//
//  RegisterViewController.swift
//  findme
//
//  Created by Maxime Signoret on 05/05/16.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    let wsBaseUrl = APICommunicator.getInstance.getBaseUrl()
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var pulseView: UIImageView!
    
    @IBOutlet weak var registerAnimationView: UIImageView!
    
    @IBAction func registerButton(sender: AnyObject) {
        let username:NSString = self.usernameField.text!
        let phoneNumber:NSString = self.phoneNumberField.text!
        let password:NSString = self.passwordField.text!
        let confirm_password:NSString = self.confirmPasswordField.text!
        
        if (username.isEqualToString("") || phoneNumber.isEqualToString("") || password.isEqualToString("") || confirm_password.isEqualToString("")) {
            UIAlert("Sign Up Failed!", message: "Please enter Username and Password")
        } else if ( !password.isEqual(confirm_password) ) {
            UIAlert("Sign Up Failed!", message: "Passwords doesn't Match")
        }
        
        if (!checkPhoneNumber(phoneNumber as String)) {
            UIAlert("Sign Up Failed!", message: "Invalid phone number")
        } else {
            do {
                let apiService = APIService()
                apiService.signUp(username, phoneNumber: phoneNumber, password: password, confirmPassword: confirm_password, onCompletion: { user, err in
                    dispatch_async(dispatch_get_main_queue()) {
                        if user != nil {
                            let vc : UIViewController = (self.storyboard!.instantiateViewControllerWithIdentifier("MapViewController") as? MapViewController)!
                            self.showViewController(vc as UIViewController, sender: vc)
                        } else {
                            self.UIAlert("Sign Up Failed!", message: "Wrong username or password")
                        }
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
        var imageName : String = ""
        
        var imageList : [UIImage] = []
        
        
        for i in 0...9 {
            imageName =  "FindMe_intro_0000\(i)"
            imageList.append(UIImage(named: imageName)!)
        }
        for i in 10...69 {
            imageName =  "FindMe_intro_000\(i)"
            imageList.append(UIImage(named: imageName)!)
        }

        
        self.registerAnimationView.animationImages = imageList
        
        startAniamtion()
    }
    
    func checkPhoneNumber(phoneNumber: String) -> Bool {
        let PHONE_REGEX = "(0|(\\+33)|(0033))[1-9][0-9]{8}"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluateWithObject(phoneNumber)
        
        return result
    }
    
    func startAniamtion(){
        self.registerAnimationView.animationDuration = 2
        self.registerAnimationView.animationRepeatCount = 1
        self.registerAnimationView.startAnimating()
        _ = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(self.startPulse), userInfo: nil, repeats: false)
    }
    
    func startPulse(){
        let pulseEffect = PulseAnimation(repeatCount: Float.infinity, radius:100, position: CGPoint(x: self.pulseView.center.x-72, y: self.pulseView.center.y-20))
        pulseEffect.backgroundColor = UIColor(colorLiteralRed: 0.33, green: 0.69, blue: 0.69, alpha: 1).CGColor
        view.layer.insertSublayer(pulseEffect, below: self.registerAnimationView.layer)
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

