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

    let hostname = "http://192.168.1.12"
    let port = 8080
    let prefix = "/findme/api"
    var url: String = ""
    
    private init() {}
    
    func getBaseUrl() -> String {
        return hostname + ":" + String(port) + prefix
    }
    
    func generateRoute(routeName: String) {
        url = hostname + routeName
    }
    
    func addParameters(parameters: Dictionary<String,String>) {
        var i = 0
        
        for (parameterName, parameterValue) in parameters {
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