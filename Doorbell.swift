//
//  Doorbell.swift
//  Doorbell Swift
//
//  Created by Grigory Avdyushin.
//  Copyright © 2016 Grigory Avdyushin. All rights reserved.
//

import Foundation

class Doorbell: NSObject {
    
    let logging = true
    let session = NSURLSession.sharedSession()
    let baseURL = "https://doorbell.io/api"
    
    let applicationId: String!
    let apiKey: String!
    
    init(applicationId: String, apiKey: String) {
        self.applicationId = applicationId
        self.apiKey = apiKey
    }
    
    func submit(email: String, message: String, completionHandler: (NSDictionary?, NSError?) -> Void) {
        postJSON("\(baseURL)/applications/\(applicationId)/submit?key=\(apiKey)", parameters: ["email": email, "message": message]) { data, response, error in
            completionHandler(data, error)
        }
    }
    
    func makeRequest(request: NSURLRequest, completionHandler: (NSDictionary?, NSURLResponse?, NSError?) -> Void) {
        
        logRequest(request)
        let startTime = NSDate()
        session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            self.logResponse(response, timeInterval: NSDate().timeIntervalSinceDate(startTime))
            
            guard let d = data else { completionHandler(nil, response, error); return }
            
            do {
                
                let json = try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                completionHandler(json, response, error)
                
            } catch let e as NSError {
                
                completionHandler(nil, response, e)
                
            }
            
            }.resume()
        
    }

    func postJSON(path: String, parameters: [String: String], completionHandler: (NSDictionary?, NSURLResponse?, NSError?) -> Void) {
        
        do {
            
            let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])

            let request = NSMutableURLRequest(URL: NSURL(string: path)!)
            request.HTTPMethod = "POST"
            request.HTTPBody = data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("HttpClient 1.0", forHTTPHeaderField: "User-Agent")
            
            makeRequest(request) { (data: NSDictionary?, response: NSURLResponse?, error: NSError?) -> Void in
                completionHandler(data, response, error)
            }
            
        } catch let error as NSError {
            completionHandler(nil, nil, error)
        }
        
    }

    func getJSON(path: String, completionHandler: (NSDictionary?, NSURLResponse?, NSError?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        request.HTTPMethod = "GET"
        request.addValue("HttpClient 1.0", forHTTPHeaderField: "User-Agent")
        
        makeRequest(request) { (data: NSDictionary?, response: NSURLResponse?, error: NSError?) -> Void in
            completionHandler(data, response, error)
        }
        
    }
    
    func logRequest(request: NSURLRequest) {
        if logging {
            print("\(request.HTTPMethod!) '\(request.URL!)'")
        }
    }
    
    func logResponse(response: NSURLResponse?, timeInterval: NSTimeInterval) {
        if logging {
            if let response = response as? NSHTTPURLResponse {
                print("\(response.statusCode) '\(response.URL!)' \(NSString(format: "[%0.4f s]", timeInterval))")
            }
        }
    }
    
}
