//
//  CreateGameTimeView.swift
//  findMyBanana
//
//  Created by Administrator on 13.03.20.
//  Copyright © 2020 Laura Riener. All rights reserved.
//

import UIKit

class CreateGameTimeView: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var model = Model()
    
    @IBOutlet weak var timePicker: UIPickerView!
    var selected : Int = 5
    
    @IBOutlet weak var testLabel: UILabel!
    
    @IBAction func nextBtn(_ sender: UIButton) {
        model.timeInSec = selected
        //self.performSegue(withIdentifier: "time", sender: self)
    }
    
    
    @IBAction func next(_ sender: UIBarButtonItem) {
        nextView()
    }
    
    fileprivate func nextView() {
        performSegue(withIdentifier: "CreateGameEmoji", sender: self)
    }
    
  /*  @IBAction func gestureNext(_ sender: UIScreenEdgePanGestureRecognizer) {
        nextView()
    }*/
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
        selected = row + 5
        print("\(selected)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if(segue.identifier == "CreateGameEmoji") {
            let vc = segue.destination as! CreateGameEmojiView
            vc.model.timeInSec = self.selected
        }
    }
    

}
