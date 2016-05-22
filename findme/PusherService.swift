//
//  PusherService.swift
//  findme
//
//  Created by Nicolas Mercier on 22/05/2016.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import PusherSwift

public class PusherService{
    
    init(){
        let request = {(urlRequest:NSMutableURLRequest) -> NSMutableURLRequest in
            urlRequest.setValue("token", forHTTPHeaderField: "Authorization")
            return urlRequest
        }
        
        let pusher = Pusher(
            key: "APP_KEY",
            options: [
                "authEndpoint": "http://localhost:9292/pusher/",
                "authRequestCustomizer": request,
                "encrypted": true
            ]
        )
        
        pusher.connect()
    }
}