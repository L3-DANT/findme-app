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
    
    func getUser(username: String, onCompletion: (User?, String?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator.generateRoute(APICommunicator.Route.user.rawValue, parameters: nil, directParam: username), params: nil, onCompletion: { json, err in
            if err != nil {
                onCompletion(nil, err!)
            } else {
                let user: User = UserService.unserializeJsonResponse(json!)
                
                onCompletion(user, nil)
            }
        })
    }
    
    func getFriendRequest(params: [String:String], onCompletion: ([String:AnyObject]?, String?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator.generateRoute(APICommunicator.Route.user.rawValue, parameters: params, directParam: nil), params: nil, onCompletion: { json, err in
            if err != nil {
                onCompletion(nil, err!)
            } else {
                onCompletion(json!, nil)
            }
        })
    }
    
    func sendFriendRequest(friendRequest : [String:String], onCompletion: (String?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator.generateRoute(APICommunicator.Route.friendRequest.rawValue, parameters: nil, directParam: nil), params: UserService.toJson(friendRequest), HTTPMethod: "PUT", onCompletion : {json, err in
                onCompletion(nil)
            }
        )
    }
    
    func deleteFriendRequest(caller : String, receiver : String, onCompletion: (String?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator.generateRoute(APICommunicator.Route.friendRequest.rawValue, parameters: ["caller":caller, "receiver":receiver], directParam: nil), params: nil, HTTPMethod: "DELETE", onCompletion : {json, err in
            onCompletion(err!)
        })
    }
    
    func acceptFriendRequest(friendRequest : [String:String], onCompletion: (String?) -> Void) {
        self.makeHTTPRequest(self.apiCommunicator.generateRoute(APICommunicator.Route.friendRequest.rawValue, parameters: nil, directParam: nil), params: UserService.toJson(friendRequest), HTTPMethod: "POST", onCompletion : {json, err in
            onCompletion(err!)
        })
    }
    
    func makeHTTPRequest(path: NSURL, params: NSData?, HTTPMethod: String = "GET", onCompletion: ([String:AnyObject]?, String?) -> Void) {
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
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String:AnyObject]
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
