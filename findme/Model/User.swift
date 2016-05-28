//
//  User.swift
//  findme
//
//  Created by Nicolas Mercier on 13/04/2016.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import Foundation


class User {
    var pseudo: String = ""
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    var friendList: [User]?
    var phoneNumber: String = "000000000"
    var state: State = State.OFFLINE
    
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
    }
}
