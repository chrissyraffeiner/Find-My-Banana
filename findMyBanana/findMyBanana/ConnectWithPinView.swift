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
        if(checkPin()){
            shakeTest()
        }else{
            nextView()
        }
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
            performSegue(withIdentifier: "JoinGameUsername", sender: self)

        } else {
            print("unvollständiger Code")
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "JoinGameUsername") {
                let vc = segue.destination as! ConnectWithUsernameView
            //vc.timeInSec = self.timeInSec
        }
    }
    

}
