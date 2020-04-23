//
//  GenerateCodeViewController.swift
//  findMyBanana
//
//  Created by Maja Drinovac on 17.03.20.
//  Copyright © 2020 Laura Riener. All rights reserved.
//

import UIKit

class CreateGameGamecodeView: UIViewController {
    //let createGameUrl = "http://192.168.1.104:3000/createGame"
    let createGameUrl = "http://127.0.0.1:3000/createGame"
    var token = ""
    var jsonModel = GameModel(anz: 3, timeInSec: 5)
    var shareUrl = ""

    @IBOutlet weak var shareBtnView: UIView!
    
    @IBOutlet weak var tokenLabel: UILabel!
    
    @IBAction func shareLinkBtn(_ sender: UIButton) {
        let activityVC = UIActivityViewController(activityItems: [self.shareUrl], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupPost()
        //self.tokenLabel.text = self.token
        addShadow(view: shareBtnView)
    }
    
    func addShadow(view: UIView){
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4
        view.layer.cornerRadius = 20
    }
    
    func setupPost(){
        
        if let url = URL(string: self.createGameUrl) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
                        
            var jsondata = try? JSONEncoder().encode(jsonModel)

            request.httpBody = jsondata
            
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    //print("dataString: \(dataString)")
                    self.token = dataString
                    //self.saveToken(token:dataString)
                    //print("token: \(self.token)")
                    self.shareUrl = "findMyBanana://\(self.token)"
                    print("url: \(self.shareUrl)")
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
