//
//  PolicyAddOnViewController.swift
//  MenuBar
//
//  Created by FCI on 27/12/24.
//

import UIKit

class PolicyAddOnViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    
    @IBOutlet var PolicNo: UITextField!
    @IBOutlet var AddNo: UITextField!
    @IBOutlet var Amt: UITextField!
    
    
    
    @IBOutlet var Save: UIButton!
    @IBOutlet var Update: UIButton!
    @IBOutlet var Delete: UIButton!
    @IBOutlet var GET: UIButton!
    
    
    var pv1: UIPickerView!
    var PolicyNo: [String] = []
    
    var pv2: UIPickerView!
    var AddID: [String] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissFunc))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
    
        // Set up the UIPickerView for ClaimStatus
        pv1 = UIPickerView()
        pv1.delegate = self
        pv1.dataSource = self
        PolicNo.inputView = pv1
        PolicNo.inputAccessoryView = toolbar
        
       
        
        pv2 = UIPickerView()
        pv2.delegate = self
        pv2.dataSource = self
        AddNo.inputView = pv2
        AddNo.inputAccessoryView = toolbar
        
        fetchPolicyIDs()
        
        fetchADDONIDs()
    }
    

    
    @IBAction func ClickSave(_ sender: UIButton) {
        guard let policyNo = PolicNo.text?.trimmingCharacters(in: .whitespacesAndNewlines), !policyNo.isEmpty,
              let addNo = AddNo.text?.trimmingCharacters(in: .whitespacesAndNewlines), !addNo.isEmpty,
              let amount = Amt.text?.trimmingCharacters(in: .whitespacesAndNewlines), !amount.isEmpty else {
            showAlert(title: "Error", message: "All fields must be filled.")
            return
        }

        // Correct URL without the bearer token in the path
        guard let webserviceURL = URL(string: "\(Constants.policyAPI)/api/PolicyAddOn") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }

        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

       
        let policyAddOnDetails: [String: Any] = [
            "AddonID": addNo,
            "Amount": Int(amount) ?? 0,
            "PolicyNo": policyNo
        ]

        // Convert payload to JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: policyAddOnDetails, options: [])
            request.httpBody = jsonData
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Request Body: \(jsonString)")
            }
        } catch {
            showAlert(title: "Error", message: "Failed to serialize JSON: \(error.localizedDescription)")
            print("Failed to serialize JSON: \(error.localizedDescription)")
            return
        }

        // Send the request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                }
                print("Request failed: \(error.localizedDescription)")
                return
            }

            // Check for valid HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    let errorMessage = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                    }
                    print("Server Error \(httpResponse.statusCode): \(errorMessage)")
                    return
                }
            }

            // Handle response data
            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Success", message: "Response from server: \(jsonResponse)")
                        }
                        print("Response from server: \(jsonResponse)")
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                    }
                    print("Failed to parse JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }

    
    
    @IBAction func ClickUpdate(_ sender: UIButton) {
        guard let policyNo = PolicNo.text?.trimmingCharacters(in: .whitespacesAndNewlines), !policyNo.isEmpty,
              let addNo = AddNo.text?.trimmingCharacters(in: .whitespacesAndNewlines), !addNo.isEmpty,
              let amount = Amt.text?.trimmingCharacters(in: .whitespacesAndNewlines), !amount.isEmpty else {
            showAlert(title: "Error", message: "All fields must be filled.")
            return
        }
        
        guard let webserviceURL = URL(string: "\(Constants.policyAPI)/api/PolicyAddOn/\(policyNo)/\(addNo)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Construct the payload
        let policyAddOnDetails: [String: Any] = [
            "PolicyNo": policyNo,   // Corrected field name
            "AddonID": addNo,       // Corrected field name
            "Amount": Int(amount) ?? 0 // Assuming the amount is numeric
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: policyAddOnDetails, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Request Body: \(jsonString)")
            }
            request.httpBody = jsonData
        } catch {
            showAlert(title: "Error", message: "Failed to serialize JSON: \(error.localizedDescription)")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                        }
                        print("Server Error: \(errorMessage)")
                    }
                    return
                }
            }
            
            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Success", message: "Update successful: \(jsonResponse)")
                        }
                        print("Response from server: \(jsonResponse)")
                    } else {
                        if let responseString = String(data: data, encoding: .utf8) {
                            DispatchQueue.main.async {
                                self.showAlert(title: "Error", message: "Unexpected response format. Raw response: \(responseString)")
                            }
                            print("Unexpected response format. Raw response: \(responseString)")
                        }
                    }
                } catch {
                    if let responseString = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Error", message: "Failed to parse JSON. Raw response: \(responseString)")
                        }
                        print("Failed to parse JSON. Raw response: \(responseString)")
                    }
                }
            }
        }
        task.resume()
    }


    
    
    @IBAction func ClickDelete(_ sender: UIButton) {
        
        guard let policyNo = PolicNo.text?.trimmingCharacters(in: .whitespacesAndNewlines), !policyNo.isEmpty,
              let addNo = AddNo.text?.trimmingCharacters(in: .whitespacesAndNewlines), !addNo.isEmpty else {
            showAlert(title: "Error", message: "Policy No and AddNo must be provided.")
            return
        }

        
        guard let webserviceURL = URL(string: "\(Constants.policyAPI)/api/PolicyAddOn/\(policyNo)/\(addNo)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }

     
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Execute the request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                }
                print("Request failed: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if (200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Success", message: "Policy deleted successfully.")
                    }
                } else {
                    let errorMessage = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Failed to delete policy. Status Code: \(httpResponse.statusCode). Error: \(errorMessage)")
                    }
                    print("Failed to delete policy. Status Code: \(httpResponse.statusCode). Error: \(errorMessage)")
                }
            }
        }
        task.resume()
    }
    
    
    
    @IBAction func ClickGet(_ sender: UIButton) {
        guard let policyNo = PolicNo.text?.trimmingCharacters(in: .whitespacesAndNewlines), !policyNo.isEmpty,
              let addNo = AddNo.text?.trimmingCharacters(in: .whitespacesAndNewlines), !addNo.isEmpty else {
            showAlert(title: "Error", message: "Policy Number and Add-on Number must be filled.")
            return
        }
        
        guard let webserviceURL = URL(string: "\(Constants.policyAPI)/api/PolicyAddOn/\(policyNo)/\(addNo)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Request URL: \(webserviceURL)")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                            self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                        } else {
                            self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
                        }
                    }
                    return
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "No data received from server.")
                }
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Raw JSON Response: \(jsonResponse)")
                    
                    let policyNo = (jsonResponse["policyNo"] as? String)?.trimmingCharacters(in: .whitespaces) ?? "N/A"
                    let addonID = (jsonResponse["addonID"] as? Int).map { String($0) } ?? (jsonResponse["addonID"] as? String) ?? "N/A"
                    let amount = (jsonResponse["amount"] as? Int).map { String($0) } ?? "N/A"
                    
                    print("Parsed PolicyNo: \(policyNo)")
                    print("Parsed AddonID: \(addonID)")
                    print("Parsed Amount: \(amount)")
                    
                    DispatchQueue.main.async {
                        self.PolicNo.text = policyNo
                        self.AddNo.text = addonID
                        self.Amt.text = amount
                    }
                } else {
                    DispatchQueue.main.async {
                        if let responseString = String(data: data, encoding: .utf8) {
                            self.showAlert(title: "Error", message: "Unexpected response format: \(responseString)")
                        } else {
                            self.showAlert(title: "Error", message: "Unexpected response format.")
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    if let responseString = String(data: data, encoding: .utf8) {
                        self.showAlert(title: "Error", message: "Failed to parse JSON. Raw response: \(responseString)")
                    } else {
                        self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                    }
                }
            }
        }
        task.resume()
    }


    
    func fetchPolicyIDs() {

        
        let url = URL(string: "\(Constants.policyAPI)/api/Policy")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization") // Pass token in header
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        self.PolicyNo = []

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
                        print("JSON Response: \(jsonResponse)")
                        
                        for policy in jsonResponse {
                            if let policyNo = policy["policyNo"] as? String {
                                let trimmedPolicyNo = policyNo.trimmingCharacters(in: .whitespaces)
                                print("Policy No: \(trimmedPolicyNo)")
                                self.PolicyNo.append(trimmedPolicyNo)
                            } else {
                                print("policyNo not found for policy: \(policy)")
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
    

    
    
    func fetchADDONIDs() {
        
        
        
        // URL for the API
        guard let url = URL(string: "\(Constants.policyAPI)/api/PolicyAddOn") else {
            print("Invalid URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
         
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Failed to get HTTP response.")
                return
            }
          
            if !(200...299).contains(httpResponse.statusCode) {
                print("Server error with status code: \(httpResponse.statusCode)")
                return
            }
            
            
            if let data = data {
                do {
                    
                    if let rawResponse = String(data: data, encoding: .utf8) {
                        print("Raw API Response: \(rawResponse)")
                    }
                    
                
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        var fetchedAddIDs = [String]()
                        for add in jsonResponse {
                            if let addonID = add["addonID"] as? String { // Use "addonID" instead of "AddID"
                                fetchedAddIDs.append(addonID.trimmingCharacters(in: .whitespaces)) // Trim whitespaces
                            }
                        }
                        
                        
                        print("Fetched AddOn IDs: \(fetchedAddIDs)")
                        
                  
                        DispatchQueue.main.async {
                            self.AddID = fetchedAddIDs
                            self.pv2.reloadAllComponents()
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
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Single component in each picker
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pv1 {
            return PolicyNo.count
        } else if pickerView == pv2  {
            return AddID.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pv1 {
            return PolicyNo[row]
        } else if pickerView == pv2 {
            return AddID[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pv1 {
            PolicNo.text = PolicyNo[row]
        } else if pickerView == pv2  {
            AddNo.text = AddID[row]
        }
    }
    
    
    
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    
    
    @objc func dismissFunc(){
        view.endEditing(true)
    }

}
