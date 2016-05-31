//
//  APIService.swift
//  findme
//
//  Created by Maxime Signoret on 11/05/16.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import CoreLocation

class APIService {
    let apiCommunicator = APICommunicator.getInstance
    
    enum MyError : ErrorType {
        case RuntimeError(String)
    }

    func signIn(params: [String:String], onCompletion: (User?, String?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator.generateRoute(APICommunicator.Route.login.rawValue, parameters: nil, directParam: nil), params: UserService.toJson(params), HTTPMethod: "POST", onCompletion: { json, err in
            
            if err != nil {
                onCompletion(nil, String(err!.debugDescription))
            } else {
                UserService.setUserInSession(json!)
                let user: User = UserService.unserializeJsonResponse(json!)

                onCompletion(user, nil)
            }
        })
    }
    
    func signUp(params: [String:String], onCompletion: (User?, String?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator.generateRoute(APICommunicator.Route.user.rawValue, parameters: nil, directParam: nil), params: UserService.toJson(params), HTTPMethod: "PUT", onCompletion: { json, err in
            
            if err != nil {
                onCompletion(nil, err!)
            } else {
                UserService.setUserInSession(json!)
                let user: User = UserService.unserializeJsonResponse(json!)
                
                onCompletion(user, nil)
            }
        })
    }
    
    func updateLocation(params: [String:String], onCompletion: (User?, String?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator.generateRoute(APICommunicator.Route.user.rawValue, parameters: nil, directParam: nil), params: UserService.toJson(params), HTTPMethod: "POST", onCompletion: { json, err in
            
            if err != nil {
                onCompletion(nil, err!)
            } else {
                UserService.setUserInSession(json!)
                let user: User = UserService.unserializeJsonResponse(json!)
                
                onCompletion(user, nil)
            }
        })
    }
    
    func updateUser(params: String, onCompletion: (User?, String?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator.generateRoute(APICommunicator.Route.user.rawValue, parameters: nil, directParam: nil), params: params.dataUsingEncoding(NSUTF8StringEncoding), HTTPMethod: "POST", onCompletion: { json, err in
            
            if err != nil {
                onCompletion(nil, err!)
            } else {
                UserService.setUserInSession(json!)
                let user: User = UserService.unserializeJsonResponse(json!)
                
                onCompletion(user, nil)
            }
        })
    }
    
    func deleteUser(name: String, onCompletion: (String?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator.generateRoute(APICommunicator.Route.user.rawValue, parameters: nil, directParam: name),params: nil, HTTPMethod: "DELETE", onCompletion: { json, err in

        })
    }
    
    func getUser(username: String, onCompletion: (User?, String?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator.generateRoute(APICommunicator.Route.user.rawValue, parameters: nil, directParam: username), params: nil, onCompletion: { json, err in
            if err != nil {
                onCompletion(nil, String(err!.debugDescription))
            } else {
                UserService.setUserInSession(json!)
                let user: User = UserService.unserializeJsonResponse(json!)
                
                onCompletion(user, nil)
            }
        })
    }
    
    func getFriendRequest(params: [String:String], onCompletion: ([String]?, String?) -> Void) {
        self.makeGetHTTPRequest(self.apiCommunicator.generateRoute(APICommunicator.Route.friendRequest.rawValue, parameters: params, directParam: nil), params: nil, onCompletion: { json, err in
            if json != nil {
                onCompletion(json, nil)
            } else {
                onCompletion(nil, "Empty")
            }
        })
    }
    
    func sendFriendRequest(friendRequest : [String:String], onCompletion: (String?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator.generateRoute(APICommunicator.Route.friendRequest.rawValue, parameters: nil, directParam: nil), params: UserService.toJson(friendRequest), HTTPMethod: "PUT", deserialize: false, onCompletion : {json, err in
            if err != nil {
                onCompletion("Account does not exist")
            } else {
                onCompletion(nil)
            }
        })
    }
    
    func deleteFriendRequest(params: [String:String], onCompletion: (String?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator.generateRoute(APICommunicator.Route.friendRequest.rawValue, parameters: params, directParam: nil), params: nil, HTTPMethod: "DELETE", onCompletion : {json, err in
            if err != nil {
                onCompletion("Delete error.")
            }
        })
    }
    
    func acceptFriendRequest(friendRequest : [String:String], onCompletion: (String?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator.generateRoute(APICommunicator.Route.friendRequest.rawValue, parameters: nil, directParam: nil), params: UserService.toJson(friendRequest), HTTPMethod: "POST", onCompletion : {json, err in
            if err != nil {
                onCompletion("Accept error.")
            }
        })
    }
    
    func makeHTTPRequest(path: NSURL, params: NSData?, HTTPMethod: String = "GET", deserialize: Bool = true, onCompletion: ([String:AnyObject]?, String?) -> Void) {
        let request = NSMutableURLRequest(URL: path)
        request.HTTPMethod = HTTPMethod
            
        if HTTPMethod != "GET" && HTTPMethod != "DELETE" {
            request.HTTPBody = params
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }
            
        let session = NSURLSession.sharedSession()
            
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                onCompletion(nil, error!.localizedDescription)
            } else {
                let realResponse = response as? NSHTTPURLResponse

                if realResponse!.statusCode >= 200 && realResponse!.statusCode < 300 {
                    do {
                        if deserialize {
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String:AnyObject]
                            onCompletion(json, nil)
                        } else {
                            onCompletion(nil, nil)
                        }
                    } catch {
                        onCompletion(nil, String(error))
                    }
                } else {
                    onCompletion(nil, "Bad credentials")
                }
            }
        })
            
        task.resume()
    }
    
    func makeGetHTTPRequest(path: NSURL, params: NSData?, HTTPMethod: String = "GET", onCompletion: ([String]?, String?) -> Void) {
        let request = NSMutableURLRequest(URL: path)
        request.HTTPMethod = HTTPMethod
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                onCompletion(nil, error!.localizedDescription)
            } else {
                let realResponse = response as? NSHTTPURLResponse
                
                if realResponse!.statusCode >= 200 && realResponse!.statusCode < 300 {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String]
                        onCompletion(json, nil)
                    } catch {
                        onCompletion(nil, String(error))
                    }
                } else {
                    onCompletion(nil, "Bad credentials")
                }
            }
        })
        
        task.resume()
    }
}
