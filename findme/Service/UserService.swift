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

    static func getUserInSession() -> User {
        let serializedUser: [String:AnyObject] = NSUserDefaults.standardUserDefaults().objectForKey(UserService.userAppSession) as! [String : AnyObject]
        
        return unserializeJsonResponse(serializedUser)
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
        let state = User.State(rawValue: response["state"] as! String)!
        let friends = response["friendList"] as? [NSDictionary]
        var friendList : [User] = []
        
        for friend in friends! as [NSDictionary] {
            let friendName = friend["pseudo"] as! String
            let friendLatitude = friend["latitude"] as! Double
            let friendLongitude = friend["longitude"] as! Double
            let friendPhoneNumber = friend["phoneNumber"] as! String
            let friendState = User.State(rawValue: friend["state"] as! String)!
            
            friendList.append(User(pseudo: friendName, latitude: friendLatitude, longitude: friendLongitude, phoneNumber: friendPhoneNumber, state: friendState))
        }
        
        return User(pseudo: name, latitude: latitude, longitude: longitude, phoneNumber: phoneNumber, state: state as User.State, friendList: friendList)
    }
    
    static func deleteFriend(username: String) {
        var i: Int = 0
        let user = UserService.getUserInSession()
        
        for friend in user.friendList! {
            if friend.pseudo == username {
                user.friendList!.removeAtIndex(i)
                break
            }
            i += 1
        }
    }
    
    static func isValidPhoneNumber(phoneNumber: String) -> Bool {
        if phoneNumber.rangeOfString(phonePattern, options: .RegularExpressionSearch) != nil {
            return true
        }
        
        return false
    }
}
