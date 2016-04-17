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
                        let password = user["password"] as? String
                        let x = user["x"] as? Double
                        let y = user["y"] as? Double
                        let friendList = user["friendList"] as? [User]
                        let jsonUser = User(pseudo: name!, x: x!, y: y!, password: password!, friendList: friendList!)
                        self.users.append(jsonUser)
                    }
            }
        }
    }
}   