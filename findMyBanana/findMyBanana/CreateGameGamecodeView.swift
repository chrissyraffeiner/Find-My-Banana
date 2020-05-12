//
//  GenerateCodeViewController.swift
//  findMyBanana
//
//  Created by Maja Drinovac on 17.03.20.
//  Copyright © 2020 Laura Riener. All rights reserved.
//

import UIKit

class CreateGameGamecodeView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let createGameUrl = "http://192.168.0.105:3000/createGame"
    //let createGameUrl = "http://127.0.0.1:3000/createGame"
    var token = ""
    var jsonModel = GameModel(anz: 3, timeInSec: 5)
    var shareUrl = ""
    var username = ""
    var parameter = ["":""]
    var arr = ["\u{1F36A}"]
    var users = [""]
    var counter = 0

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var shareBtnView: UIView!
        
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func shareLinkBtn(_ sender: UIButton) {
        let activityVC = UIActivityViewController(activityItems: [self.shareUrl], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBOutlet weak var tokenLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        self.users[0] = username
        //self.usernameLabel.text = username
        let queue = DispatchQueue(label: "myQueue", attributes: .concurrent)
        // Do any additional setup after loading the view.
        addShadow(view: shareBtnView)
        queue.async{
            self.setupPost()
            print(self.token)
        }//async
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        let cellIndex = indexPath.item
        cell.text.text = arr[cellIndex]
        cell.username.text = users[cellIndex]
        return cell
    }
    func poll(){
        print("poll startetd")
        if let url = URL(string: "http://192.168.0.105:3000/poll?counter=\(self.counter)&token=\(self.token)"){
            var request = URLRequest(url:url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("data: \(data)")
                    //print(dataString)
                    
                    DispatchQueue.main.async {
                        if(dataString != "Try again"){
                            if let x = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]{
                                self.counter = x["count"] as! Int
                                //String(data: x["new"] as! Data, encoding: .utf8)
                                let values​ = x["new"] as! NSArray
                                self.arr.append((values​[0] as! NSString) as String)
                                print(self.arr)
                            }else{
                                print("failed parse")
                            }
                           self.poll()
                        }else{
                            print("was i ned")
                            self.poll()
                        }
                    }//DispatchQueue
                }
                if let error = err {
                    print("Error took place \(error)")
                }
            }.resume()
        }
    }
    
    func joinGame(parameter:[String:String]){
        if let url = URL(string: "http://192.168.0.105:3000/joinGame") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            var username = parameter["username"]
            var token = parameter["token"]
            //let jsondata = try? JSONEncoder().encode(model)
            var poststring = "token=\(token!)&username=\(username!)"
            request.httpBody = poststring.data(using: String.Encoding.utf8)
            
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    //print("dataString: \(dataString)")
                    print(dataString)
                    //self.saveToken(token:dataString)
                    //print("token: \(self.token)")
                    DispatchQueue.main.async {
                        //self.tokenLabel.text = self.token
                        print("token: \(self.token)")
                        self.poll()
                       // self.arr.append("new")
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
    
    func addShadow(view: UIView){
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4
        view.layer.cornerRadius = 20
    }
    
    func setupPost() {
        
        if let url = URL(string: self.createGameUrl) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
                        
            let jsondata = try? JSONEncoder().encode(jsonModel)
            let poststring = "anz=\(jsonModel.anz)&timeInSec=\(jsonModel.timeInSec)"

            request.httpBody = poststring.data(using: String.Encoding.utf8)
            
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    //print("dataString: \(dataString)")
                    self.token = dataString
                    //self.saveToken(token:dataString)
                    //print("token: \(self.token)")
                    
                    self.shareUrl = self.token//"findMyBanana://\(self.token)"
                    print("url: \(self.shareUrl)")
                    DispatchQueue.main.async {
                        //self.tokenLabel.text = self.token
                        print("token: \(self.token)")
                        self.parameter = ["token": self.token, "username": self.username]
                        self.joinGame(parameter: self.parameter)
                        self.arr.append("new")
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
    
  fileprivate func next(){
      performSegue(withIdentifier: "gameStart", sender: self)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
      if(segue.identifier == "gameStart") {
          let vc = segue.destination as! CameraView
        vc.einstellungen = jsonModel
      }
  }
    
}
