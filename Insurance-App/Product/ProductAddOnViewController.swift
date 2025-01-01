//
//  ProductAddonFormViewController.swift
//  SideMenu2
//
//  Created by FCI on 23/12/24.
//

import UIKit


struct ProductAddon: Codable {
    
    let productID: String
    let addonID: String
    let addonTitle: String
    let addonDescription: String
}

struct RequestBody1: Codable {
    let productAddons: [ProductAddon]
}

class ProductAddonViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource   {

    
    @IBOutlet var addOnInput:UITextField!
    @IBOutlet var addOnTitleInput:UITextField!
    @IBOutlet var addOnDescriptionInput:UITextField!
    @IBOutlet var productIdInput:UITextField!
    
    @IBOutlet var postDetailsButton: UIButton!
    @IBOutlet var updateDetailsButton: UIButton!
    @IBOutlet var deleteDetailsButton: UIButton!
    
    var productsList:[String] =  []

    var productPicker: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        getProducts()
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dismissFunc))
        toolbar.setItems([done], animated: true)
        
        // Setup Payment Options Picker for paymentOptionsInput
        productPicker = UIPickerView()
        productPicker.delegate = self
        productPicker.dataSource = self
        productIdInput.inputView = productPicker
        productIdInput.inputAccessoryView = toolbar

    }
    
    // Pickerview Protocl Methods implementation here
    
    // 1. number of components in picker view
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }

    // 2. number of rows in a component
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if pickerView == productPicker {
            return productsList.count
        }
        return 0
    }
    
    //3. display the array info in rows
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == productPicker {
            return productsList[row]
        }
        return nil
    }
    
    //4. when user select any row in component
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == productPicker {
            productIdInput.text = productsList[row]
        }
        
    }

    @objc func dismissFunc(){
        view.endEditing(true)
    }

    func getProducts(){
        
        //Create the URL Request
        //let url = URL(string: "https://abzproductwebapi-chanad.azurewebsites.net/api/Product")! // Replace with your API URL
        let url = URL(string: "\(Constants.productAPI)/api/Product")!
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

    @IBAction func postDetails(){
        let productAddon = ProductAddon(
            productID: productIdInput.text!,
            addonID: addOnInput.text!,
            addonTitle: addOnTitleInput.text!,
            addonDescription: addOnDescriptionInput.text!
        )
        
        // Encode Request Body into JSON
        guard let jsonData = try? JSONEncoder().encode(productAddon) else {
            print("Failed to encode request body")
            return
        }
        print("ENCODED REQUEST BODY IN JSON")

        //Create the URL Request
        let url = URL(string: "\(Constants.productAPI)/api/ProductAddOn/\(Constants.bearerToken)")! // Replace with your API URL
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
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Response: \(jsonResponse)")
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()

        
    }

    @IBAction func putDetails(){
        
            let productAddon = ProductAddon(
                productID: productIdInput.text!,
                addonID: addOnInput.text!,
                addonTitle: addOnTitleInput.text!,
                addonDescription: addOnDescriptionInput.text!
            )
            
            // Encode Request Body into JSON
            guard let jsonData = try? JSONEncoder().encode(productAddon) else {
                print("Failed to encode request body")
                return
            }
            print("ENCODED REQUEST BODY IN JSON")

            //Create the URL Request
            let url = URL(string: "\(Constants.productAPI)/api/ProductAddOn/\(productIdInput.text!)/\(addOnInput.text!)")! // Replace with your API URL
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
        let productAddon = ProductAddon(
            productID: productIdInput.text!,
            addonID: addOnInput.text!,
            addonTitle: addOnTitleInput.text!,
            addonDescription: addOnDescriptionInput.text!
        )
        
        // Encode Request Body into JSON
        guard let jsonData = try? JSONEncoder().encode(productAddon) else {
            print("Failed to encode request body")
            return
        }
        print("ENCODED REQUEST BODY IN JSON")

        //Create the URL Request
        let url = URL(string: "\(Constants.productAPI)/api/ProductAddOn/\(productIdInput.text!)/\(addOnInput.text!)")! // Replace with your API URL
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
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Response: \(jsonResponse)")
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()

    }

}
