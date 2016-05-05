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
                let params = "pseudo=\(username)&password=\(password)"
                let url:NSURL = NSURL(string: wsBaseUrl + "/user/v1/getUser?" + params)!
                let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "GET"
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                var reponseError: NSError?
                var response: NSURLResponse?
                
                var urlData: NSData?
                do {
                    urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
                } catch let error as NSError {
                    reponseError = error
                    urlData = nil
                }
                
                if (urlData != nil) {
                    let res = response as! NSHTTPURLResponse!;
                    
                    NSLog("Response code: %ld", res.statusCode);
                    
                    if (res.statusCode >= 200 && res.statusCode < 300)
                    {
                        let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                        
                        NSLog("Response ==> %@", responseData);
                        
                        //var error: NSError?
                        let jsonData:NSDictionary = try NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                        //let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
                        
                        //NSLog("Success: %ld", success);
                        
                        //if (success == 1) {
                        if (true) {
                            NSLog("Login SUCCESS");
                            
                            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                            prefs.setObject(username, forKey: "USERNAME")
                            prefs.setInteger(1, forKey: "ISLOGGEDIN")
                            prefs.synchronize()
                            
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            var error_msg:NSString
                            
                            if jsonData["error_message"] as? NSString != nil {
                                error_msg = jsonData["error_message"] as! NSString
                            } else {
                                error_msg = "Unknown Error"
                            }
                            UIAlert("Sign in Failed!", message: error_msg as String)
                        }
                    } else {
                        UIAlert("Sign in Failed!", message: "Connection Failed")
                    }
                } else {
                    UIAlert("Sign in Failed!", message: "Connection Failure")
                }
            } catch {
                UIAlert("Sign in Failed!", message: "Server Error")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    func UIAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        self.presentViewController(alert, animated: true){}
    }
}