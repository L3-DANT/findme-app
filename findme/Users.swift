//
//  Users.swift
//  findme
//
//  Created by Nicolas Mercier on 17/03/2016.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import Foundation


class Users {
    
    var users : [User]
    
    init(){
        self.users = []
        
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var dataTask: NSURLSessionDataTask?
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8080/findme/api/user/v1/users")!)
        request.HTTPMethod = "GET"
        
        dataTask = defaultSession.dataTaskWithRequest(request) {
            data, response, error in
            
            do{
                if let error = error {
                    print(error.localizedDescription)
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    print(httpResponse.statusCode)
                    if httpResponse.statusCode == 200 {
                        if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [NSDictionary] {
                            dispatch_async(dispatch_get_main_queue(), {
                                for user : NSDictionary in jsonResult{
                                    let name = user["pseudo"] as? String
                                    let latitude = user["latitude"] as? Double
                                    let longitude = user["longitude"] as? Double
                                    let friendList = user["friendList"] as? [User]
                                    let phoneNumber = user["phoneNumber"] as? String
                                    let jsonUser = User(pseudo: name!, latitude: latitude!, longitude: longitude!, friendList: friendList!, phoneNumber : phoneNumber!)
                                    self.users.append(jsonUser)
                                }
                            })
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        dataTask?.resume()
    }
}   