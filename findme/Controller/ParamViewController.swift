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
    
    @IBOutlet weak var allowLocationSharing: UISwitch!
    let apiService = APIService()
    let userService = UserService()
    
    @IBAction func switchLocationSharing(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(allowLocationSharing.on, forKey: "allowSharing")
    }
    
    @IBAction func logoutTapped(sender: UIButton) {
        let currentUser: User = UserService.getUserInSession()
        currentUser.state = User.State.OFFLINE
        let jsonUser = JSONSerializer.toJson(currentUser)

        let apiService = APIService()
        apiService.updateUser(jsonUser, onCompletion: { user, err in
        })
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        let vc : UIViewController = (self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController)!
        self.showViewController(vc as UIViewController, sender: vc)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        
        navigationController!.navigationBar.barTintColor = UIColor(colorLiteralRed: 52/255, green: 73/255, blue: 94/255, alpha: 1.0)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        let locationAllowed: Bool? = NSUserDefaults.standardUserDefaults().boolForKey("allowSharing")
        allowLocationSharing.setOn(locationAllowed!, animated: false)
        
    }
    
    @IBAction func changePassword(sender: AnyObject) {
        let currentUser = UserService.getUserInSession()
        
        let alert = UIAlertController(title: "Change Password", message: "", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (newPassword) -> Void in })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action) -> Void in
            let newPassword = alert.textFields![0] as UITextField
            if( newPassword.text != ""){
                currentUser.password = newPassword.text
                let jsonUser = JSONSerializer.toJson(currentUser)
                self.apiService.updateUser(jsonUser, onCompletion: { data in
                    
                })
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func changePhoneNumber(sender: AnyObject) {
        let currentUser = UserService.getUserInSession()
        
        let alert = UIAlertController(title: "Change Phone Number", message: "enter your new phone number", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            if(textField != ""){
                currentUser.phoneNumber = textField.text!
                let jsonUser = JSONSerializer.toJson(currentUser)
                self.apiService.updateUser(jsonUser, onCompletion: { data in
                    
                })
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteAccount(sender: AnyObject) {
        let currentUser = UserService.getUserInSession()
        
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your awesome account ?", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action) -> Void in
            self.apiService.deleteUser(currentUser.pseudo, onCompletion: { err in
                if err == nil{
                    let vc : UIViewController = (self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController)!
                    self.showViewController(vc as UIViewController, sender: vc)
                }
            })
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func newPhoneNumber(phoneNumber : String){
        
    }
    
    func newPassword(password: String){
        
    }
    
}
