//
//  ProductViewController.swift
//  MenuBar
//
//  Created by FCI on 26/12/24.
//

import UIKit

class ProductViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet var Product: UITextField!
    @IBOutlet var ProductNam: UITextField!
    @IBOutlet var ProductDes: UITextField!
    @IBOutlet var ProductUIn: UITextField!
    @IBOutlet var InsuredIn: UITextField!
    @IBOutlet var PolicyCov: UITextField!
    
    
    @IBOutlet var Save: UIButton!
    @IBOutlet var Update: UIButton!
    @IBOutlet var Delete: UIButton!
    @IBOutlet var GET: UIButton!
    
    var pv1: UIPickerView!
    var InsuredIntrest: [String] = []
    
    var pv2: UIPickerView!
    var PolicyCoverage: [String] = []
    
    var pv3: UIPickerView!
    var prodID: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissFunc))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        InsuredIntrest = ["Private Car", "Public Car"]
        // Set up the UIPickerView for ClaimStatus
        pv1 = UIPickerView()
        pv1.delegate = self
        pv1.dataSource = self
        InsuredIn.inputView = pv1
        InsuredIn.inputAccessoryView = toolbar
        
        PolicyCoverage = ["1", "2", "3", "5"]
        
        pv2 = UIPickerView()
        pv2.delegate = self
        pv2.dataSource = self
        PolicyCov.inputView = pv2
        PolicyCov.inputAccessoryView = toolbar
        
        
        pv3 = UIPickerView()
        pv3.delegate = self
        pv3.dataSource = self
        Product.inputView = pv3
        Product.inputAccessoryView = toolbar
        
        fetchproductIDs()
        
    }
    
    
    @IBAction func ClickSave(_ sender: UIButton) {

        
        guard let product = Product.text, !product.isEmpty,
              let productName = ProductNam.text, !productName.isEmpty,
              let productDescription = ProductDes.text, !productDescription.isEmpty,
              let productUIN = ProductUIn.text, !productUIN.isEmpty,
              let insuredIn = InsuredIn.text, !insuredIn.isEmpty,
              let policyCoverage = PolicyCov.text, !policyCoverage.isEmpty else {
            showAlert(title: "Error", message: "All fields must be filled.")
            return
        }

        
        guard let webserviceURL = URL(string: "\(Constants.productAPI)/api/Product/\(Constants.bearerToken)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let productDetails: [String: Any] = [
            
            "productID": product,
            "productName": productName,
            "productDescription": productDescription,
            "productUIN": productUIN,
            "insuredInterests": insuredIn,
            "policyCoverage": policyCoverage
            
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: productDetails, options: [])
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


    
    
    
    @IBAction func ClickUpdate(_ sender: UIButton) {

        guard let product = Product.text, !product.isEmpty,
              let productName = ProductNam.text, !productName.isEmpty,
              let productDescription = ProductDes.text, !productDescription.isEmpty,
              let productUIN = ProductUIn.text, !productUIN.isEmpty,
              let insuredIn = InsuredIn.text, !insuredIn.isEmpty,
              let policyCoverage = PolicyCov.text, !policyCoverage.isEmpty else {
            showAlert(title: "Error", message: "Invalid input: All fields must be filled.")
            return
        }
        
        
        guard let webserviceURL = URL(string: "\(Constants.productAPI)/api/Product/\(product)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }
        
        // Configure PUT request
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare JSON payload
        let productDetails: [String: Any] = [
            "productID": product,
            "productName": productName,
            "productDescription": productDescription,
            "productUIN": productUIN,
            "insuredInterests": insuredIn,
            "policyCoverage": policyCoverage
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: productDetails, options: [])
            request.httpBody = jsonData
        } catch {
            showAlert(title: "Error", message: "Failed to serialize JSON: \(error.localizedDescription)")
            return
        }
        
        // Perform the request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                return
            }
            
            // Handle response
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

    
    
    
    @IBAction func ClickDelete(_ sender: UIButton) {
        
  
        
        guard let productID = Product.text, !productID.isEmpty else {
            showAlert(title: "Error", message: "Invalid input: Product ID must be provided.")
            return
        }
        
        guard let webserviceURL = URL(string: "\(Constants.productAPI)/api/Product/\(productID)") else {
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

        guard let product = Product.text, !product.isEmpty else {
            showAlert(title: "Error", message: "Registration Number must be filled.")
            return
        }
        
        // Construct the URL
        guard let webserviceURL = URL(string: "\(Constants.productAPI)/api/Product/\(product)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
                    
                    // Update UI on the main thread
                    DispatchQueue.main.async {
                        self.Product.text = (jsonResponse["productID"] as? String)?.trimmingCharacters(in: .whitespaces) ?? "N/A"
                        self.ProductNam.text = jsonResponse["productName"] as? String ?? "N/A"
                        self.ProductDes.text = jsonResponse["productDescription"] as? String ?? "N/A"
                        self.ProductUIn.text = (jsonResponse["productUIN"] as? String)?.trimmingCharacters(in: .whitespaces) ?? "N/A"

                        self.InsuredIn.text = jsonResponse["insuredInterests"] as? String ?? "N/A"
                        self.PolicyCov.text = jsonResponse["policyCoverage"] as? String ?? "N/A"
                        
                  
                        if let productAddons = jsonResponse["productAddons"] as? [String], !productAddons.isEmpty {
                            print("Product Addons: \(productAddons)")
                            
                        } else {
                            print("No product addons available.")
                        }
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
    
    
    
    // UIPickerViewDelegate and UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Single component in each picker
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pv1 {
            return InsuredIntrest.count
        } else if pickerView == pv2  {
            return PolicyCoverage.count
        } else {
            return prodID.count
        }
      
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pv1 {
            return InsuredIntrest[row]
        } else if pickerView == pv2 {
            return PolicyCoverage[row]
        } else {
            return prodID[row]
        }
   
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pv1 {
            InsuredIn.text = InsuredIntrest[row]
        } else if pickerView == pv2  {
            PolicyCov.text = PolicyCoverage[row]
        }else {
            Product.text = prodID[row]
        }
    }
    
    @objc func dismissFunc(){
        view.endEditing(true)
    }
    
    
    
    func fetchproductIDs() {

        
        // Correct URL without token in the path
        let url = URL(string: "\(Constants.productAPI)/api/Product")!

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
            
            if let data = data {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response data as String"
                print("Response Data String: \(responseString)")
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        for product in jsonResponse {
                            if let productID = product["productID"] as? String {
                                print("CustomerID: \(productID)")
                                // Assuming self.CustomerID exists as an array property
                                self.prodID.append(productID)
                            } else {
                                print("CustomerID not found for product: \(product)")
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
