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
    var selected : Int = 3
    
    var model = Model()
    
    @IBOutlet weak var testLabel: UILabel!
    
    
    @IBAction func next(_ sender: UIBarButtonItem) {
        next()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("segue: \(model.timeInSec)")
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
        selected = row + 3
        print("\(selected)")
        
    }
    
    fileprivate func next(){
        performSegue(withIdentifier: "GenerateCode", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "GenerateCode") {
            let vc = segue.destination as! GenerateCodeViewController
            vc.model.timeInSec = model.timeInSec
            vc.model.anz = selected
        }
    }
    
    

}
