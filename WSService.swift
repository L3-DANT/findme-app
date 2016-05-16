//
//  WSService.swift
//  findme
//
//  Created by Maxime Signoret on 11/05/16.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import Foundation

class WSService {
    let wsConnection = WSConnection.getInstance.getBaseUrl()
    let userAppSession = "user"

    func signIn(username: NSString, password: NSString, onCompletion: (User?, ErrorType?) -> Void) {
        let postParams: [String: String] = ["pseudo": username as String, "password": password as String]

        makeHTTPRequest(wsConnection + "/user/v1/login", params: postParams, HTTPMethod: "POST", onCompletion: { json, err in
            
            if err != nil {
                onCompletion(nil, err)
            } else {
                let data = json!["data"]
                
                let userSession = NSUserDefaults.standardUserDefaults()
                userSession.setObject(data!, forKey: self.userAppSession)
                userSession.synchronize()
                
                let name = data!["pseudo"] as? String
                let latitude = data!["latitude"] as? Double
                let longitude = data!["longitude"] as? Double
                let friendList = data!["friendList"] as? [User]
                let phoneNumber = data!["phoneNumber"] as? String

                let user:User = User(pseudo: name!, latitude: latitude!, longitude: longitude!, friendList: friendList!, phoneNumber: phoneNumber!)

                onCompletion(user, nil)
            }
        })
    }
    
    func signUp(username: NSString, phoneNumber: NSString, password: NSString, confirmPassword: NSString, onCompletion: (User?, ErrorType?) -> Void) {
        let postParams: [String: String] = ["pseudo": username as String, "phoneNumber": phoneNumber as String, "password": password as String]
        
        makeHTTPRequest(wsConnection + "/user/v1/sign-up", params: postParams, HTTPMethod: "PUT", onCompletion: { json, err in
            let data = json!["data"]
            
            if err != nil || (data is NSNull) {
                onCompletion(nil, err)
            } else {
                let name = data!["pseudo"] as? String
                let latitude = data!["latitude"] as? Double
                let longitude = data!["longitude"] as? Double
                let friendList = data!["friendList"] as? [User]
                let phoneNumber = data!["phoneNumber"] as? String
                
                let user:User = User(pseudo: name!, latitude: latitude!, longitude: longitude!, friendList: friendList!, phoneNumber: phoneNumber!)
                
                onCompletion(user, nil)
            }
        })
    }

    func getUsers(onCompletion: (User?, ErrorType?) -> Void) {
        makeHTTPRequest(wsConnection + "/user/v1/users", params: nil, onCompletion: { json, err in
            let data = json!["data"]
            
            if err != nil || (data is NSNull) {
                onCompletion(nil, err)
            } else {
                let name = data!["pseudo"] as? String
                let latitude = data!["latitude"] as? Double
                let longitude = data!["longitude"] as? Double
                let friendList = data!["friendList"] as? [User]
                let phoneNumber = data!["phoneNumber"] as? String
                
                let user:User = User(pseudo: name!, latitude: latitude!, longitude: longitude!, friendList: friendList!, phoneNumber: phoneNumber!)
                
                onCompletion(user, nil)
            }
        })
    }
    
    func getUser(username: NSString, onCompletion: (User?, ErrorType?) -> Void) {
        makeHTTPRequest(wsConnection + "/user/v1/getUser?pseudo=\(username)", params: nil, onCompletion: { json, err in
            let data = json!["data"]
            
            if err != nil || (data is NSNull) {
                onCompletion(nil, err)
            } else {
                let name = data!["pseudo"] as? String
                let latitude = data!["latitude"] as? Double
                let longitude = data!["longitude"] as? Double
                let friendList = data!["friendList"] as? [User]
                let phoneNumber = data!["phoneNumber"] as? String
                
                let user:User = User(pseudo: name!, latitude: latitude!, longitude: longitude!, friendList: friendList!, phoneNumber: phoneNumber!)
                
                onCompletion(user, nil)
            }
        })
    }

    func makeHTTPRequest(path: String, params: [String: String]?, HTTPMethod: String = "GET", onCompletion: ([String:AnyObject]?, ErrorType?) -> Void) {
        do {
            let request = NSMutableURLRequest(URL: NSURL(string: path)!)
            request.HTTPMethod = HTTPMethod
            
            if HTTPMethod != "GET" {
                let postData:NSData = try NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions())
                let postLength:NSString = String(postData.length)
            
                request.HTTPBody = postData
                request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
            }
            
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                if error != nil {
                    onCompletion(nil, error)
                } else {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? [String:AnyObject]
                        onCompletion(json, nil)
                    } catch {
                        onCompletion(nil, error)
                    }
                }
            })
            
            task.resume()
        } catch {
            NSLog("Error: %ld", "Bad data");
        }
    }
}
