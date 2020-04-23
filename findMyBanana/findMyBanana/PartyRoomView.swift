//
//  PartyRoomView.swift
//  findMyBanana
//
//  Created by Maja Drinovac on 01.04.20.
//  Copyright © 2020 Laura Riener. All rights reserved.
//

import UIKit

class PartyRoomView: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    var username = "player"
    
    override func viewDidLoad() {
        usernameLabel.text = username
        super.viewDidLoad()
        print("hello, \(username)")
        // Do any additional setup after loading the view.
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
