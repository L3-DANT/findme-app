//
//  RegisterViewController.swift
//  findme
//
//  Created by Maxime Signoret on 05/05/16.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    let wsBaseUrl = WSConnection.getInstance.getBaseUrl()
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBAction func registerButton(sender: AnyObject) {
        let username:NSString = self.usernameField.text!
        let phoneNumber:NSString = self.phoneNumberField.text!
        let password:NSString = self.passwordField.text!
        let confirm_password:NSString = self.confirmPasswordField.text!
        
        if (username.isEqualToString("") || phoneNumber.isEqualToString("") || password.isEqualToString("") || confirm_password.isEqualToString("")) {
            UIAlert("Sign Up Failed!", message: "Please enter Username and Password")
        } else if ( !password.isEqual(confirm_password) ) {
            UIAlert("Sign Up Failed!", message: "Passwords doesn't Match")
        } else {
            do {
                let wsService = WSService()
                wsService.signUp(username, phoneNumber: phoneNumber, password: password, confirmPassword: confirm_password, onCompletion: { user, err in
                    if user != nil {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        self.UIAlert("Sign Up Failed!", message: "Wrong username or password")
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
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
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
    
    func UIAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        self.presentViewController(alert, animated: true){}
    }
}

