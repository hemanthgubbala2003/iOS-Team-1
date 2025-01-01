//
//  ClaimPageViewController.swift
//  MenuBar
//
//  Created by FCI on 27/12/24.
//Rithik Task

import UIKit

class ClaimPageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet var ClaimNO: UITextField!
    @IBOutlet var ClaimDate: UITextField!
    @IBOutlet var PolciNo: UITextField!
    @IBOutlet var InciDate: UITextField!
    @IBOutlet var InciLoc: UITextField!
    @IBOutlet var InciDes: UITextField!
    @IBOutlet var ClaimAmt: UITextField!
    @IBOutlet var SurvyNam: UITextField!
    @IBOutlet var SurvyPhn: UITextField!
    @IBOutlet var SurvyDate: UITextField!
    @IBOutlet var SurvyDes: UITextField!
    @IBOutlet var ClaimStat: UITextField!
    

    
    @IBOutlet var Save: UIButton!
    @IBOutlet var Update: UIButton!
    @IBOutlet var Delete: UIButton!
    @IBOutlet var GET: UIButton!
    
    var pv1: UIPickerView!
    var ClaimNo: [String] = []
    
    
    var pv2: UIPickerView!
    var PolicyNO: [String] = []
    
    var pv3: UIPickerView!
    var ClaimStatus: [String] = []
    


    
    var dp1: UIDatePicker!
    var df1: DateFormatter!
    
    var dp2: UIDatePicker!
    var df2: DateFormatter!
    
    var dp3: UIDatePicker!
    var df3: DateFormatter!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissFunc))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true

        
       
        
        
        pv1 = UIPickerView()
        pv1.delegate = self
        pv1.dataSource = self
        ClaimNO.inputView = pv1
        ClaimNO.inputAccessoryView = toolbar
        
        pv2 = UIPickerView()
        pv2.delegate = self
        pv2.dataSource = self
        PolciNo.inputView = pv2
        PolciNo.inputAccessoryView = toolbar
        
        ClaimStatus = ["S", "A", "R","T"]
        
       
        pv3 = UIPickerView()
        pv3.delegate = self
        pv3.dataSource = self
        ClaimStat.inputView = pv3
        ClaimStat.inputAccessoryView = toolbar
        

        
     
        dp1 = UIDatePicker()
        dp1.datePickerMode = .date
        dp1.preferredDatePickerStyle = .wheels
        dp1.addTarget(self, action: #selector(dp1Click), for: .valueChanged)
        SurvyDate.inputView = dp1
        SurvyDate.inputAccessoryView = toolbar
        

   
        
        dp2 = UIDatePicker()
        dp2.datePickerMode = .date
        dp2.preferredDatePickerStyle = .wheels
        dp2.addTarget(self, action: #selector(dp2Click), for: .valueChanged)
        ClaimDate.inputView = dp2
        ClaimDate.inputAccessoryView = toolbar

        
        dp3 = UIDatePicker()
        dp3.datePickerMode = .date
        dp3.preferredDatePickerStyle = .wheels
        dp3.addTarget(self, action: #selector(dp3Click), for: .valueChanged)
        InciDate.inputView = dp3
        InciDate.inputAccessoryView = toolbar


        fetchPolicyIDs()
        fetchClaimIDs()
    }
    
    
    @IBAction func ClickSave(_ sender: Any) {
        //let accessToken = claimAPI.bearerToken

        
        guard let Cno = ClaimNO.text, !Cno.isEmpty,
              let CDat = ClaimDate.text, !CDat.isEmpty,
              let PolNo = PolciNo.text, !PolNo.isEmpty,
              let IndDat = InciDate.text, !IndDat.isEmpty,
              let IndLoc = InciLoc.text, !IndLoc.isEmpty,
              let IndDes = InciDes.text, !IndDes.isEmpty,
              let CAmt = ClaimAmt.text, !CAmt.isEmpty,
              let SuryNam = SurvyNam.text, !SuryNam.isEmpty,
              let SuryPhn = SurvyPhn.text, !SuryPhn.isEmpty,
              let SuryDa = SurvyDate.text, !SuryDa.isEmpty,
              let SuryDes = SurvyDes.text, !SuryDes.isEmpty,
              let Cst = ClaimStat.text, !Cst.isEmpty else {
            showAlert(title: "ERROR", message: "Please fill in all fields.")
            return
        }

        guard let webserviceURL = URL(string: "\(Constants.claimAPI)/api/Claim/\(Constants.bearerToken)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let ClaimData: [String: Any] = [
            "claimNo": Cno, // Ensure this is a non-empty string
            "claimDate": CDat, // Must be in ISO 8601 format
            "policyNo": PolNo, // Ensure this is a non-empty string
            "incidentDate": IndDat, // Must be in ISO 8601 format
            "incidentLocation": IndLoc, // Ensure this is a non-empty string
            "incidentDescription": IndDes, // Ensure this is a non-empty string
            "claimAmount": Int(CAmt) ?? 0, // Ensure this is a number and not 0
            "surveyorName": SuryNam, // Ensure this is a non-empty string
            "surveyorPhone": SuryPhn, // Ensure this is a valid phone number string
            "surveyDate": SuryDa, // Must be in ISO 8601 format
            "surveyDescription": SuryDes, // Ensure this is a non-empty string
            "claimStatus": Cst // Ensure this matches accepted status values
        ]


        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ClaimData, options: [])
            request.httpBody = jsonData
        } catch {
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

            guard let httpResponse = response as? HTTPURLResponse else { return }

            if !(200...299).contains(httpResponse.statusCode) {
                if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                    }
                    print("Server Error \(httpResponse.statusCode): \(errorMessage)")
                }
                return
            }

            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Success", message: "Response from server: \(jsonResponse)")
                        }
                    }
                } catch {
                    print("Failed to parse JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }

    
    
    @IBAction func ClickUpdate(_ sender: UIButton) {
        

        
        guard let Cno = ClaimNO.text, !Cno.isEmpty,
              let CDat = ClaimDate.text, !CDat.isEmpty,
              let PolNo = PolciNo.text, !PolNo.isEmpty,
              let IndDat = InciDate.text, !IndDat.isEmpty,
              let IndLoc = InciLoc.text, !IndLoc.isEmpty,
              let IndDes = InciDes.text, !IndDes.isEmpty,
              let CAmt = ClaimAmt.text, !CAmt.isEmpty,
              let SuryNam = SurvyNam.text, !SuryNam.isEmpty,
              let SuryPhn = SurvyPhn.text, !SuryPhn.isEmpty,
              let SuryDa = SurvyDate.text, !SuryDa.isEmpty,
              let SuryDes = SurvyDes.text, !SuryDes.isEmpty,
              let Cst = ClaimStat.text, !Cst.isEmpty else {
            showAlert(title: "Error", message: "Invalid input: All fields must be filled.")
            return
        }
        
        // Attempt to convert ClaimAmount to a numeric value (Decimal or Double)
        guard let claimAmount = Double(CAmt) else {
            showAlert(title: "Error", message: "ClaimAmount must be a valid number.")
            return
        }
        
        guard let webserviceURL = URL(string: "\(Constants.claimAPI)api/Claim/\(Cno)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }

        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "PUT"
        request.setValue("Bearer  \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let claimData: [String: Any] = [
            "ClaimNo": Cno,
            "ClaimDate": CDat,
            "PolicyNo": PolNo,
            "IncidentDate": IndDat,
            "IncidentLocation": IndLoc,
            "IncidentDescription": IndDes,
            "ClaimAmount": claimAmount,
            "SurveyorName": SuryNam,
            "SurveyorPhone": SuryPhn,
            "SurveyDate": SuryDa,
            "SurveyDescription": SuryDes,
            "ClaimStatus": Cst
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: claimData, options: [])
            request.httpBody = jsonData
        } catch {
            print("Failed to serialize JSON: \(error.localizedDescription)")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                print("Request failed: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                    self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                    print("Server Error \(httpResponse.statusCode): \(errorMessage)")
                } else {
                    self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
                    print("Server returned an error: \(httpResponse.statusCode)")
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
                    print("Failed to parse JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }

    
    
    
    @IBAction func ClickDelete(_ sender: UIButton) {
        
   
        
        guard let Cno = ClaimNO.text, !Cno.isEmpty else {
            showAlert(title: "Error", message: "Invalid input: Claim ID must be provided.")
            return
        }
        
        guard let webserviceURL = URL(string: "\(Constants.claimAPI)api/Claim/\(Cno)") else {
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
                        self.showAlert(title: "Success", message: "Claim deleted successfully.")
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

    
    
    
    @IBAction func ClaimDetails(_ sender: UIButton) {
        guard let Cno = ClaimNO?.text, !Cno.isEmpty else {
            showAlert(title: "Error", message: "Claim ID must be filled.")
            return
        }

        guard let webserviceURL = URL(string: "\(Constants.claimAPI)api/Claim/\(Cno)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }

        print("Request URL: \(webserviceURL)")

        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("Authorization Header: \(request.allHTTPHeaderFields?["Authorization"] ?? "No Authorization Header")")

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
                        self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
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
                    DispatchQueue.main.async {
                        self.ClaimDate.text = jsonResponse["claimDate"] as? String ?? "N/A"
                        self.PolciNo.text = jsonResponse["policyNo"] as? String ?? "N/A"
                        self.InciDate.text = jsonResponse["incidentDate"] as? String ?? "N/A"
                        self.InciLoc.text = jsonResponse["incidentLocation"] as? String ?? "N/A"
                        self.InciDes.text = jsonResponse["incidentDescription"] as? String ?? "N/A"
                        self.ClaimAmt.text = "\(jsonResponse["claimAmount"] as? Int ?? 0)"
                        self.SurvyNam.text = jsonResponse["surveyorName"] as? String ?? "N/A"
                        self.SurvyPhn.text = jsonResponse["surveyorPhone"] as? String ?? "N/A"
                        self.SurvyDate.text = jsonResponse["surveyDate"] as? String ?? "N/A"
                        self.SurvyDes.text = jsonResponse["surveyDescription"] as? String ?? "N/A"
                        self.ClaimStat.text = jsonResponse["claimStatus"] as? String ?? "N/A"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Unexpected response format.")
                    }
                }
            } catch {
                DispatchQueue.main.async {
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
    

    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }

    // 2. number of rows in a component
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if pickerView == pv1 {
            return ClaimNo.count
        } else if pickerView == pv2 {
            return PolicyNO.count
        } else {
            return ClaimStatus.count
        }

    }
    
    //3. display the array info in rows
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        if pickerView == pv1 {
            return ClaimNo[row]
        } else if pickerView == pv2 {
            return PolicyNO[row]
        } else {
            return ClaimStatus[row]
        }

    }
    
    //4. when user select any row in component
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pv1 {
            ClaimNO.text = ClaimNo[row]
        } else if pickerView == pv2 {
            PolciNo.text = PolicyNO[row]
        } else {
            ClaimStat.text = ClaimStatus[row]
        }
        
    }

    
    
    
    @objc func dp1Click() {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC time zone

        SurvyDate.text = isoFormatter.string(from: dp1.date)
    }

    
    @objc func dp2Click() {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC time zone

        ClaimDate.text = isoFormatter.string(from: dp2.date)
    }

    
    @objc func dp3Click() {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC time zone

        InciDate.text = isoFormatter.string(from: dp3.date)
    }

    
    @objc func dismissFunc(){
        view.endEditing(true)
    }
    
    
    func fetchClaimIDs() {
        // Correct URL without token in the path
        let url = URL(string: "\(Constants.claimAPI)/api/Claim")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization") // Pass token in header
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
            
            guard let data = data else {
                print("No data received from the server.")
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    var foundClaims = [String]() // Store successfully extracted claim numbers
                    
                    for claim in jsonResponse {
                        if let claimNo = claim["claimNo"] as? String { // Adjust key casing to match API response
                            print("ClaimNo: \(claimNo)")
                            foundClaims.append(claimNo)
                        } else {
                            print("ClaimID not found for product: \(claim)")
                        }
                    }
                    
                   
                    DispatchQueue.main.async {
                        self.ClaimNo = foundClaims // Assuming `ClaimNo` is a class property
                        print("Fetched Claim Numbers: \(self.ClaimNo)")
                    }
                } else {
                    print("Unexpected JSON structure.")
                }
            } catch {
                print("Failed to decode response: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    
    
    func fetchPolicyIDs() {

        
        let url = URL(string: "\(Constants.policyAPI)/api/Policy")! // Replace with your API URL

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer  \(Constants.bearerToken)", forHTTPHeaderField: "Authorization") // Pass token in header
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        self.PolicyNO = []

        
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
                print("Response Data String: \(responseString)") // Print raw response for debugging
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        print("JSON Response: \(jsonResponse)")  // Log the full response JSON
                        
                        for policy in jsonResponse {
                            if let policyNo = policy["policyNo"] as? String {
                                let trimmedPolicyNo = policyNo.trimmingCharacters(in: .whitespaces)
                                print("Policy No: \(trimmedPolicyNo)")
                                self.PolicyNO.append(trimmedPolicyNo)  // Append to the ProposalID array
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
    

    
}

