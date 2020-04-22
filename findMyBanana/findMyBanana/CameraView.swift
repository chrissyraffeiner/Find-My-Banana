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
    let session = AVCaptureSession()
    @IBOutlet weak var animatedView: UIView!
    @IBOutlet weak var answerLabel: UILabel!
    
    var counter = 0
    var counterTimer = Timer()
    var counterStartValue = 3
    var isCountdownFinished = false
    
    var audioPlayer:AVAudioPlayer?
    
    @IBOutlet weak var findView: UIView!
    @IBOutlet weak var countdownLabel: UILabel!
    
    override func viewDidLoad() {
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
                isCountdownFinished = true
                schowEmoji()
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
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
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
            answerLabel.text = first.identifier
        }
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
