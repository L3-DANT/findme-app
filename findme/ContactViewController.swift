//
//  ContactViewController.swift
//  findme
//
//  Created by Nicolas Mercier on 16/03/2016.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ContactViewController: UITableViewController, NSURLConnectionDelegate {
    @IBOutlet var friendsTable: UITableView!
    
    
    var items : [[String]] = [[],[],[]]

    let sections : [String] = ["Incoming Requests", "Request sended", "Friends"]
    
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var dataTask: NSURLSessionDataTask?
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        
        navigationController!.navigationBar.barTintColor = UIColor(colorLiteralRed: 52/255, green: 73/255, blue: 94/255, alpha: 1.0)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        loadItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @IBAction func addFriend(sender: AnyObject) {
        let alert = UIAlertController(title: "Add Friend", message: "Enter the name of the friend you want to add", preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Add", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.sendFriendRequest(textField.text!)
        }))
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        print("Row: \(row)")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.items[section].count > 0 ? sections[section] : nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = "\(self.items[indexPath.section][indexPath.row])"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // Add method to remove friend server side
            items.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        if editingStyle == UITableViewCellEditingStyle.Insert {
            // Fix with true sms number
            let number = "sms:+33667479299"
            UIApplication.sharedApplication().openURL(NSURL(string: number)!)
        }
        
        
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if (indexPath.section == 0){
            let accept = UITableViewRowAction(style: .Default, title: "Accept", handler: { (action:UITableViewRowAction!, indexPath: NSIndexPath) -> Void in
                
                let acceptMenu = UIAlertController(title: nil, message: "Accept Friend request from \(self.items[indexPath.section][indexPath.row]) ?", preferredStyle: .Alert)
                
                let acceptAction = UIAlertAction(title: "Accept", style: .Default, handler: {(alert: UIAlertAction!) in self.acceptFriendRequest(indexPath)})
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                
                acceptMenu.addAction(acceptAction)
                acceptMenu.addAction(cancelAction)
                
                self.presentViewController(acceptMenu, animated : true, completion : nil)
            })
            
            accept.backgroundColor = UIColor.greenColor()
            
            let decline = UITableViewRowAction(style: .Normal, title: "Decline") { action, index in
                let declineMenu = UIAlertController(title: nil, message: "Decline Friend request from \(self.items[indexPath.section][indexPath.row]) ?", preferredStyle: .Alert)
                
                let declineAction = UIAlertAction(title: "Decline", style: .Default, handler: {(alert: UIAlertAction!) in self.declineFriendRequest(indexPath)})
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                
                declineMenu.addAction(declineAction)
                declineMenu.addAction(cancelAction)
                
                self.presentViewController(declineMenu, animated : true, completion : nil)
            }
            
            decline.backgroundColor = UIColor.redColor()
            
            return [decline, accept]
        } else if(indexPath.section == 2){
            let sms = UITableViewRowAction(style: .Default, title: "\u{2606}\n Sms") { action, index in
                print("sms button tapped")
                self.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.Insert, forRowAtIndexPath: indexPath)
            }
            
            sms.backgroundColor = UIColor.blueColor()
            
            let call = UITableViewRowAction(style: .Normal, title: "\u{2605}\n Call") { action, index in
                print("call button tapped")
                self.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.None, forRowAtIndexPath: indexPath)
            }
            
            call.backgroundColor = UIColor.greenColor()
            
            let delete = UITableViewRowAction(style: .Default, title: "\u{267A}\n Delete") { action, index in
                print("delete button tapped")
                self.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
            }
            
            delete.backgroundColor = UIColor.redColor()
            
            return [delete, sms, call]
        } else {
            let cancel = UITableViewRowAction(style: .Default, title: "Cancel") { action, index in
                let cancelMenu = UIAlertController(title: nil, message: "Cancel Friend request from \(self.items[indexPath.section][indexPath.row]) ?", preferredStyle: .Alert)
                
                let acceptAction = UIAlertAction(title: "Yes", style: .Default, handler: {(alert: UIAlertAction!) in self.cancelFriendRequest(indexPath)})
                let cancelAction = UIAlertAction(title: "No", style: .Cancel, handler: nil)
                
                cancelMenu.addAction(acceptAction)
                cancelMenu.addAction(cancelAction)
                
                self.presentViewController(cancelMenu, animated : true, completion : nil)
            }
            
            cancel.backgroundColor = UIColor.darkGrayColor()

            return [cancel]
        }
    }
    
    func loadItems() {
        loadUsers()
        loadAsked()
        loadReceived()
    }
    
        
    func loadUsers(){
        self.items[2] = []
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        //TODO change with username in memory
        let pseudo = "Nicolas"
        
        let wsService = WSService()
        wsService.getUser(pseudo, onCompletion: { user, err in
            if user != nil && user?.friendList != nil {
                for friend in user!.friendList!{
                    self.items[2].append(friend.pseudo)
                }
                self.friendsTable.reloadData()
            }
        })
    }
    
    func loadAsked(){
        self.items[1] = []
        
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8080/findme/api/friendrequest/v1?caller=Nicolas")!)
        request.HTTPMethod = "GET"
        
        
        dataTask = defaultSession.dataTaskWithRequest(request) {
            data, response, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
            do {
                if let error = error {
                    print(error.localizedDescription)
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if (httpResponse.statusCode >= 200 && httpResponse.statusCode <= 300) {
                        print(httpResponse.statusCode)
                        if self.navigationController != nil
                        {
                            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String] {
                                dispatch_async(dispatch_get_main_queue(), {
                                    for user : String in jsonResult{
                                        self.items[1].append(user)
                                    }
                                    self.friendsTable.reloadData()
                                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                                })
                            }
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        dataTask?.resume()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func loadReceived(){
        self.items[0] = []
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var dataTask: NSURLSessionDataTask?
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8080/findme/api/friendrequest/v1?receiver=Nicolas")!)
        request.HTTPMethod = "GET"
        
        
        dataTask = defaultSession.dataTaskWithRequest(request) {
            data, response, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
            do {
                if let error = error {
                    print(error.localizedDescription)
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if (httpResponse.statusCode >= 200 && httpResponse.statusCode <= 300) {
                        print(httpResponse.statusCode)
                        if self.navigationController != nil
                        {
                            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String] {
                                dispatch_async(dispatch_get_main_queue(), {
                                    for user : String in jsonResult{
                                        self.items[0].append(user)
                                    }
                                    self.friendsTable.reloadData()
                                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                                })
                            }
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        dataTask?.resume()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    
    func acceptFriendRequest(indexPath : NSIndexPath){
        let caller = items[indexPath.section][indexPath.row]
        //TODO change for logged user
        let receiver = "Nicolas"
        
        let friendrequest = ["caller" : caller, "receiver" : receiver]
        
        let wsService = WSService()
        wsService.acceptFriendRequest(friendrequest, onCompletion: { err in
            self.loadItems()
        })
    }
    
    func cancelFriendRequest(indexPath : NSIndexPath){
        let receiver = items[indexPath.section][indexPath.row]
        //TODO change for logged user
        let caller = "Nicolas"
    
        let wsService = WSService()
        wsService.deleteFriendRequest(caller, receiver : receiver, onCompletion: { err in
            self.loadItems()
        })

    }
    
    func declineFriendRequest(indexPath : NSIndexPath){
        let caller = items[indexPath.section][indexPath.row]
        //TODO change for logged user
        let receiver = "Nicolas"
        
        let wsService = WSService()
        wsService.deleteFriendRequest(caller, receiver : receiver, onCompletion: { err in
            self.loadItems()
        })

    }
    
    func sendFriendRequest(name : String){
        //TODO change for logged in user name
        let friendRequest = ["caller" :  "Nicolas", "receiver" : name]
        
        let wsService = WSService()
        wsService.sendFriendRequest(friendRequest, onCompletion: { err in
            self.loadItems()
        })
    }
    
}
