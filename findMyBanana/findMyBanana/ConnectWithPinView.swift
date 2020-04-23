//
//  ConnectWithPinView.swift
//  findMyBanana
//
//  Created by Maja Drinovac on 01.04.20.
//  Copyright © 2020 Laura Riener. All rights reserved.
//

import UIKit

class ConnectWithPinView: UIViewController {

    @IBOutlet weak var numberOne: UIView!
    @IBOutlet weak var numberTwo: UIView!
    @IBOutlet weak var numberThree: UIView!
    @IBOutlet weak var numberFour: UIView!
    @IBOutlet weak var numberFive: UIView!
    
    
    @IBAction func nextBtn(_ sender: UIBarButtonItem) {
        nextView()
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
        performSegue(withIdentifier: "JoinGameUsername", sender: self)
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
