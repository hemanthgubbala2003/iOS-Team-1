//
//  Customer.swift
//  05-Login-Module
//
//  Created by FCI on 30/12/24.
//

import Foundation

struct Customer: Codable {
    
    var customerID: String
    var customerName: String
    var customerPhone: String
    var customerEmail: String
    var customerAddress: String
    
    static var customer: Customer!
    
    static func getCustomers(customerEmail: String, completion: @escaping (Customer?, Error?) -> Void) {
        // Create the URL Request
        let url = URL(string: "\(Constants.customerAPI)/api/Customer")! // Replace with your API URL
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Constants.bearerToken)", forHTTPHeaderField: "Authorization")

        // Perform the API Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error) // Notify the caller about the error
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
            
            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        for customer in jsonResponse {
                            if customer["customerEmail"] as? String == customerEmail {
                                let foundCustomer = Customer(
                                    customerID: "\(customer["customerID"]!)",
                                    customerName: "\(customer["customerName"]!)",
                                    customerPhone: "\(customer["customerPhone"]!)",
                                    customerEmail: "\(customer["customerEmail"]!)",
                                    customerAddress: "\(customer["customerAddress"]!)"
                                )
                                
                                // Update the static variable safely
                                DispatchQueue.main.async {
                                    Customer.customer = foundCustomer
                                    completion(foundCustomer, nil) // Notify the caller with the found customer
                                }
                                return
                            }
                        }
                        // Customer not found
                        DispatchQueue.main.async {
                            completion(nil, NSError(domain: "NotFoundError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Customer not found for the provided email"]))
                        }
                    }
                } catch {
                    completion(nil, error) // Notify the caller about the decoding error
                }
            }
        }
        task.resume()
    }

    
}
