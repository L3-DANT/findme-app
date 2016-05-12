//
//  AddFriendController.swift
//  findme
//
//  Created by Nicolas Mercier on 13/04/2016.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import UIKit

class AddFriendController : UIViewController{
    
    @IBOutlet weak var receiver: UITextField!
    var user:User = User()
    
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var dataTask: NSURLSessionDataTask?
    
    @IBAction func addFriend(sender: AnyObject) {
        self.user.pseudo = "Nicolas"
        let friendRequest = ["caller" : self.user.pseudo, "receiver" : self.receiver.text!] as Dictionary<String, String>
        sendFriendRequest(friendRequest)
    }
    
    
    func sendFriendRequest(friendRequest : NSDictionary) {
        dismissKeyboard()
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8080/findme/api/friendrequest/v1/create")!)
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(friendRequest, options: NSJSONWritingOptions.PrettyPrinted)
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "PUT"
        
        dataTask = defaultSession.dataTaskWithRequest(request) {
            data, response, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                print(httpResponse.statusCode)
                if httpResponse.statusCode == 200 {
                    if let navigationController = self.navigationController
                    {
                        navigationController.popViewControllerAnimated(true)
                    }
                }
                //TODO autres status
            }
        }
        dataTask?.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }


}



