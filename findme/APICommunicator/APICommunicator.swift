//
//  APICommunicator.swift
//  findme
//
//  Created by Maxime Signoret on 05/05/16.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import Foundation


class APICommunicator {
    static let getInstance = APICommunicator()

    let hostname = "http://localhost"
    let port = 8080
    let prefix = "/findme/api/"
    var url: String = ""
    
    enum Route : String {
        case user = "user/v1/"
        case login = "user/v1/login"
        case friendRequest = "friendrequest/v1/"
    }
    
    private init() {}
    
    func getBaseUrl() -> String {
        return hostname + ":" + String(port) + prefix
    }
    
    func generateRoute(route: String, parameters: Dictionary<String,String>?) -> NSURL {
        self.url = self.getBaseUrl() + route
        if parameters != nil {
            self.addParameters(parameters!)
        }
        
        return NSURL(string: url)!
    }
    
    func addParameters(params: Dictionary<String,String>) {
        var i = 0
        
        for (parameterName, parameterValue) in params {
            if i == 0 {
                url += "?"
            } else {
                url += "&"
            }
            
            url += parameterName + "=" + parameterValue
            i += 1
        }
    }
}