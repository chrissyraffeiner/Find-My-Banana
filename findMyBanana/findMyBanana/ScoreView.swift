//
//  ScoreView.swift
//  findMyBanana
//
//  Created by Maja Drinovac on 05.06.20.
//  Copyright © 2020 Laura Riener. All rights reserved.
//

import UIKit

class ScoreView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user:Array<Dictionary<String,Any>> = []
    var runde = 1
    var emojiAnz = 0
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(user.count)
        return user.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let punkte:Int = user[indexPath.row]["punkte"]! as! Int
        cell.textLabel?.text = String(punkte)
        cell.detailTextLabel?.text = "\(user[indexPath.row]["username"]!) \(user[indexPath.row]["emoji"]!)"
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func nextBtn(_ sender: UIBarButtonItem) {
        if(runde<emojiAnz) {
            //nochmal
            self.performSegue(withIdentifier: "playAgain", sender: self)
        } else {
            //start
            self.performSegue(withIdentifier: "start", sender: self)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "playAgain") {
            let vc = segue.destination as! CameraView
            print("playAgain \(vc.runde)")
            vc.runde = vc.runde + 1
        }
        
        if(segue.identifier == "start") {
            print("start")
        }
    }
    

}
