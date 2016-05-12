//
//  User.swift
//  findme
//
//  Created by Nicolas Mercier on 13/04/2016.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import Foundation


class User {
    var pseudo : String = ""
    var longitude : Double = 0.0
    var latitude : Double = 0.0
    var friendList : [User]?
    var phoneNumber : String = "000000000"
    
    init(pseudo : String, latitude : Double, longitude : Double, friendList :[User], phoneNumber : String){
        self.pseudo = pseudo
        self.longitude = longitude
        self.latitude = latitude
        self.friendList = friendList
        self.phoneNumber = phoneNumber
    }
}