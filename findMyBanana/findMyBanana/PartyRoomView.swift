//
//  PartyRoomView.swift
//  findMyBanana
//
//  Created by Maja Drinovac on 01.04.20.
//  Copyright © 2020 Laura Riener. All rights reserved.
//

import UIKit

class PartyRoomView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //@IBOutlet weak var usernameLabel: UILabel!
    
    var username = "player"
    var counter = 0
    var token = ""
    var arr = ["\u{1F36A}"]
    var useArr = [Any]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.dataSource = self
        super.viewDidLoad()
        print("hello, \(username)")
        joinGame()
        poll()
        // Do any additional setup after loading the view.
    }
    
    
    func joinGame(){
      //if let url = URL(string: "http://192.168.0.100:3000/joinGame") {
        if let url = URL(string: "http://192.168.1.175:3000/joinGame") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            
            let poststring = "token=\(self.token)&username=\(self.username)"
            request.httpBody = poststring.data(using: String.Encoding.utf8)
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    
                    print(dataString)
                    
                    DispatchQueue.main.async {
                        self.arr.append("new")
                        print(dataString)
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
        //if let url = URL(string: "http://192.168.0.105:3000/poll?counter=\(self.counter)&token=\(self.token)"){
        if let url = URL(string: "http://192.168.1.175:3000/poll?counter=\(self.counter)&token=\(self.token)"){
            var request = URLRequest(url:url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print(dataString)
                    
                    DispatchQueue.main.async {
                        
                        print("datastriing: \(dataString)")
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
    
   
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        let cellIndex = indexPath.item
        print(username)
        cell.text.text = "\(arr[cellIndex])\n\(username)"
        return cell
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
