//
//  ConnectionSettings.swift
//  findme
//
//  Created by Maxime Signoret on 17/03/16.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

public struct ConnectionSettings {
    
    static var clientId = "yA0ac1klHaXYDJ5HPHN4sVVxpX1Vem1A"
    static var clientSecret = "zJA8WNmmxe4UXR0G"
    static var apiBaseUrl = "http://localhost:8080"
    
    public static func apiURLWithPathComponents(components: String) -> String {
        return ConnectionSettings.apiBaseUrl
    }
}
