//
//  LoginViewController.swift
//  findme
//
//  Created by Maxime Signoret on 05/05/16.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    let wsBaseUrl = WSConnection.getInstance.getBaseUrl()
    let userAppSession = "user"
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    @IBAction func loginAction(sender: AnyObject) {
        let username:NSString = self.usernameField.text!
        let password:NSString = self.passwordField.text!
        
        if (username.isEqualToString("") || password.isEqualToString("")) {
            UIAlert("Sign in Failed!", message: "Please enter Username and Password")
        } else {
            do {
                let wsService = WSService()
                wsService.signIn(username, password: password, onCompletion: { user, err in
                    if user != nil {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        self.UIAlert("Sign in Failed!", message: "Wrong username or password")
                    }
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        //Get user in session
        let user = NSUserDefaults.standardUserDefaults().objectForKey(self.userAppSession)
        //No need login if user in session
        if user != nil {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MapViewController")
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo: [NSObject : AnyObject] = notification.userInfo!
        
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.view.frame.origin.y -= keyboardSize.height
                })
            }
        } else {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
        print(self.view.frame.origin.y)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    func UIAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        self.presentViewController(alert, animated: true){}
    }
}
