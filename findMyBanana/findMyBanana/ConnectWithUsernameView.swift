//
//  ConnectWithUsernameView.swift
//  findMyBanana
//
//  Created by Maja Drinovac on 01.04.20.
//  Copyright © 2020 Laura Riener. All rights reserved.
//

import UIKit

class ConnectWithUsernameView: UIViewController {
    let setUsernameUrl = "http://172.0.0.1:3000/joinGame"
    //let setUsernameUrl "http://192.168.0.100:3000/joinGame"

    @IBOutlet weak var usernameTF: UITextField!
    
    @IBAction func gestureNext(_ sender: UIScreenEdgePanGestureRecognizer) {
        if(sender.state == .began){
            nextView()
        }
    }
    
    @IBAction func nextBtn(_ sender: UIBarButtonItem) {
        nextView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //addShadow(tf: usernameTF)
        // Do any additional setup after loading the view.
        
    }
    
    fileprivate func nextView() {
        performSegue(withIdentifier: "PartyRoom", sender: self)
    }
    
    func addShadow(tf: UITextField){
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 10
    }
    
    func setupPost() {
        
        if let url = URL(string: self.setUsernameUrl) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
                        
            let jsondata = try? JSONEncoder().encode(usernameTF.text)

            request.httpBody = jsondata
            
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                }
                if let error = err {
                    print("Error took place \(error)")
                }
            }.resume()
        }else{
            print("URL ist flasch")
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print("username: \(usernameTF.text!)")
        if(segue.identifier == "PartyRoom") {
            self.setupPost()
            let vc = segue.destination as! PartyRoomView
            vc.username = usernameTF.text!
        }
    }

}

