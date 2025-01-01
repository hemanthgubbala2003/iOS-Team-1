//
//  ViewController.swift
//  MenuBar
//
//  Created by FCI on 26/12/24.
//Rithik Task

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet var MenuBar: UIButton!
    @IBOutlet var InsuranceMenu: [UIButton]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        Constants.generateToken()
        if let user = Auth.auth().currentUser {
            let email = user.email
            let userID = user.uid
            print("Logged in user: \(email ?? "No Email"), User ID: \(userID)")
            Customer.getCustomers(customerEmail: email!) { customer, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else if let customer = customer {
                    print("Customer ID: \(customer.customerID)")
                    print("Customer Name: \(customer.customerName)")
                    print("Customer Phone: \(customer.customerPhone)")
                    print("Customer Email: \(customer.customerEmail)")
                    print("Customer Address: \(customer.customerAddress)")
                    self.title = "CID: \(customer.customerID)"
                    
                } else {
                    print("Customer not found")
                }
            }
        } else {
            print("No user is logged in.")
        }
        // Style the menu bar button
        MenuBar.layer.cornerRadius = MenuBar.frame.height / 2
        
        // Initialize all menu items
        InsuranceMenu.forEach { btn in
            btn.layer.cornerRadius = btn.frame.height / 2
            btn.isHidden = true
            btn.alpha = 0
        }
        
        
    }

    @IBAction func ClickForItems(_ sender: UIButton) {
        let shouldShow = InsuranceMenu.first?.isHidden ?? true
        InsuranceMenu.forEach { btn in
            UIView.animate(withDuration: 0.3, animations: {
                btn.alpha = shouldShow ? 1 : 0
            }, completion: { _ in
                btn.isHidden = !shouldShow
            })
        }
    }

    @IBAction func ItemPress(_ sender: UIButton) {
        // Handle individual menu item presses
        print("Pressed: \(sender.currentTitle ?? "Unknown Item")")
    }
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }

}
