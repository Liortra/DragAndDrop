import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        
        setUpElements()
    }
    
    //MARK:- Helper functions
    func setUpElements(){
        // Hide the error label
        errorLabel.alpha = 0
        // Style the elements
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }
    
    // Check the fields and validate them
    func vaildateFields() -> String?{
        
        //Check that all fields are filled in
        if  emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fiil in all fields"
        }
        
        return nil
    }
    
    func showError(_ message:String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    //MARK:- login button
    @IBAction func loginTapped(_ sender: Any) {
        // Vaildate text fields
        let error = vaildateFields()
        if error != nil {
            showError(error!)
        }
        else{
            // Create cleaned version of the text field
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Signing the user
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if error != nil{
                    self.showError(error!.localizedDescription)
                }
                else{
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier:Constants.Segue.Segue_toMain, sender: nil)
                    }
                }
            }
        }
    }
}
