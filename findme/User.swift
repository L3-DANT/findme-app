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
    var x : Double
    var y : Double
    var friendList : [User]?
    var password : String
    
    init(pseudo : String, x : Double, y : Double, password : String, friendList :[User]){
        self.pseudo = pseudo
        self.x = x
        self.y = y
        self.password = password
        self.friendList = friendList
    }
}