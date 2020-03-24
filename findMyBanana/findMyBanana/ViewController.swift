import UIKit

class ViewController: UIViewController {

    @IBOutlet var findmxBananaView: UIView!
    @IBOutlet weak var createBtnView: UIView!
    @IBOutlet weak var connectBtnView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addShadow(view: self.createBtnView)
        addShadow(view: self.connectBtnView)
    }
    
    func addShadow(view: UIView){
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4
        view.layer.cornerRadius = 10
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
