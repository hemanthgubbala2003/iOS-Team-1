//
//  RegisterViewController.swift
//  05-Login-Module
//
//  Created by FCI on 29/12/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


class RegisterViewController: UIViewController {

    @IBOutlet weak var customerIdTextfield: UITextField!
    @IBOutlet weak var customerNameTextfield: UITextField!
    @IBOutlet weak var customerPhoneTextfield: UITextField!
    @IBOutlet weak var customerAddressTextfield: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    
    var email:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        emailLabel.text = email
    }
    @IBAction func postDetails(){
        
        // Prepare the Data
        
        Customer.customer = Customer(
            customerID: customerIdTextfield.text!,
            customerName: customerNameTextfield.text!,
            customerPhone: customerPhoneTextfield.text!,
            customerEmail: emailLabel.text!,
            customerAddress: customerAddressTextfield.text!
        )
                
        let url = "\(Constants.customerAPI)/api/Customer/\(Constants.bearerToken)"
        
        httpRequestAndResponse(
            requestBody: Customer.customer,
            urlString:url,
            HttpMethod: "POST"
        )


    }
    
    func httpRequestAndResponse(requestBody : Codable, urlString: String, HttpMethod: String){
        // Encode Request Body into JSON
        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            print("Failed to encode request body")
            return
        }
        print("ENCODED REQUEST BODY IN JSON")

        //Create the URL Request
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        // Set http Method, headers and encoded body
        request.httpMethod = HttpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        //Check the Json request body here
        print("Completed setting the Request")
        print(String(data: jsonData, encoding: .utf8)!)

        //Perform the API Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            // Prints the response when there is an http error code
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                if let data = data {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        print("Response: \(jsonResponse)")
                    } catch {
                        print("Failed to decode response: \(error.localizedDescription)")
                    }
                }
                return
            }
            print("Getting the Response")
            
            // Prints the response on Success
            if let data = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Response: \(jsonResponse)")
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: Constants.registerSegue, sender: self)
                    }


                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    
    
}
