//
//  ProductAddonFormViewController.swift
//  SideMenu2
//
//  Created by FCI on 23/12/24.
//


import UIKit

import Foundation

struct Policy: Codable {
    let policyNo: String
    let proposalNo: String
    let noClaimBonus: Int
    let receiptNo: String
    let receiptDate: String
    let paymentMode: String
    let amount: Int
}

struct RequestBody: Codable {
    let policies: [Policy]
}

class PolicyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet var policyNumberInput: UITextField!
    @IBOutlet var proposalNumberInput: UITextField!
    @IBOutlet var noClaimBonusInput: UITextField!
    @IBOutlet var receiptNumberInput: UITextField!
    @IBOutlet var receiptDateInput: UITextField!
    @IBOutlet var paymentOptionsInput: UITextField!
    @IBOutlet var amountInput: UITextField!
    @IBOutlet var postDetailsButton: UIButton!
    @IBOutlet var updateDetailsButton: UIButton!
    @IBOutlet var deleteDetailsButton: UIButton!
    
    let paymentOptions = ["C","Q","U","D"]   // Payment options (UPI, Card)
    var proposalsList:[String] =  []
    
    var datePicker: UIDatePicker!
    var proposalNumberPicker: UIPickerView!
    var paymentOptionsPicker: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getProposals()
        let toolbar1 = UIToolbar()
        toolbar1.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(showDate))
        toolbar1.setItems([done], animated: true)
        
        datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .inline
        receiptDateInput.inputView = datePicker
        receiptDateInput.inputAccessoryView = toolbar1
        
        let toolbar2 = UIToolbar()
        toolbar2.sizeToFit()
        let done2 = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dismissFunc))
        toolbar2.setItems([done2], animated: true)
        
        // Setup Payment Options Picker for paymentOptionsInput
        paymentOptionsPicker = UIPickerView()
        paymentOptionsPicker.delegate = self
        paymentOptionsPicker.dataSource = self
        paymentOptionsInput.inputView = paymentOptionsPicker
        paymentOptionsInput.inputAccessoryView = toolbar2
        
        // Show proposal number
        proposalNumberPicker = UIPickerView()
        proposalNumberPicker.delegate = self
        proposalNumberPicker.dataSource = self
        proposalNumberInput.inputView = proposalNumberPicker
        proposalNumberInput.inputAccessoryView = toolbar2

    }

    
    // Pickerview Protocl Methods implementation here
    
    // 1. number of components in picker view
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }

    // 2. number of rows in a component
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if pickerView == paymentOptionsPicker {
            return paymentOptions.count
        }else if pickerView == proposalNumberPicker {
            return proposalsList.count
        }
        return 0
    }
    
    //3. display the array info in rows
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == paymentOptionsPicker {
            return paymentOptions[row]
        }else if pickerView == proposalNumberPicker {
            return proposalsList[row]
        }
        return nil
    }
    
    //4. when user select any row in component
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == paymentOptionsPicker {
            paymentOptionsInput.text = paymentOptions[row]
        }else if pickerView == proposalNumberPicker {
            proposalNumberInput.text = proposalsList[row]
        }
        
    }
    func formatDateToISO8601WithMilliseconds(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure the time is in UTC
        return formatter.string(from: date)
    }

    @objc func showDate(){
        view.endEditing(true)
        let formattedDate = formatDateToISO8601WithMilliseconds(datePicker.date)
        receiptDateInput.text = formattedDate

    }
    
    @objc func dismissFunc(){
        view.endEditing(true)
    }
    
    @IBAction func getDetails(){
        
        let url = URL(string: "\(Constants.policyAPI)/api/Policy")! // Replace with your API URL
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        
        print("Completed setting the Request")

        //Perform the API Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                print("\(String(describing: response))")
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
            if let data = data {
                do {
                    
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        
                        
                        
                         for policy in jsonResponse{
                            if let policyID = policy["policyNo"] as? String {
                                print(policyID)
                                DispatchQueue.main.async{
                                    if policyID.trimmingCharacters(in: .whitespacesAndNewlines) == self.policyNumberInput.text! {
                                        print("Found \(policyID) == \(self.policyNumberInput.text!)")
                                        self.proposalNumberInput.text = policy["proposalNo"] as? String
                                        self.noClaimBonusInput.text = "\(policy["noClaimBonus"] as! Double)"
                                        self.receiptNumberInput.text = policy["receiptNo"] as? String
                                        self.receiptDateInput.text = policy["receiptDate"] as? String
                                        self.paymentOptionsInput.text = policy["paymentMode"] as? String
                                        self.amountInput.text = "\(policy["amount"] as! Int)"
                                        
                                    }

                                }
                                
                            }
                            else {
                                    print("proposalID not found for proposal: \(policy)")
                                }
                            
                       }

                    }
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()


    }
    @IBAction func postDetails(){
                
        let policy = validateFields()

        // Encode Request Body into JSON
        guard let jsonData = try? JSONEncoder().encode(policy) else {
            print("Failed to encode request body")
            return
        }
        print("ENCODED REQUEST BODY IN JSON")
    
        
        //Create the URL Request
        let url = URL(string: "\(Constants.policyAPI)/api/Policy/\(Constants.bearerToken)")! // Replace with your API URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        //print("\(requestBody)")
        print(String(data: jsonData, encoding: .utf8)!)
        
        print("Completed setting the Request")
        print("\(jsonData)")
        //Perform the API Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                self.showAlert(title: "Server Error ", message: "Details not saved")
                print("\(String(describing: response))")
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
            self.showAlert(title: "Success ", message: "Details saved")
            
            if let data = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Response: \(jsonResponse)")
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()


    }
    
    func getProposals(){
        
        //Create the URL Request
        let url = URL(string: "\(Constants.proposalAPI)/api/Proposal")! // Replace with your API URL
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")


        //Perform the API Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                print("\(response)")
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
            
            if let data = data {
                do {

                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        print("Response: \(jsonResponse)")
                        for proposal in jsonResponse{
                            if let proposalID = proposal["proposalNo"] as? String {
                                print("Proposal ID: \(proposalID)")
                                self.proposalsList.append(proposalID)
                            }
                            else {
                                    print("proposalID not found for proposal: \(proposal)")
                                }

                       }

                    }
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    @IBAction func putDetails(){

        let policy = validateFields()

        // Encode Request Body into JSON
        guard let jsonData = try? JSONEncoder().encode(policy) else {
            print("Failed to encode request body")
            return
        }
        print("ENCODED REQUEST BODY IN JSON")
    
        
        //Create the URL Request
        let url = URL(string: "\(Constants.policyAPI)/api/Policy/\(policyNumberInput.text!)")! // Replace with your API URL
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        //print("\(requestBody)")
        print(String(data: jsonData, encoding: .utf8)!)
        
        print("Completed setting the Request")
        print("\(jsonData)")
        //Perform the API Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                self.showAlert(title: "Error ", message: "Details not updated")
                print("\(response)")
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
            
            self.showAlert(title: "Success ", message: "Details updated")
            if let data = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Response: \(jsonResponse)")
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()


    }

    @IBAction func deleteDetails(){
        
        let policy = validateFields()

        // Encode Request Body into JSON
        guard let jsonData = try? JSONEncoder().encode(policy) else {
            print("Failed to encode request body")
            return
        }
        print("ENCODED REQUEST BODY IN JSON")
    
        
        //Create the URL Request
        let url = URL(string: "\(Constants.policyAPI)/api/Policy/\(policyNumberInput.text!)")! // Replace with your API URL
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")

        request.httpBody = jsonData
        //print("\(requestBody)")
        print(String(data: jsonData, encoding: .utf8)!)
        
        print("Completed setting the Request")
        print("\(jsonData)")
        //Perform the API Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                self.showAlert(title: "Error", message: "Details not deleted")
                print("\(response)")
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
            self.showAlert(title: "Success", message: "Details deleted")
            
            if let data = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Response: \(jsonResponse)")
                    
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()


    }
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func validateFields() -> Policy? {
        // Check if text fields are filled and valid
        guard let policyNo = policyNumberInput.text, !policyNo.isEmpty else {
            showAlert(title: "Validation Error", message: "Policy number is required.")
            return nil
        }
        
        guard let proposalNo = proposalNumberInput.text, !proposalNo.isEmpty else {
            showAlert(title: "Validation Error", message: "Proposal number is required.")
            return nil
        }
        
        guard let noClaimBonusText = noClaimBonusInput.text, let noClaimBonus = Int(noClaimBonusText) else {
            showAlert(title: "Validation Error", message: "Claim bonus must be a valid number.")
            return nil
        }
        
        guard let receiptNo = receiptNumberInput.text, !receiptNo.isEmpty else {
            showAlert(title: "Validation Error", message: "Receipt number is required.")
            return nil
        }
        
        guard let receiptDate = receiptDateInput.text, !receiptDate.isEmpty else {
            showAlert(title: "Validation Error", message: "Receipt date is required.")
            return nil
        }
        
        guard let paymentMode = paymentOptionsInput.text, !paymentMode.isEmpty else {
            showAlert(title: "Validation Error", message: "Payment mode is required.")
            return nil
        }
        
        guard let amountText = amountInput.text, let amount = Int(amountText) else {
            showAlert(title: "Validation Error", message: "Amount must be a valid number.")
            return nil
        }
        
        // Return Policy object if all validations pass
        return Policy(policyNo: policyNo, proposalNo: proposalNo, noClaimBonus: noClaimBonus, receiptNo: receiptNo, receiptDate: receiptDate, paymentMode: paymentMode, amount: amount)
    }

}

// Prepare the Data

//        let policy = Policy(
//            policyNo: policyNumberInput.text!,
//            proposalNo: proposalNumberInput.text!,
//            noClaimBonus: Int(noClaimBonusInput.text!)!,
//            receiptNo: receiptNumberInput.text!,
//            receiptDate: receiptDateInput.text!,
//            paymentMode: paymentOptionsInput.text!,
//            amount: Int(amountInput.text!)!
//        )
