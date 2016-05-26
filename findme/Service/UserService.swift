//
//  UserService.swift
//  findme
//
//  Created by Maxime Signoret on 26/05/16.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import Foundation

class UserService {
    static let phonePattern: String = "(0|(\\+33)|(0033))[1-9][0-9]{8}"

    static func isValidPhoneNumber(phoneNumber: String) -> Bool {
        if phoneNumber.rangeOfString(phonePattern, options: .RegularExpressionSearch) != nil {
            return true
        }
        
        return false
    }
}
