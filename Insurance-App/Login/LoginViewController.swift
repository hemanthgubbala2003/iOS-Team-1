//
//  LoginViewController.swift
//  05-Login-Module
//
//  Created by FCI on 29/12/24.
//
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    

    @IBAction func loginPressed(_ sender: UIButton) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e)
                } else {
                    // If not for the async bloc it may run on parallel thread causing exception
                    DispatchQueue.main.async {
                        print("\(self.emailTextfield.text!)")
                        //Customer.getCustomers(customerEmail: self.emailTextfield.text!)
                        self.performSegue(withIdentifier: Constants.loginSegue, sender: self)
                        
                    }

                    
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.loginSegue {

            if let welcomeViewController = segue.destination as? WelcomeViewController {
                // Pass the data
                welcomeViewController.email = emailTextfield.text!
                print("\(self.emailTextfield.text!)")
                
            }
        }
    }

    
}
