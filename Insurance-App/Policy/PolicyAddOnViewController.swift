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
        
        // Toolbar for picker views
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissFunc))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        // Set up the UIPickerView for PolicyNo
        pv1 = UIPickerView()
        pv1.delegate = self
        pv1.dataSource = self
        PolicNo.inputView = pv1
        PolicNo.inputAccessoryView = toolbar
        
        // Set up the UIPickerView for AddID
        pv2 = UIPickerView()
        pv2.delegate = self
        pv2.dataSource = self
        AddNo.inputView = pv2
        AddNo.inputAccessoryView = toolbar
        
        // Fetch Policy IDs initially
        fetchPolicyIDs()
        
    }
    
    
    @IBAction func ClickSave(_ sender: UIButton) {
        
        guard let policyNo = PolicNo.text, !policyNo.isEmpty,
              let addNo = AddNo.text, !addNo.isEmpty,
              let amount = Amt.text, !amount.isEmpty else {
            showAlert(title: "Error", message: "All fields must be filled.")
            return
        }

        // Correct URL without the bearer token in the path
        guard let webserviceURL = URL(string: "\(Constants.policyAPI)/api/PolicyAddOn/\(Constants.bearerToken)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }

        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

       
        let policyAddOnDetails: [String: Any] = [
            "AddonID": addNo,
            "PolicyNo": policyNo,
            "Amount": Int(amount) ?? 0
            
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


    
  
    



 
    
    func fetchPolicyIDs() {
        guard let url = URL(string: "\(Constants.policyAPI)/api/Policy") else {
            print("Invalid URL for fetching Policy IDs.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        PolicyNo = []
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching policy IDs: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received while fetching policy IDs.")
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    self.PolicyNo = jsonResponse.compactMap { $0["policyNo"] as? String }
                    print("Fetched PolicyNo array: \(self.PolicyNo)")
                    
                    DispatchQueue.main.async {
                        self.pv1.reloadAllComponents()
                    }
                } else {
                    print("Invalid response format while fetching policy IDs.")
                }
            } catch {
                print("Error parsing policy IDs: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    
    
    func fetchADDONIDs(for policyNo: String) {
        guard let url = URL(string: "\(Constants.policyAPI)/api/PolicyAddOn/ByPolicy/\(policyNo)") else {
            print("Invalid URL for fetching Add-On IDs.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        AddID = []
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching Add-On IDs: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to fetch Add-On IDs: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                print("No data received while fetching Add-On IDs.")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "No data received from server.")
                }
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    self.AddID = jsonResponse.compactMap { $0["addonID"] as? String }
                    print("Fetched AddID array for policy \(policyNo): \(self.AddID)")
                    
                    DispatchQueue.main.async {
                        self.pv2.reloadAllComponents()
                    }
                } else {
                    print("Invalid response format while fetching Add-On IDs.")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Invalid response format from server.")
                    }
                }
            } catch {
                print("Error parsing Add-On IDs: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to parse response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == pv1 ? PolicyNo.count : AddID.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == pv1 ? PolicyNo[row] : AddID[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pv1 {
            guard row < PolicyNo.count else { return }
            PolicNo.text = PolicyNo[row]
            
            // Fetch Add-On IDs for the selected PolicyNo
            fetchADDONIDs(for: PolicyNo[row])
        } else if pickerView == pv2 {
            guard row < AddID.count else { return }
            AddNo.text = AddID[row]
        }
    }
    
    @objc func dismissFunc() {
        view.endEditing(true)
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
