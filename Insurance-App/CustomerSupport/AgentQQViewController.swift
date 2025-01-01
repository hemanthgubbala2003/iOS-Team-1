//
//  AgentQQViewController.swift
//  Support
//
//  Created by FCI-2199 on 30/12/24.
//

    import UIKit

    class AgentQQViewController: UIViewController {
        
        @IBOutlet var queryID: UITextField!
        @IBOutlet var srNo: UITextField!
        @IBOutlet var descript: UITextField!
        @IBOutlet var responseDate: UITextField!
        @IBOutlet var agentID: UITextField!
        
        var qid: String?
        var sno: String?
        var des: String?
        var qdate: String?
        var AID: String?
        
        var dp1: UIDatePicker!
        var df1: DateFormatter!
        @IBOutlet var save: UIButton!
       // @IBOutlet var update: UIButton!
        //@IBOutlet var delete: UIButton!
        @IBOutlet var get: UIButton!
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            dp1 = UIDatePicker()
            dp1.datePickerMode = .date
            dp1.preferredDatePickerStyle = .wheels
            dp1.addTarget(self, action: #selector(dp1Click), for: .valueChanged)
            responseDate.inputView = dp1
        }

        
        @IBAction func clickSave(_ sender: UIButton) {
     
            guard let QID = queryID.text, !QID.isEmpty,
                  let SNO = srNo.text, !SNO.isEmpty,
                  let DES = descript.text, !DES.isEmpty,
                  let QDATE = responseDate.text, !QDATE.isEmpty,
                  let ADI = agentID.text, !ADI.isEmpty else {
                print("Invalid input: All fields must be filled.")
                return
            }
            
            guard let webserviceURL = URL(string: "\(Constants.queryAPI)/api/QueryResponse/\(Constants.bearerToken)") else {
                print("Invalid URL")
                return
            }
            
            var request = URLRequest(url: webserviceURL)
            request.httpMethod = "POST"
            request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let queryinfo: [String: Any] = [
                "queryID": QID,
                "srNo": SNO,
                "description": DES,
                "responseDate": QDATE,
                "agentID": ADI
            ]
            

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: queryinfo, options: [])
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
                    print("HTTP Status: \(httpResponse)")
                    if !(200...299).contains(httpResponse.statusCode) {
                        if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                            self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                            print("\(errorMessage)")
                        } else {
                            self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
                        }
                        return
                    }
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
                if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                    print("Server Response: \(errorMessage)")
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
        

        
        
        @IBAction func clickGet(_ sender: UIButton) {
            
            
            guard let QID = queryID.text,!QID.isEmpty,let SNO = srNo.text,!SNO.isEmpty else {
                print("Invalid input: Product ID must be filled.")
                return
            }
            
            // Construct the URL
            guard let webserviceURL = URL(string: "\(Constants.queryAPI)/api/QueryResponse/\(QID)/\(SNO)") else {
                print("Invalid URL")
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
                    print("HTTP Status: \(httpResponse)")

                    if !(200...299).contains(httpResponse.statusCode) {
                        if httpResponse.statusCode == 401 {
                            self.showAlert(title: "Error", message: "Unauthorized: Check your access token.")
                        } else if let data = data, let errorMessage = String(data: data, encoding: .utf8)
                        {
                            self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                            print("\(errorMessage)")
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
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                            print("Response from server: \(jsonResponse)")
                            DispatchQueue.main.async {
    //                             Safely unwrap and update the UI with the fetched data
                                self.queryID.text = jsonResponse["queryID"] as? String ?? "N/A"
                                self.srNo.text = jsonResponse["srNo"] as? String ?? "N/A"
                                self.descript.text = jsonResponse["description"] as? String ?? "N/A"
                                self.responseDate.text = jsonResponse["responseDate"] as? String ?? "N/A"
                                self.agentID.text = jsonResponse["agentID"] as? String ?? "N/A"
                                
                                
                                
                                
                            }
                            
                        }

    //                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
    //                        print("Response from server: \(jsonResponse)")
    //                        DispatchQueue.main.async {
    //                            // Safely unwrap and update the UI with the fetched data
    //                            self.queryID.text = jsonResponse["QueryID"] as? String ?? "N/A"
    //                            self.custID.text = jsonResponse["CustomerID"] as? String ?? "N/A"
    //                            self.descript.text = jsonResponse["Description"] as? String ?? "N/A"
    //                            self.queryDate.text = jsonResponse["QueryDate"] as? String ?? "N/A"
    //                            self.status.text = jsonResponse["Status"] as? String ?? "N/A"
    //
    //
    //
    //                        }
                        
                    } catch {
                        DispatchQueue.main.async {
                            print("Failed to parse JSON: \(error.localizedDescription)")
                        }
                    }
                
            }
            task.resume()
        }
        @objc func dp1Click() {
                let dateFormatter = DateFormatter()
                 dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS" // ISO 8601 format with milliseconds

                 // Convert the selected date into the formatted string
                 let formattedDate = dateFormatter.string(from: dp1.date)

                 // Set the formatted date string to the regDate text field
                 responseDate.text = formattedDate
            }
    }


