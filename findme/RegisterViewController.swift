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
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBAction func registerButton(sender: AnyObject) {
        let username:NSString = self.usernameField.text!
        let email:NSString = self.emailField.text!
        let password:NSString = self.passwordField.text!
        let confirm_password:NSString = self.confirmPasswordField.text!
        
        if (username.isEqualToString("") || email.isEqualToString("") || password.isEqualToString("")) {
            UIAlert("Sign Up Failed!", message: "Please enter Username and Password")
        } else if ( !password.isEqual(confirm_password) ) {
            UIAlert("Sign Up Failed!", message: "Passwords doesn't Match")
        } else {
            do {
                
                let post:NSString = "pseudo=\(username)&email=\(email)&password=\(password)&c_password=\(confirm_password)"
                
                NSLog("PostData: %@",post);
                
                let url:NSURL = NSURL(string: wsBaseUrl + "/user/v1/user")!
                
                let postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
                
                let postLength:NSString = String(postData.length)
                
                let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                request.HTTPBody = postData
                request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
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
                        
                        let jsonData:NSDictionary = try NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                        
                        
                        let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
                        
                        NSLog("Success: %ld", success);
                        
                        if(success == 1)
                        {
                            NSLog("Sign Up SUCCESS");
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            var error_msg:NSString
                            
                            if jsonData["error_message"] as? NSString != nil {
                                error_msg = jsonData["error_message"] as! NSString
                            } else {
                                error_msg = "Unknown Error"
                            }
                            UIAlert("Sign Up Failed!", message: error_msg as String)
                        }
                        
                    } else {
                        UIAlert("Sign Up Failed!", message: "Connection Failed")
                    }
                }  else {
                    UIAlert("Sign Up Failed!", message: "Connection Failure")
                }
            } catch {
                UIAlert("Sign Up Failed!", message: "Server Error!")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
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
