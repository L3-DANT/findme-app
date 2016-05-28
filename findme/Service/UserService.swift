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
    static let userAppSession = "user"
    
    static func hasUserInSession() -> Bool {
        return NSUserDefaults.standardUserDefaults().objectForKey(UserService.userAppSession) != nil ? true : false
    }

    static func getUserInSession() -> AnyObject {
        return NSUserDefaults.standardUserDefaults().objectForKey(UserService.userAppSession)!
    }
    
    static func setUserInSession(serializedUser: [String:AnyObject]) {
        let userSession = NSUserDefaults.standardUserDefaults()
        userSession.setObject(serializedUser, forKey: UserService.userAppSession)
        userSession.synchronize()
    }
    
    static func unserializeJsonResponse(response: [String:AnyObject]) -> User {
        let name = response["pseudo"] as! String
        let latitude = response["latitude"] as! Double
        let longitude = response["longitude"] as! Double
        let phoneNumber = response["phoneNumber"] as! String
        let friends = response["friendList"] as? [NSDictionary]
        var friendList : [User] = []
        
        for friend in friends! as [NSDictionary] {
            let friendName = friend["pseudo"] as! String
            let friendLatitude = friend["latitude"] as! Double
            let friendLongitude = friend["longitude"] as! Double
            let friendPhoneNumber = friend["phoneNumber"] as! String
            
            friendList.append(User(pseudo: friendName, latitude: friendLatitude, longitude: friendLongitude, phoneNumber: friendPhoneNumber))
        }
        
        return User(pseudo: name, latitude: latitude, longitude: longitude, friendList: friendList, phoneNumber: phoneNumber)
    }
    
    static func isValidPhoneNumber(phoneNumber: String) -> Bool {
        if phoneNumber.rangeOfString(phonePattern, options: .RegularExpressionSearch) != nil {
            return true
        }
        
        return false
    }
}
