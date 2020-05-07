//
//  PartyRoomView.swift
//  findMyBanana
//
//  Created by Maja Drinovac on 01.04.20.
//  Copyright © 2020 Laura Riener. All rights reserved.
//

import UIKit

class PartyRoomView: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    var username = "player"
    var counter = 0
    var token = ""
    
    override func viewDidLoad() {
        usernameLabel.text = username
        super.viewDidLoad()
        print("hello, \(username)")
        // Do any additional setup after loading the view.
    }
    
    func joinGame(parameter:[String:String]){
        if let url = URL(string: "http://192.168.0.100:3000/joinGame") {
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
                                  // print("token: \(self.token)")
                                   //self.arr.append("new")
                                   print(dataString)
                                   //self.poll()
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
        
    func poll(){
        if let url = URL(string: "http://192.168.0.105:3000/poll?counter=\(self.counter)&token=\(self.token)"){
            var request = URLRequest(url:url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    //print("dataString: \(dataString)")
                    print(dataString)
                    //self.saveToken(token:dataString)
                    //print("token: \(self.token)")
                    
                    DispatchQueue.main.async {
                        //self.tokenLabel.text = self.token
                       // print("token: \(self.token)")
                        //self.arr.append("new")
                        print(dataString)
                        self.poll()
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
