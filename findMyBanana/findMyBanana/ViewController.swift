import UIKit

class ViewController: UIViewController {

    @IBOutlet var findmxBananaView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func ConnectGame(_ sender: Any) {
         performSegue(withIdentifier: "showJoinGameSence1", sender: self)
        
    }
    
    @IBAction func CreateGame(_ sender: Any) {
         performSegue(withIdentifier: "showCreateGame1", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showCreateGame1"){
            
        }
        
        if(segue.identifier == "showJoinGameSence1"){
            
        }
    }
}
