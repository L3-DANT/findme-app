//
//  WSConnection.swift
//  findme
//
//  Created by Maxime Signoret on 05/05/16.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import Foundation


class WSConnection {
    static let getInstance = WSConnection()

    let url = "http://localhost"
    let port = 8080
    let prefix = "/findme/api"
    
    private init() {}
    
    func getBaseUrl() -> String {
        return url + ":" + String(port) + prefix
    }
}