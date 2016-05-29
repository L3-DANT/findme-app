//
//  ParamViewController.swift
//  findme
//
//  Created by Nicolas Mercier on 16/03/2016.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ParamViewController: UITableViewController {
    
    @IBAction func logoutTapped(sender: UIButton) {
        let currentUser: User = UserService.getUserInSession()
        currentUser.state = User.State.OFFLINE
        let dictUser = currentUser.toDict()
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        let apiService = APIService()
        apiService.updateUser(dictUser, onCompletion: { user, err in
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        
        navigationController!.navigationBar.barTintColor = UIColor(colorLiteralRed: 52/255, green: 73/255, blue: 94/255, alpha: 1.0)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
    }
}
