//
//  AgentViewController.swift
//  MenuBar
//
//  Created by FCI on 26/12/24.
//rithik Task

import UIKit

class AgentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet var AgntID: UITextField!
    @IBOutlet var AgntNam: UITextField!
    @IBOutlet var AgntPhn: UITextField!
    @IBOutlet var AgntEmail: UITextField!
    @IBOutlet var LicenCod: UITextField!
    
    @IBOutlet var Save: UIButton!
    @IBOutlet var Update: UIButton!
    @IBOutlet var Delete: UIButton!
    @IBOutlet var GET: UIButton!
    
    
    var pv1: UIPickerView!
    var AgentID: [String] = []
    
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
        AgntID.inputView = pv1
        AgntID.inputAccessoryView = toolbar
        
        
        fetchagentIDs()
    }
    

    @IBAction func ClickSave(_ sender: UIButton) {
        


        guard let ID = AgntID.text, !ID.isEmpty,
              let Name = AgntNam.text, !Name.isEmpty,
              let Phone = AgntPhn.text, !Phone.isEmpty,
              let Email = AgntEmail.text, !Email.isEmpty,
              let Lisence = LicenCod.text, !Lisence.isEmpty  else {
            showAlert(title: "Error", message: "All fields must be filled.")
            return
        }

     
        guard let webserviceURL = URL(string: "\(Constants.agentAPI)/api/Agent/\(Constants.bearerToken)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }

        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Updated payload with expected field names
        let agentData: [String: Any] = [
            "AgentID": ID,
            "AgentName": Name,
            "AgentPhone": Phone,
            "AgentEmail": Email,
            "LicenseCode": Lisence  // Corrected spelling
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: agentData, options: [])
            request.httpBody = jsonData
        } catch {
            showAlert(title: "Error", message: "Failed to serialize JSON: \(error.localizedDescription)")
            print("Failed to serialize JSON: \(error.localizedDescription)")
            return
        }

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                }
                print("Request failed: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                    }
                    print("Server Error \(httpResponse.statusCode): \(errorMessage)")
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
                    }
                    print("Server Error \(httpResponse.statusCode)")
                }
                return
            }

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
    

    @IBAction func ClickUpadte(_ sender: UIButton) {
        

        guard let ID = AgntID.text, !ID.isEmpty,
              let Name = AgntNam.text, !Name.isEmpty,
              let Phone = AgntPhn.text, !Phone.isEmpty,
              let Email = AgntEmail.text, !Email.isEmpty,
              let Lisence = LicenCod.text, !Lisence.isEmpty else {
            showAlert(title: "Error", message: "Invalid input: All fields must be filled.")
            return
        }
        
        
        guard let webserviceURL = URL(string: "\(Constants.agentAPI)/api/Agent/\(ID)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }
        
        
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
       
        let agentData: [String: Any] = [
            "AgentID": ID,
            "AgentName": Name,
            "AgentPhone": Phone,
            "AgentEmail": Email,
            "LicenseCode": Lisence  // Corrected spelling
        ]

        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: agentData, options: [])
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
            
     
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                        self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                        return
                    } else {
                        self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
                        return
                    }
                }
            }
            
            // Parse response data
            if let data = data {
                // Try to parse as JSON
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Success", message: "Response from server: \(jsonResponse)")
                        }
                        print("Response from server: \(jsonResponse)")
                    } else {
                        // Handle unexpected format
                        if let responseString = String(data: data, encoding: .utf8) {
                            DispatchQueue.main.async {
                                self.showAlert(title: "Error", message: "Unexpected response format. Raw response: \(responseString)")
                            }
                            print("Unexpected response format. Raw response: \(responseString)")
                        }
                    }
                } catch {
                    // Fallback to raw response
                    if let responseString = String(data: data, encoding: .utf8) {
                        self.showAlert(title: "Error", message: "Failed to parse JSON. Raw response: \(responseString)")
                        print("Failed to parse JSON. Raw response: \(responseString)")
                    } else {
                        self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                        print("Failed to parse JSON: \(error.localizedDescription)")
                    }
                }
            }
        }
        task.resume()
    }
    
    @IBAction func Delete(_ sender: UIButton) {
        

        
        guard let ID = AgntID.text, !ID.isEmpty else {
            showAlert(title: "Error", message: "Invalid input: Product ID must be provided.")
            return
        }
        
        guard let webserviceURL = URL(string: "\(Constants.agentAPI)/api/Agent/\(ID)") else {
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
                        self.showAlert(title: "Success", message: "Product deleted successfully.")
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
        
 
        guard let ID = AgntID.text, !ID.isEmpty else {
            showAlert(title: "Error", message: "Registration Number must be filled.")
            return
        }
        

        guard let webserviceURL = URL(string: "\(Constants.agentAPI)/api/Agent/\(ID)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "GET" // Use GET if the API requires it
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Log the request details
        print("Request URL: \(webserviceURL)")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                        self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                    } else {
                        self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
                    }
                    return
                }
            }
            
            guard let data = data else {
                self.showAlert(title: "Error", message: "No data received from server.")
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Response from server: \(jsonResponse)")
                    
                    DispatchQueue.main.async {
                        // Populate UI fields with the retrieved data
                        self.AgntNam.text = jsonResponse["agentName"] as? String ?? "N/A"
                        self.AgntPhn.text = jsonResponse["agentPhone"] as? String ?? "N/A"
                        self.AgntEmail.text = jsonResponse["agentEmail"] as? String ?? "N/A"
                        self.LicenCod.text = jsonResponse["licenseCode"] as? String ?? "N/A"
                    }

                } else {
                    if let responseString = String(data: data, encoding: .utf8) {
                        self.showAlert(title: "Error", message: "Unexpected response format: \(responseString)")
                    } else {
                        self.showAlert(title: "Error", message: "Unexpected response format.")
                    }
                }
            } catch {
                if let responseString = String(data: data, encoding: .utf8) {
                    self.showAlert(title: "Error", message: "Failed to parse JSON. Raw response: \(responseString)")
                } else {
                    self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                }
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
    
    @objc func dismissFunc(){
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return AgentID.count
        
    

    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        guard row < AgentID.count else { return nil }  // Check index bounds
        return AgentID[row]
        


    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pv1 {
            guard row < AgentID.count else { return }  // Check index bounds
            AgntID.text = AgentID[row]
            
        }
    }
    
    
    
    
    func fetchagentIDs() {

        
     
        let url = URL(string: "\(Constants.agentAPI)/api/Agent")!

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
                        for agent in jsonResponse {
                            if let agentID = agent["agentID"] as? String {
                                let trimmedAgentID = agentID.trimmingCharacters(in: .whitespacesAndNewlines)
                                print("agentID: \(trimmedAgentID)")
                                
                                
                                self.AgentID.append(trimmedAgentID)
                            } else {
                                print("agentID not found for agent: \(agent)")
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

}
