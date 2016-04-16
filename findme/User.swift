//
//  User.swift
//  findme
//
//  Created by Nicolas Mercier on 13/04/2016.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import Foundation


class User {
    var pseudo : String
    var x : Float
    var y : Float
    var friendList : [User]?
    var password : String
    
    init(pseudo : String, x : Float, y : Float, password : String, friendList :[User]){
        self.pseudo = pseudo
        self.x = x
        self.y = y
        self.password = password
        self.friendList = friendList
    }
}