//
//  CameraView.swift
//  findMyBanana
//
//  Created by Maja Drinovac on 22.04.20.
//  Copyright © 2020 Laura Riener. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreML

class CameraView: UIViewController {

    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var animatedView: UIView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var detectedLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    
    var points = 0
    let session = AVCaptureSession()
    var counter = 0
    var counterTimer = Timer()
    var counterStartValue = 3
    var isCountdownFinished = false
    var einstellungen = GameModel(anz: 3, timeInSec: 5)
    
    var found=false
    var item = "banana"
    
    var audioPlayer:AVAudioPlayer?
    
    @IBOutlet weak var findView: UIView!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var findTime: UILabel!
    
    var isEmojiShown = false
    
    @IBAction func showHideUser(_ sender: UIButton) {
    }
    
    
    override func viewDidLoad() {
        findTime.text = "find in under \(einstellungen.timeInSec) sec"
        super.viewDidLoad()
        view.bringSubviewToFront(animatedView)
        startCountdown()
    }
    
    func startCountdown(){
        animatedView.backgroundColor = UIColor(red: 48/255, green: 99/255, blue: 1, alpha: 1)
        counter = 3
        startCounter()
    }
    
    func startCounter(){
        counterTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(decrementCounter), userInfo: nil, repeats: true)
    }
    
    @objc func decrementCounter(){
        if(!isCountdownFinished){
            let pathToSound = Bundle.main.path(forResource: "countdown_sound", ofType: "wav")!
            let url = URL(fileURLWithPath: pathToSound)
            do{
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            }catch{
                print("ned so")
            }
            counter -= 1
            switch(counter){
            case 2:
                //yellow
                animatedView.backgroundColor = UIColor(red: 1, green: 204/255, blue: 48/255, alpha: 1)
                break
            case 1:
                //green
                animatedView.backgroundColor = UIColor(red: 1/255, green: 220/255, blue: 91/255, alpha: 1)
            default:
                animatedView.backgroundColor = UIColor.white
            }
            countdownLabel.text = "\(counter)"
            if counter <= 0{
                if(!isEmojiShown){
                    isEmojiShown = true
                    schowEmoji()
                }
                if counter <= -4{
                    isCountdownFinished = true
                    animatedView.removeFromSuperview()
                    findView.removeFromSuperview()
                    print("preview")
                    view.bringSubviewToFront(preview)
                    preview.bringSubviewToFront(answerLabel)
                    preview.bringSubviewToFront(pointsLabel)
                    preview.bringSubviewToFront(userButton)
                    preview.bringSubviewToFront(detectedLabel)
                    
                    answerLabel.layer.zPosition = 10
                    pointsLabel.layer.zPosition = 10
                    userButton.layer.zPosition = 10
                    detectedLabel.layer.zPosition = 10

                    view.bringSubviewToFront(preview.subviews[0])
                    view.bringSubviewToFront(preview.subviews[1])
                    view.bringSubviewToFront(preview.subviews[2])
                    view.bringSubviewToFront(preview.subviews[3])
                    startCapture()
                }
            }
        }
    }
    
    func schowEmoji(){
        //viewstack.bringSubviewToFront(camera)
       view.bringSubviewToFront(findView)
    }
    
    func startCapture(){
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        session.sessionPreset = .photo
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        session.addInput(input)
        
        session.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        self.preview.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        previewLayer.frame = previewLayer.bounds
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self as? AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue(label: "videoQueue"))
        
        session.addOutput(output)
    }
    
    func detectScene(image: CIImage){
                guard let model = try? VNCoreMLModel(for: YOLOv3Tiny().model) else { return }

    }
    
    func captureOutput(_ output:AVCaptureOutput, didOutput samplebuffer: CMSampleBuffer, from connection: AVCaptureConnection){
    
    guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(samplebuffer) else {return}
    
    guard let model = try? VNCoreMLModel(for: YOLOv3Tiny().model) else {return }
    
    
    let request = VNCoreMLRequest(model: model){ (finishedReq, err) in
        DispatchQueue.main.async(execute: {
            // perform all the UI updates on the main queue
            if let results = finishedReq.results as? [VNDetectedObjectObservation]{
                self.drawResults(results)
            }
        })
        
    }
    
    try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    func drawResults(_ results: [Any]){
        for observation in results where observation is VNRecognizedObjectObservation{
            guard let objectRecognized = observation as? VNRecognizedObjectObservation else {return}
            
            let first = objectRecognized.labels[0]
            print(first.identifier)
            if(!found) {
                answerLabel.text = first.identifier
            if(first.identifier == item) {
                points+=1
                pointsLabel.text = "\(points)"
                found = true
                showGreenBorder()
            }
            }
        }
    }
    
    func showGreenBorder(){
        /*self.preview.layer.borderWidth = 1
        self.preview.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor*/
        answerLabel.textColor = UIColor(red:0/255, green:225/255, blue:0/255, alpha: 1)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
