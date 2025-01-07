//
//  Constants.swift
//  05-Login-Module
//
//  Created by FCI on 29/12/24.
//

import Foundation

struct Constants{
    static let registerSegue = "Register"
    static let loginSegue = "Login"
    static let createAccountSegue = "Create Account"
    
    static let customerAPI = "https://abzcustomerwebapi-chanad.azurewebsites.net"
    static let productAPI = "https://abzproductwebapi-chanad.azurewebsites.net"
    static let queryAPI = "https://abzquerywebapi-chanad.azurewebsites.net"
    static let agentAPI = "https://abzagentwebapi-chanad.azurewebsites.net"
    static let claimAPI = "https://abzclaimwebapi-chanad.azurewebsites.net"
    static let policyAPI = "https://abzpolicywebapi-chanad.azurewebsites.net"
    static let proposalAPI = "https://abzproposalwebapi-chanad.azurewebsites.net"
    static let vehicleAPI = "https://abzvehiclewebapi-chanad.azurewebsites.net"
    static let authAPI = "https://abzauthwebapi-chanad.azurewebsites.net"
    

    
    static var bearerToken:String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoidXNlck5hbWUiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJyb2xlIiwiZXhwIjoxNzM1OTg1Nzg3LCJpc3MiOiJodHRwczovL3d3dy50ZWFtMS5jb20iLCJhdWQiOiJodHRwczovL3d3dy50ZWFtMS5jb20ifQ.92Sb-Pj_WrkQ7rxkB_LUF-ePIJ12F4-dcu4ybGMGx2s"
    
    static func generateToken(){
       
        //Create the URL Request
        let url = URL(string: "\(Constants.authAPI)/api/Auth/userName/role/My name is Bond, James Bond the great")! // Replace with your API URL
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
                        print(String(data: data, encoding: .utf8)!)
                        print("Failed to decode response: \(error.localizedDescription)")
                    }
                }
                return
            }
            print("Getting the Response")
            
            if let data = data {
                print(String(data: data, encoding: .utf8)!)
                bearerToken = String(data: data, encoding: .utf8)!
            }
        }
        task.resume()

    }

}
