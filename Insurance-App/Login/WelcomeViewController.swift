//
//  WelcomeViewController.swift
//  05-Login-Module
//
//  Created by FCI on 29/12/24.



import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class WelcomeViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    var email:String?
    @IBOutlet var img: UIImageView!
    @IBOutlet var cntrl: UIPageControl!
    @IBOutlet var product: UIButton!
    var timer: Timer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
//        label.text = Customer.customer?.customerID
        
        //Customer.getCustomers(customerEmail: email!)
        //label.text = Customer.customer.customerID
        cntrl.numberOfPages = 4 // Adjust based on your images
        cntrl.currentPage = 0
        
        // Start the automatic page control timer
        startAutomaticPageControl()
        
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
                    self.label.text = "CID: \(customer.customerID)"
                    
                } else {
                    print("Customer not found")
                }
            }
        } else {
            print("No user is logged in.")
        }



    }
    func startAutomaticPageControl() {
        // Invalidate any existing timer before starting a new one
        timer?.invalidate()
        
        // Create a new timer to update the page every 0.3 seconds
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(updatePageControl), userInfo: nil, repeats: true)
    }
    @objc func updatePageControl() {
        // Move to the next page, or loop back to the first page when reaching the last
        if cntrl.currentPage < cntrl.numberOfPages - 1 {
            cntrl.currentPage += 1
        } else {
            cntrl.currentPage = 0
        }
        
        // Update the background color and image based on the current page
        updateImageAndBackground(for: cntrl.currentPage)
    }

    // Function to update the image and background color
    func updateImageAndBackground(for page: Int) {
        switch page {
        case 0:
            self.view.backgroundColor = UIColor.red
            img.image = UIImage(named: "ins1")
        case 1:
            self.view.backgroundColor = UIColor.yellow
            img.image = UIImage(named: "ins2")
        case 2:
            self.view.backgroundColor = UIColor.blue
            img.image = UIImage(named: "ins3")
        case 3:
            self.view.backgroundColor = UIColor.brown
            img.image = UIImage(named: "ins4")

        default:
            break
        }
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
