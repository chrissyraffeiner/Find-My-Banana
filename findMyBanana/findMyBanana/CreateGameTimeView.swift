//
//  CreateGameTimeView.swift
//  findMyBanana
//
//  Created by Administrator on 13.03.20.
//  Copyright © 2020 Laura Riener. All rights reserved.
//

import UIKit

class CreateGameTimeView: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
        
    @IBOutlet weak var timePicker: UIPickerView!
    var timeInSec : Int = 5
    
    @IBOutlet weak var testLabel: UILabel!
    
    @IBAction func next(_ sender: UIBarButtonItem) {
        nextView()
    }
    
    fileprivate func nextView() {
        performSegue(withIdentifier: "CreateGameEmoji", sender: self)
    } 
    
    @IBAction func gestureNext(_ sender: UIScreenEdgePanGestureRecognizer) {
        if(sender.state == .began){
            nextView()
        }
        
    }
   override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.timePicker.delegate = self
        self.timePicker.dataSource = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 30-4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 5) sec"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(row)
        timeInSec = row + 5
        print("\(timeInSec)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if(segue.identifier == "CreateGameEmoji") {
            let vc = segue.destination as! CreateGameEmojiView
            vc.timeInSec = self.timeInSec
        }
    }
    

}
