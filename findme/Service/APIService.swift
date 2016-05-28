//
//  APIService.swift
//  findme
//
//  Created by Maxime Signoret on 11/05/16.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import CoreLocation

class APIService {
    let apiCommunicator = APICommunicator.getInstance.getBaseUrl()
    
    enum MyError : ErrorType {
        case RuntimeError(String)
    }

    func signIn(params: [String:String], onCompletion: (User?, ErrorType?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator + "/user/v1/login", params: params, HTTPMethod: "POST", onCompletion: { json, err in
            
            if err != nil {
                onCompletion(nil, err)
            } else {
                UserService.setUserInSession(json!)
                let user: User = UserService.unserializeJsonResponse(json!)

                onCompletion(user, nil)
            }
        })
    }
    
    func signUp(params: [String:String], onCompletion: (User?, ErrorType?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator + "/user/v1", params: params, HTTPMethod: "PUT", onCompletion: { json, err in
            
            if err != nil {
                onCompletion(nil, err)
            } else {
                UserService.setUserInSession(json!)
                let user: User = UserService.unserializeJsonResponse(json!)
                
                onCompletion(user, nil)
            }
        })
    }
    
    func updateUser(params: [String:String], onCompletion: (User?, ErrorType?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator + "/user/v1", params: params, HTTPMethod: "POST", onCompletion: { json, err in
            
            if err != nil {
                onCompletion(nil, err)
            } else {
                UserService.setUserInSession(json!)
                let user: User = UserService.unserializeJsonResponse(json!)
                
                onCompletion(user, nil)
            }
        })
    }
    
    func getUser(username: NSString, onCompletion: (User?, ErrorType?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator + "/user/v1/\(username)", params: nil, onCompletion: { json, err in
            if err != nil {
                onCompletion(nil, err)
            } else {
                let user: User = UserService.unserializeJsonResponse(json!)
                
                onCompletion(user, nil)
            }
        })
    }
    
    func sendFriendRequest(friendRequest : [String: String], onCompletion: (ErrorType?) -> Void) {
        self.getUser(friendRequest["receiver"]!, onCompletion: {user, err in
            if err == nil {
                self.makeHTTPRequest(self.apiCommunicator + "/friendrequest/v1", params: friendRequest, HTTPMethod: "PUT", onCompletion : {json, err in
                    onCompletion(nil)
                })
            } else {
                onCompletion(err)
            }
        })
    }
    
    func deleteFriendRequest(caller : String, receiver : String, onCompletion: (ErrorType?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator + "/friendrequest/v1?caller=\(caller)&receiver=\(receiver)", params: nil, HTTPMethod: "DELETE", onCompletion : {json, err in
            onCompletion(err)
        })
    }
    
    func acceptFriendRequest(friendRequest : [String : String], onCompletion: (ErrorType?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator + "/friendrequest/v1", params: friendRequest, HTTPMethod: "POST", onCompletion : {json, err in
            onCompletion(err)
        })
    }
    
    func updateCurrentUserLocation(name : String, location : CLLocationCoordinate2D) {
        let params = ["pseudo" : name, "latitude" : "\(location.latitude)", "longitude" : "\(location.longitude)"]
        
        self.makeHTTPRequest(self.apiCommunicator + "/update-coordinates", params: params, HTTPMethod : "POST", onCompletion: {json, err in

        })
    }
    
    func makeHTTPRequest(path: String, params: [String: String]?, HTTPMethod: String = "GET", onCompletion: ([String:AnyObject]?, ErrorType?) -> Void) {
        do {
            let request = NSMutableURLRequest(URL: NSURL(string: path)!)
            request.HTTPMethod = HTTPMethod
            
            if HTTPMethod != "GET" && HTTPMethod != "DELETE"{
                let postData:NSData = try NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions())
                let postLength:NSString = String(postData.length)
            
                request.HTTPBody = postData
                request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
            }
            
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                let realResponse = response as? NSHTTPURLResponse
                print(realResponse?.statusCode)
                
                if realResponse!.statusCode >= 200 && realResponse!.statusCode < 300 {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String:AnyObject]
                        onCompletion(json, nil)
                    } catch {
                        onCompletion(nil, error)
                    }
                } else {
                    onCompletion(nil, MyError.RuntimeError("Bad credentials"))
                }
            })
            
            task.resume()
        } catch {
            NSLog("Error: %ld", "Bad data");
        }
    }
}
