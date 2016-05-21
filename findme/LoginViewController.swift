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
    
    @IBOutlet weak var findMeIntroView: UIImageView!
    @IBOutlet weak var pulseView: UIImageView!
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
            let vc : UIViewController = (self.storyboard!.instantiateViewControllerWithIdentifier("MapViewController") as? MapViewController)!
            self.showViewController(vc as UIViewController, sender: vc)
        }
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
        
        self.findMeIntroView.animationImages = imageList
        
        startAniamtion()
    }
    
    func startAniamtion(){
        self.findMeIntroView.animationDuration = 2
        self.findMeIntroView.animationRepeatCount = 1
        self.findMeIntroView.startAnimating()
        _ = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(self.startPulse), userInfo: nil, repeats: false)
    }
    
    func startPulse(){
        let pulseEffect = PulseAnimation(repeatCount: Float.infinity, radius:100, position: self.pulseView.center)
        pulseEffect.backgroundColor = UIColor(colorLiteralRed: 0.33, green: 0.69, blue: 0.69, alpha: 1).CGColor
        view.layer.insertSublayer(pulseEffect, below: self.findMeIntroView.layer)
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
