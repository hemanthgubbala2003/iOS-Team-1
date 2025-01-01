//
//  CreateAccountViewController.swift
//  05-Login-Module
//
//  Created by FCI on 29/12/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createAccountPressed(_ sender: UIButton) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            
            Auth.auth().createUser(withEmail: email, password: password){authResult,error in
                
                if let e = error {
                    print(e.localizedDescription)
                } else{
                    // If not for the async bloc it may run on parallel thread causing exception
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: Constants.createAccountSegue, sender: self)
                    }

                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.createAccountSegue {

            if let registerViewController = segue.destination as? RegisterViewController {
                // Pass the data
                print("\(emailTextfield.text!)")
                registerViewController.email = emailTextfield.text
            }
        }
    }




}
