//
//  CreateGameEmojiView.swift
//  findMyBanana
//
//  Created by Administrator on 13.03.20.
//  Copyright © 2020 Laura Riener. All rights reserved.
//

import UIKit

class CreateGameEmojiView:  UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var emojiPicker: UIPickerView!
    var anz : Int = 3
    var timeInSec : Int = -1
    
    
    @IBAction func nextGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        if(sender.state == .began){
            next()
        }
    }
    
    @IBAction func next(_ sender: UIBarButtonItem) {
        next()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Zeit: \(timeInSec)")
        self.emojiPicker.delegate = self
        self.emojiPicker.dataSource = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7-2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 3) emojis"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(row)
        anz = row + 3
        print("\(anz)")
        
    }
    
    fileprivate func next(){
        performSegue(withIdentifier: "GenerateCode", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "GenerateCode") {
            let vc = segue.destination as! GenerateCodeViewController
            vc.jsonModel.timeInSec = timeInSec
            vc.jsonModel.anz = anz
        }
    }
    
    

}
