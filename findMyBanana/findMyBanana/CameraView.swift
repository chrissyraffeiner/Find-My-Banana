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

class CameraView: UIViewController,  AVCaptureVideoDataOutputSampleBufferDelegate, UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { //Spalten
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var punkte:Int = user[indexPath.row]["punkte"]! as! Int
        cell.textLabel?.text = String(punkte)
        cell.detailTextLabel?.text = "\(user[indexPath.row]["username"]!) \(user[indexPath.row]["emoji"]!)"
        return cell
    }
    

    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var animatedView: UIView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var detectedLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    
    @IBOutlet weak var userTable: UITableView!
    
    let session = AVCaptureSession()
    var counter = 0
    var counterTimer = Timer()
    var counterStartValue = 3
    var isCountdownFinished = false
    
    var einstellungen = GameModel(anz: 3, timeInSec: 5, token: "")
    var points = 0
    var username = ""
    var emoji = ""
    var user:Array<Dictionary<String,Any>> = []

    var open = false
    var found=false
    var item = "banana"
    
    var audioPlayer:AVAudioPlayer?
    
    @IBOutlet weak var findView: UIView!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var findTime: UILabel!
    
    var isEmojiShown = false
    var dataSource = DataSource()
    
    var users:Array<Dictionary<String, Any>> = []

    //let serverURL = "http://192.168.0.105:3000"
    //let localServer = "http://192.168.1.175:8080"
    //let localServer = "http://172.17.214.100:3000"
    let serverURL = "http://vm112.htl-leonding.ac.at:8080"
    //let serverURL = "http://31.214.245.100:3000"
    var itemU = "\u{1F973}"

    @IBOutlet weak var findItemLabel: UILabel!
    
    let url = URL(fileURLWithPath: Bundle.main.path(forResource: "countdown_sound", ofType: "wav")!)
    let cameraSoundUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "camera", ofType: "mp3")!)
    let failedSoundUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "ohno", ofType: "mp3")!)
    var timerIsFinished = false
    
    var count = 0
    var token = ""
    
    
    @IBAction func scoreBtn(_ sender: UIBarButtonItem) {
        print("btn clicked")
        let queue = DispatchQueue(label: "get")
        queue.async {
            self.getScores()
        }
    }
    
    @IBAction func showHideUser(_ sender: UIButton) {
        if open {
            userTable.layer.zPosition = -10
            
        } else {
            
            userTable.layer.zPosition = 60

        }
        open = !open
    }
    
    override func viewDidLoad() {
        findTime.text = "find in under \(einstellungen.timeInSec) sec"
        super.viewDidLoad()
        let queue = DispatchQueue(label:"queue")
        print("model cameraView: \(einstellungen)")
        timerLabel.text = "\(einstellungen.timeInSec)"
        queue.async{
            self.getItem()
        }
        view.bringSubviewToFront(animatedView)
        userTable.dataSource = self
        userTable.delegate = self
        //dataSource.user = user
        prepareSound(soundURL:url)
        startCountdown()
    }
    
    func getScores(){
        print(self.token)
        if let url = URL(string: "\(serverURL)/scoreResults/\(self.einstellungen.token)"){
            var request = URLRequest(url:url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: url){(data, response, err) in
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("score datastring: \(dataString)")
                    DispatchQueue.main.async{
                        self.performSegue(withIdentifier: "score", sender: self)
                    }
                    /*if let obj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]{
                    }
                    DispatchQueue.main.async{
                    }*/
                }
            }.resume()
        }
    }
    
    func prepareSound(soundURL:URL){
        do{
            audioPlayer = try? AVAudioPlayer(contentsOf: soundURL)
            //audioPlayer?.play()
        }catch{
            print("ned so")
        }
    }
    
    func getItem(){
        var itemU = ""
        var item = ""
        if let url = URL(string: "\(serverURL)/emojiToFind"){
            var request = URLRequest(url:url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    if let obj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]{
                        itemU = obj["emoji"] as! String
                        item = obj["name"] as! String
                    }
                    DispatchQueue.main.async{
                        print("unicode: \(itemU), name: \(item)")
                        self.item = item
                        self.itemU = itemU
                        self.findItemLabel.text = self.itemU
                    }
                }
            }.resume()
        }
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
            audioPlayer?.play()
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
                    //view.bringSubviewToFront(preview)
                    
                    answerLabel.layer.zPosition = 10
                    pointsLabel.layer.zPosition = 10
                    userButton.layer.zPosition = 10
                    detectedLabel.layer.zPosition = 10
                    let queue = DispatchQueue(label: "queue", attributes: .concurrent)
                    queue.async {
                        self.poll()
                    }

                    self.startCapture()
                    print("start capture")
                    self.startTimer()
                }
            }
        } else {
            //counterTimer.invalidate()
            counterTimer = Timer()
        }
    }
    
    func schowEmoji(){
        //viewstack.bringSubviewToFront(camera)
       view.bringSubviewToFront(findView)
    }
    
    func startCapture(){
        pointsLabel.text = "\(points)"
        if let captureDevice = AVCaptureDevice.default(for: .video){
            session.sessionPreset = .photo
            if let input = try? AVCaptureDeviceInput(device: captureDevice) {
                session.addInput(input)
                
                session.startRunning()
                
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.videoGravity = .resizeAspectFill
                self.preview.layer.addSublayer(previewLayer)
                previewLayer.frame = view.frame
                previewLayer.frame = previewLayer.bounds
                
                let output = AVCaptureVideoDataOutput()
                output.setSampleBufferDelegate(self as? AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue(label: "videoQueue"))
                print("131")
                session.addOutput(output)
            }
            else {
                return
                
            }
            
            
        } else {
            print("116")
            return
        }
        
    }
    
    func detectScene(image: CIImage){
        if let model = try? VNCoreMLModel(for: YOLOv3Tiny().model){} else { print("fehler 148") }

    }
    
    func captureOutput(_ output:AVCaptureOutput, didOutput samplebuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        if let pixelBuffer: CVPixelBuffer = try? CMSampleBufferGetImageBuffer(samplebuffer) {
            if let model = try? VNCoreMLModel(for: YOLOv3Tiny().model) {
                let request = VNCoreMLRequest(model: model){ (finishedReq, err) in
                    print(err)
                DispatchQueue.main.async(execute: {

                    // perform all the UI updates on the main queue
                    if let results = finishedReq.results as? [VNDetectedObjectObservation]{
                        self.drawResults(results)
                    }
                })
                
                }
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])

            
            
                
            } else {
                print("fehler 173")
            }
            
        }
        else {
            print("fehler 176")
            return}
    
    
    }
    
    func drawResults(_ results: [Any]){
        for observation in results where observation is VNRecognizedObjectObservation{
            guard let objectRecognized = observation as? VNRecognizedObjectObservation else {return}
            
            let first = objectRecognized.labels[0]
            //print(first.identifier)
            if(!found) {
                answerLabel.text = first.identifier
            if(first.identifier == item) {
                points+=1
                pointsLabel.text = "\(points)"
                var parameter = ["token":einstellungen.token, "username": self.username, "emoji": self.emoji, "punkte": String(points)]
                let queue = DispatchQueue(label: "queue", attributes: .concurrent)
                queue.async {
                    self.prepareSound(soundURL: self.cameraSoundUrl)
                    self.foundItem(parameter: parameter)
                }
                found = true
                showGreenBorder()
            }
            }
        }
    }
    
    func showGreenBorder(){
        /*self.preview.layer.borderWidth = 1
        self.preview.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor*/
        audioPlayer?.play()
        answerLabel.textColor = UIColor(red:0/255, green:225/255, blue:0/255, alpha: 1)
    }

    func poll(){
        print("poll startetd")
        if let url = URL(string: "\(serverURL)/poll?counter=\(self.count)&token=\(self.einstellungen.token)"){

            var request = URLRequest(url:url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    
                    
                    DispatchQueue.main.async {
                        print("datastring: \(dataString)")
                        if(dataString == "Try again"){
                            print("nixx neues")
                            self.poll()
                        }else{
                            if(dataString == "Game started"){
                                print("game started")
                            }else{
                                if let x = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]{
                                    let temp = Int(x["count"]! as! NSNumber)
                                     print("count: \(type(of: temp))")
                                    self.count = temp
                                     //String(data: x["new"] as! Data, encoding: .utf8)
                                     print(x["users"])
                                     //let values​ = x["new"] as! NSArray
                                     //self.arr.append((values​[0] as! NSString) as String)
                                     //self.users.append((values​[0] as! NSString) as String)
                                     //self.users.append(x["users"] as! String)
                                     
                                     //self.users = x["users"].username as! Array<String>
                                     //self.arr = x["users"].emoji as! Array<String>
                                     self.user = x["users"] as! Array<Dictionary<String,Any>>
                                    print("usertable user: \(self.user)")
                                    self.userTable.reloadData()
                                 }else{
                                     print("failed parse")
                                 }
                                self.poll()
                            }
                        }
                    }//DispatchQueue
                }
                if let error = err {
                    print("Error took place \(error)")
                }
            }.resume()
        }
    }
    
    func foundItem(parameter:[String:String]){
        print("paramtere: \(parameter)")

        if let url = URL(string: "\(serverURL)/foundItem") {

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let username = parameter["username"]
            let token = parameter["token"]
            //let token = self.token
            let emoji = parameter["emoji"]
            let points = parameter["punkte"]
            let poststring = "token=\(token)&username=\(username!)&emoji=\(emoji!)&punkte=\(points)"

            print(points!)
            request.httpBody = poststring.data(using: String.Encoding.utf8)
            
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("dataString: \(dataString)")
                    print("data: \(data)")
                    let spieler = Spieler()
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]]{
                               print("obj= \(jsonObj)")
                               
                               for dict in jsonObj {
                                   print("dictFOR= \(dict)")
                                let username = dict["username"] as! String
                                    let emoji = dict["emoji"] as! String
                                let punkte = dict["punkte"] as! String
                           //     self.user = dict["username"] as! Array<Dictionary<String,String>>
                             //   self.user = dict["emoji"] as! Array<Dictionary<String,String>>
                                //self.user.append( dict as! Dictionary<String,String>)
                                spieler.username = username
                                spieler.emoji = emoji
                                
                                //self.spielerliste.spieler.append(spieler)

                                print("username: \(username), emoji: \(emoji), punkte \(punkte)")
                               }
                       // self.user = jsonObj["username"] as! Array<Dictionary<String,String>>
                        
                    }

                    DispatchQueue.main.async {
                      /*  self.user = []
                        print("spielerliste count: \(self.spielerliste.spieler.count)")
                        print("user count: \(self.user.count)")
                        for i in 0..<self.spielerliste.spieler.count {
                          //  self.user[i]["emoji"]?.append("String") //(self.spielerliste.spieler[i].emoji)
                            self.user[i]["username"] += (self.spielerliste.spieler[i].username)
                            print(self.user[i]["username"])
                            self.user = self.spielerliste.spieler as! Array<Dictionary<String,String>>

                        }*/
                        self.userTable.reloadData()
                        print("user count: \(self.user.count)")

                    }//DispatchQueue
                }
                if let error = err {
                    print("Error took place \(error)")
                }
            }.resume()
        }else{
            print("URL ist flasch")
        }
    }
    func startTimer(){
        prepareSound(soundURL: failedSoundUrl)
        counter = einstellungen.timeInSec
        timerLabel.layer.zPosition = 10
        counterTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timer), userInfo: nil, repeats: true)
    }
    
    @objc func timer(){
        if(!timerIsFinished){
            counter-=1
            print("\(counter)")
            if(counter <= 3) {
                timerLabel.textColor = UIColor(red:255/255, green:0/255, blue:0/255, alpha: 1)
            }
            timerLabel.text = "\(counter)"
            if(counter == 0){
                audioPlayer?.play()
            }
            if(counter<0){
                timerLabel.layer.zPosition = 0
                counterTimer.invalidate()
                timerIsFinished = true
            }
            if(counter == -1) {
                let queue = DispatchQueue(label: "get")
                queue.async {
                    self.getScores()
                }
            }
        }
        if(found) {
            timerLabel.textColor = UIColor(red:200/255, green:100/255, blue:0/255, alpha: 1)

        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as! ScoreView
        if(segue.identifier == "score"){
            let vc = segue.destination as! ScoreView
            print("einstellungen: \(self.einstellungen)")
            vc.user = self.user
        }
    }
    

}

class DataSource : NSObject, UITableViewDataSource {
    
    var user:Array<Dictionary<String,Any>> = []

    func numberOfSections(in tableView: UITableView) -> Int { //Spalten
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var punkte:Int = user[indexPath.row]["punkte"]! as! Int
        cell.textLabel?.text = String(punkte)
        cell.detailTextLabel?.text = "\(user[indexPath.row]["username"]!) \(user[indexPath.row]["emoji"]!)"
        return cell
    }
    
}
