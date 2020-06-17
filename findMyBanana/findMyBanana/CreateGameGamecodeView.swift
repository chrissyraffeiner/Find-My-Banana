//
//  GenerateCodeViewController.swift
//  findMyBanana
//
//  Created by Maja Drinovac on 17.03.20.
//  Copyright © 2020 Laura Riener. All rights reserved.
//
import UIKit

class CreateGameGamecodeView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    //let serverURL = "http://31.214.245.100:3000"
    //let localServer = "http://192.168.1.175:8080"
    //let localServer = "http://172.17.214.100:3000"
    //let serverURL = "http://192.168.0.105:3000"
    let serverURL = "http://vm112.htl-leonding.ac.at:8080"

    var token = ""
    let spielerliste = Spielerliste()
    var jsonModel = GameModel(anz: 3, timeInSec: 5, token: "")
    var shareUrl = ""
    var username = ""
    var parameter = ["":""]
    var emojis = ["\u{1F973}", "\u{1F36A}","\u{1F480}","\u{1F47E}","\u{1F98A}","\u{1F42C}","\u{1F41D}","\u{1F354}"]
    //var arr:Array<String> = []
    //var users:Array<String> = []
    var counter = 0
    var user:Array<Dictionary<String,Any>> = []
    let queue = DispatchQueue(label: "myQueue", attributes: .concurrent)

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
        //self.users[0] = username
        //self.arr[0] = self.emojis[Int.random(in: 0 ... 7)]
        //self.usernameLabel.text = username
        // Do any additional setup after loading the view.
        addShadow(view: shareBtnView)
        queue.async{
            self.setupPost()
            print("token: \(self.token), jsonmodel: \(self.jsonModel)")
        }//async
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(user.count)
        return user.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        let cellIndex = indexPath.item
        cell.text.text = user[cellIndex]["emoji"] as! String
        cell.username.text = user[cellIndex]["username"] as! String
        print("user: \(user[cellIndex])")

        return cell
    }
    func poll(){
        print("poll startetd")
        if let url = URL(string: "\(serverURL)/poll?counter=\(self.counter)&token=\(self.token)"){

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
                                     print(Int(x["count"] as! String))
                                     self.counter = Int(x["count"] as! String)!
                                     //String(data: x["new"] as! Data, encoding: .utf8)
                                     print(x["users"])
                                     //let values​ = x["new"] as! NSArray
                                     //self.arr.append((values​[0] as! NSString) as String)
                                     //self.users.append((values​[0] as! NSString) as String)
                                     //self.users.append(x["users"] as! String)
                                     
                                     //self.users = x["users"].username as! Array<String>
                                     //self.arr = x["users"].emoji as! Array<String>
                                     self.user = x["users"] as! Array<Dictionary<String,Any>>
                                     self.collectionView.reloadData()
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
    

    
    func addShadow(view: UIView){
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4
        view.layer.cornerRadius = 20
    }
    
    func setupPost() {
        
        if let url = URL(string: "\(serverURL)/createGame") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let poststring = "anz=\(jsonModel.anz)&timeInSec=\(jsonModel.timeInSec)"
            print(poststring)
            request.httpBody = poststring.data(using: String.Encoding.utf8)
            
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    self.token = dataString
                    self.shareUrl = self.token//"findMyBanana://\(self.token)"
                    print("url: \(self.shareUrl)")
                    DispatchQueue.main.async {
                        self.tokenLabel.text = self.token
                        print("token: \(self.token)")
                        self.parameter = ["token": self.token, "username": self.username, "emoji": self.emojis[Int.random(in: 0...7)]]
                        print(self.parameter)
                        self.jsonModel.token = self.token
                        print("view did load token: \(self.token), model: \(self.jsonModel)")
                        self.poll()
                        self.joinGame(parameter: self.parameter)
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
    
    func joinGame(parameter:[String:String]){

        if let url = URL(string: "\(serverURL)/joinGame") {

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let username = parameter["username"]
            let token = parameter["token"]
            let emoji = parameter["emoji"]
            let poststring = "token=\(token!)&username=\(username!)&emoji=\(emoji!)"
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
                           //     self.user = dict["username"] as! Array<Dictionary<String,String>>
                             //   self.user = dict["emoji"] as! Array<Dictionary<String,String>>
                                self.user.append( dict as! Dictionary<String,String>)
                                spieler.username = username
                                spieler.emoji = emoji
                                self.spielerliste.spieler.append(spieler)

                                print("usernem: \(username), emoji: \(emoji)")
                               }
                       // self.user = jsonObj["username"] as! Array<Dictionary<String,String>>

                    }

                    DispatchQueue.main.async {
                        print("token: \(self.token)")
                      /*  self.user = []
                        print("spielerliste count: \(self.spielerliste.spieler.count)")
                        print("user count: \(self.user.count)")
                        for i in 0..<self.spielerliste.spieler.count {
                          //  self.user[i]["emoji"]?.append("String") //(self.spielerliste.spieler[i].emoji)
                            self.user[i]["username"] += (self.spielerliste.spieler[i].username)
                            print(self.user[i]["username"])
                            self.user = self.spielerliste.spieler as! Array<Dictionary<String,String>>

                        }*/
                        print("user count: \(self.user.count)")

                        self.collectionView.reloadData()

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
    
    func sendGameStart(){
        print("send game start")
        if let url = URL(string: "\(serverURL)/startGame?token=\(self.token)"){
            var request = URLRequest(url:url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async{
                        print("datastring: \(dataString), jsonModel: \(self.jsonModel)")
                    }
                }
                if let error = err {
                    print("Error took place \(error)")
                }
            }.resume()
        }
    }
    
  fileprivate func next(){
    performSegue(withIdentifier: "gameStart", sender: self)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
      if(segue.identifier == "gameStart") {
        queue.async {
            self.sendGameStart()
        }
        let vc = segue.destination as! CameraView
        print("jsonModel: \(jsonModel)")
        vc.einstellungen = jsonModel
         vc.user = user
        
        vc.username = username
      }
  }
    
}
