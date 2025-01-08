//
//  ProductAddonFormViewController.swift
//  SideMenu2
//
//  Created by FCI on 23/12/24.
//

import UIKit
import Foundation

struct Proposal: Codable {
    let proposalNo: String
    let regNo: String
    let productId: String
    let customerId: String
    let fromDate: String
    let toDate: String
    let idv: Int
    let agentId: String
    let basicAmount: Int
    let totalAmount: Int
}

struct RequestBody2: Codable {
    let proposals: [Proposal]
}

class ProposalViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet var proposalIdInput: UITextField!
    @IBOutlet var registrationNumberInput: UITextField!
    @IBOutlet var productIdInput: UITextField!
    @IBOutlet var customerIdInput: UITextField!
    @IBOutlet var fromDateInput: UITextField!
    @IBOutlet var toDateInput: UITextField!
    @IBOutlet var IDVInput: UITextField!
    @IBOutlet var agentIdInput: UITextField!
    @IBOutlet var basicAmountInput: UITextField!
    @IBOutlet var totalAmountInput: UITextField!
    
    @IBOutlet var postDetailsButton: UIButton!
    @IBOutlet var updateDetailsButton: UIButton!
    @IBOutlet var deleteDetailsButton: UIButton!
    
    var datePicker: UIDatePicker!
    var activeDateField: UITextField?
    var vehiclePicker: UIPickerView!
    var productPicker: UIPickerView!
    var agentPicker: UIPickerView!
    var customerPicker: UIPickerView!
    
    var vehiclesList:[String] =  []
    var productsList:[String] =  []
    var agentsList:[String] =  []
    var customersList:[String] =  []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getVehicles()
        getProducts()
        getAgents()
        getCustomers()
        setupDatePickers()
        
        let toolbar2 = UIToolbar()
        toolbar2.sizeToFit()
        let done2 = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dismissFunc))
        toolbar2.setItems([done2], animated: true)
        
        // Show vehicle
        vehiclePicker = UIPickerView()
        vehiclePicker.delegate = self
        vehiclePicker.dataSource = self
        registrationNumberInput.inputView = vehiclePicker
        registrationNumberInput.inputAccessoryView = toolbar2
        
        // Show products
        productPicker = UIPickerView()
        productPicker.delegate = self
        productPicker.dataSource = self
        productIdInput.inputView = productPicker
        productIdInput.inputAccessoryView = toolbar2
        
        // Show Agents
        agentPicker = UIPickerView()
        agentPicker.delegate = self
        agentPicker.dataSource = self
        agentIdInput.inputView = agentPicker
        agentIdInput.inputAccessoryView = toolbar2
        
        // Show Customers
        customerPicker = UIPickerView()
        customerPicker.delegate = self
        customerPicker.dataSource = self
        customerIdInput.inputView = customerPicker
        customerIdInput.inputAccessoryView = toolbar2
        
    }
    
    private func setupDatePickers() {
        datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datePickerValueChanged))
        toolbar.setItems([doneButton], animated: true)
        
        fromDateInput.inputView = datePicker
        fromDateInput.inputAccessoryView = toolbar
        toDateInput.inputView = datePicker
        toDateInput.inputAccessoryView = toolbar
        
        fromDateInput.delegate = self
        toDateInput.delegate = self
        
        
    }
    @objc func dismissFunc(){
        view.endEditing(true)
    }
    
    // Pickerview Protocl Methods implementation here
    
    // 1. number of components in picker view
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    // 2. number of rows in a component
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == vehiclePicker {
            return vehiclesList.count
        }else if pickerView == productPicker {
            return productsList.count
        }else if pickerView == customerPicker {
            return customersList.count
        }else if pickerView == agentPicker {
            return agentsList.count
        }
        return 0
    }
    
    //3. display the array info in rows
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == vehiclePicker {
            return vehiclesList[row]
        }else if pickerView == productPicker {
            return productsList[row]
        }else if pickerView == customerPicker {
            return customersList[row]
        }else if pickerView == agentPicker {
            return agentsList[row]
        }
        return nil
    }
    
    //4. when user select any row in component
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == vehiclePicker {
            registrationNumberInput.text = vehiclesList[row]
        }else if pickerView == productPicker {
            productIdInput.text = productsList[row]
        }else if pickerView == customerPicker {
            customerIdInput.text = customersList[row]
        }else if pickerView == agentPicker {
            agentIdInput.text = agentsList[row]
        }
        
    }
    
    
    
    func formatDateToISO8601WithMilliseconds(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC time
        return formatter.string(from: date)
    }
    
    @objc func datePickerValueChanged() {
        guard let activeField = activeDateField else { return }
        activeField.text = formatDateToISO8601WithMilliseconds(datePicker.date)
        view.endEditing(true)
    }
    
    @IBAction func getProposals(){
        
        guard let proposalNo = proposalIdInput.text, !proposalNo.isEmpty else {
            showAlert(title: "Validation Error", message: "Proposal number is required.")
            return
        }
        
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
                        
                        print(String(data: data, encoding: .utf8)!)
                        
                        
                         for proposal in jsonResponse{
                            if let proposalID = proposal["proposalNo"] as? String {
                                print(proposalID)
                                DispatchQueue.main.async{
                                    if proposalID.trimmingCharacters(in: .whitespacesAndNewlines) == self.proposalIdInput.text! {
                                        print("Found \(proposalID) == \(self.proposalIdInput.text!)")
                                        self.registrationNumberInput.text = proposal["regNo"] as? String
                                        self.productIdInput.text = proposal["productID"] as? String
                                        self.customerIdInput.text = proposal["customerID"] as? String
                                        self.fromDateInput.text = proposal["fromDate"] as? String
                                        self.toDateInput.text = proposal["toDate"] as? String
                                        self.IDVInput.text = "\(proposal["idv"] as! Double)"
                                        self.agentIdInput.text = proposal["agentID"] as? String
                                        self.basicAmountInput.text = "\(proposal["basicAmount"]! as! Double)"
                                        self.totalAmountInput.text = "\(proposal["totalAmount"]! as! Double)"
                                        
                                    }

                                }
                                
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

    func getVehicles(){
        
        //Create the URL Request
        let url = URL(string: "\(Constants.vehicleAPI)/api/Vehicle")! // Replace with your API URL
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
                        for vehicle in jsonResponse{
                            if let vehicleID = vehicle["regNo"] as? String {
                                print("Vehicle ID: \(vehicleID)")
                                self.vehiclesList.append(vehicleID)
                            }
                            else {
                                print("productID not found for product: \(vehicle)")
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
    
    func getProducts(){
        
        //Create the URL Request
        let url = URL(string: "\(Constants.productAPI)/api/Product")! // Replace with your API URL
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
                        for product in jsonResponse{
                            if let productID = product["productID"] as? String {
                                print("Product ID: \(productID)")
                                self.productsList.append(productID)
                            }
                            else {
                                print("productID not found for product: \(product)")
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
    
    func getCustomers(){
        
        //Create the URL Request
        let url = URL(string: "\(Constants.customerAPI)/api/Customer")! // Replace with your API URL
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
                        for customer in jsonResponse{
                            if let customerID = customer["customerID"] as? String {
                                print("Customer ID: \(customerID)")
                                self.customersList.append(customerID)
                            }
                            else {
                                print("Customer ID not found for product: \(customer)")
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
    
    func getAgents(){
        
        //Create the URL Request
        let url = URL(string: "\(Constants.agentAPI)/api/Agent")! // Replace with your API URL
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
                        for agent in jsonResponse{
                            if let agentID = agent["agentID"] as? String {
                                print("Agent ID: \(agentID)")
                                self.agentsList.append(agentID)
                            }
                            else {
                                print("Agent ID not found for product: \(agent)")
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
    
    
    
    @IBAction func postDetails() {
        let proposal = validateFields()
        
        guard let jsonData = try? JSONEncoder().encode(proposal) else {
            print("Failed to encode request body")
            return
        }
        
        let url = URL(string: "\(Constants.proposalAPI)/api/Proposal/\(Constants.bearerToken)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        print(String(data: jsonData, encoding: .utf8)!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                self.showAlert(title: "Details not saved", message: "\(String(data: data!, encoding: .utf8)!)")
                print("Server error")
                print(String(data: data!, encoding: .utf8)!)
                print("Response: \(String(describing: response))")
                
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
            
            if let data = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Response: \(jsonResponse)")
                    self.showAlert(title: "Success ", message: "Details saved")
                    
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    @IBAction func putDetails() {
        // Implementation for PUT
        let proposal = validateFields()
                
        guard let jsonData = try? JSONEncoder().encode(proposal) else {
            print("Failed to encode request body")
            return
        }
        
        let url = URL(string: "\(Constants.proposalAPI)/api/Proposal/\(proposalIdInput.text!)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        print(String(data: jsonData, encoding: .utf8)!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                if let data = data {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        print("Response: \(jsonResponse)")
                        self.showAlert(title: "Error ", message: "Details not updated")
                        
                    } catch {
                        print("Failed to decode response: \(error.localizedDescription)")
                    }
                }
                return
            }
            
            if let data = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Response: \(jsonResponse)")
                    self.showAlert(title: "Success ", message: "Details updated")
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
        
    }
    
    @IBAction func deleteDetails() {
        // Implementation for DELETE
        
        //let proposal = validateFields()
        
        guard let proposalNo = proposalIdInput.text, !proposalNo.isEmpty else {
            showAlert(title: "Validation Error", message: "Proposal number is required.")
            return
        }
        
        let proposal = Proposal(proposalNo: proposalNo, regNo: "", productId: "", customerId: "", fromDate: "", toDate: "", idv: 0, agentId: "", basicAmount: 0, totalAmount: 0)

        guard let jsonData = try? JSONEncoder().encode(proposal) else {
            print("Failed to encode request body")
            return
        }
        
        let url = URL(string: "\(Constants.proposalAPI)/api/Proposal/\(proposalIdInput.text!)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        print(String(data: jsonData, encoding: .utf8)!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                self.showAlert(title: "Error", message: "Details not deleted")
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
    
    func validateFields() -> Proposal? {
        // Check if text fields are filled and valid
        guard let proposalNo = proposalIdInput.text, !proposalNo.isEmpty else {
            showAlert(title: "Validation Error", message: "Proposal number is required.")
            return nil
        }
        
        guard let regNo = registrationNumberInput.text, !regNo.isEmpty else {
            showAlert(title: "Validation Error", message: "Registration number is required.")
            return nil
        }
        
        guard let productId = productIdInput.text, !productId.isEmpty else {
            showAlert(title: "Validation Error", message: "Product ID is required.")
            return nil
        }
        
        guard let customerId = customerIdInput.text, !customerId.isEmpty else {
            showAlert(title: "Validation Error", message: "Customer ID is required.")
            return nil
        }

        guard let fromDate = fromDateInput.text, !fromDate.isEmpty else {
            showAlert(title: "Validation Error", message: "From date is required.")
            return nil
        }
        
        guard let toDate = toDateInput.text, !toDate.isEmpty else {
            showAlert(title: "Validation Error", message: "To date is required.")
            return nil
        }
        
        guard let idvText = IDVInput.text, let idv = Int(idvText) else {
            showAlert(title: "Validation Error", message: "IDV must be a valid number.")
            return nil
        }
        
        guard let agentId = agentIdInput.text, !agentId.isEmpty else {
            showAlert(title: "Validation Error", message: "Agent ID is required.")
            return nil
        }

        guard let basicAmountText = basicAmountInput.text, let basicAmount = Int(basicAmountText) else {
            showAlert(title: "Validation Error", message: "Amount must be a valid number.")
            return nil
        }
        
        guard let totalAmountText = totalAmountInput.text, let totalAmount = Int(totalAmountText) else {
            showAlert(title: "Validation Error", message: "Amount must be a valid number.")
            return nil
        }


        
        // Return Policy object if all validations pass
        return Proposal(proposalNo: proposalNo, regNo: regNo, productId: productId, customerId: customerId, fromDate: fromDate, toDate: toDate, idv: idv, agentId: agentId,basicAmount: basicAmount,totalAmount: totalAmount)
    }

}
extension ProposalViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == fromDateInput || textField == toDateInput {
            activeDateField = textField
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == activeDateField {
            activeDateField = nil
        }
    }
    
}

