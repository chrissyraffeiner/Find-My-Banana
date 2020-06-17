//
//  ConnectWithPinView.swift
//  findMyBanana
//
//  Created by Maja Drinovac on 01.04.20.
//  Copyright © 2020 Laura Riener. All rights reserved.
//

import UIKit

class ConnectWithPinView: UIViewController {
    
    var test:Bool = true

    @IBOutlet weak var numberOne: UIView!
    @IBOutlet weak var numberTwo: UIView!
    @IBOutlet weak var numberThree: UIView!
    @IBOutlet weak var numberFour: UIView!
    @IBOutlet weak var numberFive: UIView!
    
    
    @IBOutlet weak var TextFieldOne: UITextField!
    @IBOutlet weak var TextFieldTwo: UITextField!
    @IBOutlet weak var TextFieldThree: UITextField!
    @IBOutlet weak var TextFieldFour: UITextField!
    @IBOutlet weak var TextFieldFive: UITextField!
    
    @IBOutlet weak var pinFieldsView: UIView!
    
    @IBAction func TextFieldOneEC(_ sender: UITextField) {
        TextFieldOne.tag = 1
        print(TextFieldOne.tag)
        textChanged(tag: TextFieldTwo.tag, tf: TextFieldOne)
    }
    @IBAction func TextFieldTwoEC(_ sender: UITextField) {
        TextFieldTwo.tag = 2
        textChanged(tag: TextFieldThree.tag, tf: TextFieldTwo)
    }
    @IBAction func TextFieldThreeEC(_ sender: UITextField) {
        TextFieldThree.tag = 3
        textChanged(tag: TextFieldFour.tag, tf: TextFieldThree)
    }
    @IBAction func TextFieldFourEC(_ sender: UITextField) {
        TextFieldFour.tag = 4
        textChanged(tag: TextFieldFive.tag, tf: TextFieldFour)
    }
    @IBAction func TextFieldFiveEC(_ sender: UITextField) {
        TextFieldFive.tag = 5
        textChanged(tag:-1, tf: TextFieldFive)
    }
    
    //let checkTokenUrl = "http://31.214.245.100:3000/checktoken"
    //let checkTokenUrl = "http://192.168.1.175:3000/checktoken"
    //let localServer = "http://192.168.1.175:8080"
    //let localServer = "http://192.168.0.105:3000"
    let localServer = "http://172.17.214.100:3000"
    let serverURL = "http://vm112.htl-leonding.ac.at:8080"
    //let serverURL = "http://31.214.245.100:3000"

    var token = ""
    var gameExists:String = ""
    
    /*
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
     // Try to find next responder
     if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
        nextField.becomeFirstResponder()
     } else {
        // Not found, so remove keyboard.
        textField.resignFirstResponder()
     }
     */
    
    func textChanged(tag:Int, tf:UITextField) {
        let inhalt :String = tf.text!
        if(inhalt.count>0) {
            print(inhalt)
            print(tag)
            if let newTF = tf.superview?.viewWithTag(tag) as? UITextField {
                TextFieldFour.becomeFirstResponder()
            } else {
                   // Not found, so remove keyboard.
                   tf.resignFirstResponder()
                }
        }
    }
    
    @IBAction func nextBtn(_ sender: UIBarButtonItem) {
        nextView()
    }
    
    func checkPin()->Bool{
        
        return true
    }
    
    func shakeTest(){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.06
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: pinFieldsView.center.x - 7, y: pinFieldsView.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: pinFieldsView.center.x + 7, y: pinFieldsView.center.y))
        
        pinFieldsView.layer.add(animation, forKey: "position")
    }
    
    @IBAction func gestureNext(_ sender: UIScreenEdgePanGestureRecognizer) {
        if(sender.state == .began){
            nextView()
        }
    }
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        addShadow(view: numberOne)
        addShadow(view: numberTwo)
        addShadow(view: numberThree)
        addShadow(view: numberFour)
        addShadow(view: numberFive)
        // Do any additional setup after loading the view.
        
        
    }
    
    func addShadow(view: UIView){
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4
    }
    
    fileprivate func nextView() {
        print("sth")
        if(TextFieldOne.text)!.count > 0 && (TextFieldTwo.text)!.count > 0 && (TextFieldThree.text)!.count > 0 && (TextFieldFour.text)!.count > 0 && (TextFieldFive.text)!.count > 0{
            self.token = "\(TextFieldOne.text!)\(TextFieldTwo.text!)\(TextFieldThree.text!)\(TextFieldFour.text!)\(TextFieldFive.text!)"
            print(self.token)
            
            //self.setupPost()
            let queue = DispatchQueue(label: "myQueue")
            queue.async{
                self.setupGet()
            }

        } else {
            print("unvollständiger Code")
        }
    }
    
    func setupGet(){
        if let url = URL(string: "\(self.serverURL)/checktoken/\(self.token)"){
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check if Error took place
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
                
                // Read HTTP Response Status code
                if let response = response as? HTTPURLResponse {
                    print("Response HTTP Status code: \(response.statusCode)")
                }
                
                // Convert HTTP Response Data to a simple String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        if(dataString == "true"){
                            self.performSegue(withIdentifier: "JoinGameUsername", sender: self)
                        }else{
                            self.shakeTest()
                        }
                    }
                }
                
            }.resume()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "JoinGameUsername") {
                let vc = segue.destination as! ConnectWithUsernameView
            vc.admin = false
            vc.token = self.token
            //vc.timeInSec = self.timeInSec
        }
    }
    

}

struct TokenModel:Codable{
    var token: String
}
