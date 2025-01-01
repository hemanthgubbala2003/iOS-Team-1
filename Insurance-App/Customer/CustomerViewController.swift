//
//  CustomerViewController.swift
//  MenuBar
//
//  Created by FCI on 26/12/24.
//

import UIKit

class CustomerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var CustID: UITextField!
    @IBOutlet var CustNam: UITextField!
    @IBOutlet var CustPhn: UITextField!
    @IBOutlet var CustEmail: UITextField!
    @IBOutlet var CustAdd: UITextField!
    
    @IBOutlet var Save: UIButton!
    @IBOutlet var Update: UIButton!
    @IBOutlet var Delete: UIButton!
    @IBOutlet var GET: UIButton!
    
    
    var pv1: UIPickerView!
    var CustomerID: [String] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fetchCustomerIDs()
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dismissFunc))
        toolbar.setItems([done], animated: true)
        
       
        pv1 = UIPickerView()
        pv1.delegate = self
        pv1.dataSource = self
        CustID.inputView = pv1
        CustID.inputAccessoryView = toolbar
    }
    

    @IBAction func ClickSave(_ sender: Any) {
        

        
        
        guard let ID = CustID.text, !ID.isEmpty,
              let Name = CustNam.text, !Name.isEmpty,
              let Phone = CustPhn.text, !Phone.isEmpty,
              let Email = CustEmail.text, !Email.isEmpty,
              let Address = CustAdd.text, !Address.isEmpty else {
            showAlert(title: "Error", message: "Invalid input: All fields must be filled.")
            return
        }
        
        guard let webserviceURL = URL(string: "\(Constants.customerAPI)/api/Customer/\(Constants.bearerToken)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }
        

        
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        
        let customerData: [String: Any] = [
            "CustomerID": ID,
            "CustomerName": Name,
            "CustomerPhone": Phone,
            "CustomerEmail": Email,
            "CustomerAddress": Address
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: customerData, options: [])
            request.httpBody = jsonData
        } catch {
            showAlert(title: "Error", message: "Failed to serialize JSON: \(error.localizedDescription)")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                    self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                } else {
                    self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
                }
                return
            }
       
            
            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        self.showAlert(title: "Success", message: "Response from server: \(jsonResponse)")
                    }
                } catch {
                    self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    
    
    
    
    
    @IBAction func ClickUpdate(_ sender: Any) {
        

        
        guard let ID = CustID.text, !ID.isEmpty,
              let Name = CustNam.text, !Name.isEmpty,
              let Phone = CustPhn.text, !Phone.isEmpty,
              let Email = CustEmail.text, !Email.isEmpty,
              let Address = CustAdd.text, !Address.isEmpty else {
            showAlert(title: "Error", message: "Invalid input: All fields must be filled.")
            return
        }
        
        guard let webserviceURL = URL(string: "\(Constants.customerAPI)/api/Customer/\(ID)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }
        

        
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        
        let customerData: [String: Any] = [
            "CustomerID": ID,
            "CustomerName": Name,
            "CustomerPhone": Phone,
            "CustomerEmail": Email,
            "CustomerAddress": Address
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: customerData, options: [])
            request.httpBody = jsonData
        } catch {
            showAlert(title: "Error", message: "Failed to serialize JSON: \(error.localizedDescription)")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                    self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                } else {
                    self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
                }
                return
            }
            
            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        self.showAlert(title: "Success", message: "Response from server: \(jsonResponse)")
                    }
                } catch {
                    self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    
    
    
    
    
    
    @IBAction func ClickDelete(_ sender: Any) {
        
   
        
        guard let ID = CustID.text, !ID.isEmpty else {
            showAlert(title: "Error", message: "Invalid input: Customer ID must be provided.")
            return
        }
        
        guard let webserviceURL = URL(string: "\(Constants.customerAPI)/api/Customer/\(ID)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }
        

        
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Success", message: "Customer deleted successfully.")
                    }
                } else {
                    if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                        self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                    } else {
                        self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
                    }
                }
            }
        }
        task.resume()
    }
    
    
    @IBAction func ClickGet(_ sender: UIButton) {


        // Validate Customer ID
        guard let ID = CustID.text, !ID.isEmpty else {
            showAlert(title: "Error", message: "Customer ID must be filled.")
            return
        }

        // Construct the correct URL
        guard let webserviceURL = URL(string: "\(Constants.customerAPI)/api/Customer/\(ID)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }

        // Debug print the URL
        print("Request URL: \(webserviceURL)")

        // Create the GET request
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "GET"
        
        // Ensure the authorization header is set correctly
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Debug print the headers to ensure token is being passed
        print("Authorization Header: \(request.allHTTPHeaderFields?["Authorization"] ?? "No Authorization Header")")

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            // Handle connection errors
            if let error = error {
                self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                return
            }

            // Handle HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")

                if !(200...299).contains(httpResponse.statusCode) {
                    if httpResponse.statusCode == 401 {
                        self.showAlert(title: "Error", message: "Unauthorized: Check your access token.")
                    } else if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                        self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                    } else {
                        self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
                    }
                    return
                }
            }

            // Handle response data
            guard let data = data else {
                self.showAlert(title: "Error", message: "No data received from server.")
                return
            }

            // Parse JSON response
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Response from server: \(jsonResponse)")

                    // Update the UI with fetched data
                    DispatchQueue.main.async {
                        self.CustNam.text = jsonResponse["customerName"] as? String ?? "N/A"
                        self.CustPhn.text = jsonResponse["customerPhone"] as? String ?? "N/A"
                        self.CustEmail.text = jsonResponse["customerEmail"] as? String ?? "N/A"
                        self.CustAdd.text = jsonResponse["customerAddress"] as? String ?? "N/A"
                    }
                } else {
                    self.showAlert(title: "Error", message: "Unexpected response format.")
                }
            } catch {
                self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
        
    }
  
    
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    
    
    
    func fetchCustomerIDs() {

        
        
        let url = URL(string: "\(Constants.customerAPI)/api/Customer")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization") 
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Perform the API request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Failed to get HTTP response.")
                return
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode) {
                print("Server error with status code: \(httpResponse.statusCode)")
                if let data = data {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response data as String"
                    print("Response Data String: \(responseString)")
                }
                return
            }
            
            if let data = data {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response data as String"
                print("Response Data String: \(responseString)")
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        for customer in jsonResponse {
                            if let customerID = customer["customerID"] as? String {
                                print("CustomerID: \(customerID)")
                                // Assuming self.CustomerID exists as an array property
                                self.CustomerID.append(customerID)
                            } else {
                                print("CustomerID not found for product: \(customer)")
                            }
                        }
                    } else {
                        print("Unexpected JSON structure.")
                    }
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }

    
    
    // Pickerview Protocl Methods implementation here
    
    // 1. number of components in picker view
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }

    // 2. number of rows in a component
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if pickerView == pv1 {
            return CustomerID.count
        }
        return 0
    }
    
    //3. display the array info in rows
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pv1 {
            return CustomerID[row]
        }
        return nil
    }
    
    //4. when user select any row in component
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pv1 {
            CustID.text = CustomerID[row]
        }
        
    }

    @objc func dismissFunc(){
        view.endEditing(true)
    }
}



