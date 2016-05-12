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
        let feedUrl = "http://localhost:8080/findme/api/user/fixtures"
        
        let request = NSURLRequest(URL: NSURL(string: feedUrl)!)
        
        self.users = []
        
        NSURLConnection.sendAsynchronousRequest(request,queue: NSOperationQueue.mainQueue()) {
            response, data, error in if let jsonData = data,
                json = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers)) as? [NSDictionary]{
                    for user : NSDictionary in json{
                        let name = user["pseudo"] as? String
                        let latitude = user["latitude"] as? Double
                        let longitude = user["longitude"] as? Double
                        let friendList = user["friendList"] as? [User]
                        let phoneNumber = user["phoneNumber"] as? String
                        let jsonUser = User(pseudo: name!, latitude: latitude!, longitude: longitude!, friendList: friendList!, phoneNumber : phoneNumber!)
                        self.users.append(jsonUser)
                    }
            }
        }
    }
}   