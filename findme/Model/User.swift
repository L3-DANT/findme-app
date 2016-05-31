//
//  User.swift
//  findme
//
//  Created by Nicolas Mercier on 13/04/2016.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import Foundation


class User {
    var pseudo: String = String()
    var longitude: Double = Double()
    var latitude: Double = Double()
    var friendList: [User]?
    var phoneNumber: String = String()
    var state: State = State.OFFLINE
    var password : String? = nil
    
    enum State : String {
        case ONLINE = "ONLINE"
        case AWAY = "AWAY"
        case OFFLINE = "OFFLINE"
    }

    init() {}

    init(pseudo: String, latitude: Double, longitude: Double, phoneNumber: String, state: State, friendList: [User] = []) {
        self.pseudo = pseudo
        self.longitude = longitude
        self.latitude = latitude
        self.friendList = friendList
        self.phoneNumber = phoneNumber
        self.state = state
    }
}
