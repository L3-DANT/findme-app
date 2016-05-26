//
//  UserService.swift
//  findme
//
//  Created by Maxime Signoret on 26/05/16.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import Foundation

class userService {
    let phonePattern: String = "(0|(\\+33)|(0033))[1-9][0-9]{8}"

    func isValidPhoneNumber(phoneNumber: String) -> Bool {
        if phoneNumber.rangeOfString(self.phonePattern, options: .RegularExpressionSearch) != nil {
            return true
        }
        
        return false
    }
}
