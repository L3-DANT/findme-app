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
    
    let apiService = APIService()
    var user: User = UserService.getUserInSession()
    var items: [[String]] = [[],[],[]]
    let sections: [String] = ["Incoming Requests", "Outgoing Requests", "Friends"]
    var state : [String] = []
    
    internal enum UITableViewCellEditingStyle : Int {
        case Delete
        case Sms
        case Call
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        
        self.apiService.getUser(self.user.pseudo, onCompletion: { user, err in
            dispatch_async(dispatch_get_main_queue()) {
                if user != nil {
                    self.user = user!
                }
            }
        })
        
        navigationController!.navigationBar.barTintColor = UIColor(colorLiteralRed: 52/255, green: 73/255, blue: 94/255, alpha: 1.0)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()

    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadItems()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @IBAction func addFriend(sender: AnyObject) {
        let alert = UIAlertController(title: "Add Friend", message: "Enter the name of the friend you want to add", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.sendFriendRequest(textField.text!)
        }))
        
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
        
        if indexPath.section == 0 {
            cell.imageView!.image = UIImage(named: "incoming")
        } else if indexPath.section == 1 {
            cell.imageView!.image = UIImage(named: "outgoing")
        } else {
            cell.imageView!.image = UIImage(named: self.state[indexPath.row])
        }
        

        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            items.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        if editingStyle == UITableViewCellEditingStyle.Sms {
            let number = "sms:" + self.user.friendList![indexPath.row].phoneNumber
            UIApplication.sharedApplication().openURL(NSURL(string: number)!)
        }
        if editingStyle == UITableViewCellEditingStyle.Call {
            let number = "tel:" + self.user.friendList![indexPath.row].phoneNumber
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
            
            accept.backgroundColor = UIColor(colorLiteralRed: 0.1529, green: 0.6823, blue: 0.3764, alpha: 1.0)
            
            let decline = UITableViewRowAction(style: .Normal, title: "Decline") { action, index in
                let declineMenu = UIAlertController(title: nil, message: "Decline Friend request from \(self.items[indexPath.section][indexPath.row]) ?", preferredStyle: .Alert)
                
                let declineAction = UIAlertAction(title: "Decline", style: .Default, handler: {(alert: UIAlertAction!) in self.declineFriendRequest(indexPath.section, row: indexPath.row)})
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                
                declineMenu.addAction(declineAction)
                declineMenu.addAction(cancelAction)
                
                self.presentViewController(declineMenu, animated : true, completion : nil)
            }
            
            decline.backgroundColor = UIColor(colorLiteralRed: 0.7529, green: 0.2235, blue: 0.1686, alpha: 1.0)
            
            return [decline, accept]
        } else if(indexPath.section == 2){
            let sms = UITableViewRowAction(style: .Default, title: "Sms") { action, index in
                print("sms button tapped")
                self.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.Sms, forRowAtIndexPath: indexPath)
            }
            
            sms.backgroundColor = UIColor(colorLiteralRed: 0.9450, green: 0.7686, blue: 0.0588, alpha: 1.0)
            
            let call = UITableViewRowAction(style: .Normal, title: "Call") { action, index in
                print("call button tapped")
                self.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.Call, forRowAtIndexPath: indexPath)
            }
            
            call.backgroundColor = UIColor(colorLiteralRed: 0.1529, green: 0.6823, blue: 0.3764, alpha: 1.0)
            
            let delete = UITableViewRowAction(style: .Default, title: "Delete") { action, index in
                let deleteMenu = UIAlertController(title: nil, message: "Remove \(self.items[indexPath.section][indexPath.row]) from your friend list ?", preferredStyle: .Alert)
                
                let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {(alert: UIAlertAction!) in self.deleteFriend(indexPath)})
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                
                deleteMenu.addAction(deleteAction)
                deleteMenu.addAction(cancelAction)
                
                self.presentViewController(deleteMenu, animated : true, completion : nil)
            }
            
            delete.backgroundColor = UIColor(colorLiteralRed: 0.7529, green: 0.2235, blue: 0.1686, alpha: 1.0)
            
            return [delete, sms, call]
        } else {
            let cancel = UITableViewRowAction(style: .Default, title: "Cancel") { action, index in
                let cancelMenu = UIAlertController(title: nil, message: "Cancel Friend request from \(self.items[indexPath.section][indexPath.row]) ?", preferredStyle: .Alert)
                
                let acceptAction = UIAlertAction(title: "Yes", style: .Default, handler: {(alert: UIAlertAction!) in self.cancelFriendRequest(indexPath.section, row: indexPath.row)})
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
        self.items = [[],[],[]]
        self.apiService.getUser(self.user.pseudo, onCompletion: { user, err in
            dispatch_async(dispatch_get_main_queue()) {
                if user != nil {
                    self.user = user!
                }
                self.loadUsers()
                self.loadAsked()
                self.loadReceived()
            }
        })
    }
    
    
    func loadUsers() {
        self.items[2] = []
        
        for friend in self.user.friendList! {
            self.items[2].append(friend.pseudo)
            self.state.append(friend.state.rawValue)
        }
        
        self.friendsTable.reloadData()
    }
    
    func loadAsked() {
        self.items[1] = []
        let params: [String:String] = ["caller": self.user.pseudo]
        
        self.apiService.getFriendRequest(params, onCompletion: { users, err in
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if users != nil {
                    if self.navigationController != nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            for user in users! {
                                self.items[1].append(String(user))
                            }
                            
                            self.friendsTable.reloadData()
                        }
                    }
                }
            }
        })
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func loadReceived() {
        self.items[0] = []
        let params: [String:String] = ["receiver": self.user.pseudo]
        
        self.apiService.getFriendRequest(params, onCompletion: { users, err in
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if users != nil {
                    if self.navigationController != nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            for user in users! {
                                self.items[0].append(String(user))
                            }
                            
                            self.friendsTable.reloadData()
                        }
                    }
                }
            }
        })
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func acceptFriendRequest(indexPath : NSIndexPath){
        let caller = items[indexPath.section][indexPath.row]
        let receiver = self.user.pseudo
        
        let friendRequest = ["caller" : caller, "receiver" : receiver]
        
        self.apiService.acceptFriendRequest(friendRequest, onCompletion: { err in
            dispatch_async(dispatch_get_main_queue()) {
                let user = User()
                user.pseudo = caller
                self.user.friendList?.append(user)
                self.loadItems()
            }
        })
    }
    
    func cancelFriendRequest(section: Int, row: Int) {
        let params: [String:String] = ["caller": self.user.pseudo, "receiver": self.items[section][row]]
        self.apiService.deleteFriendRequest(params, onCompletion: { err in
            dispatch_async(dispatch_get_main_queue()) {
                self.loadItems()
            }
        })
    }
    
    func declineFriendRequest(section: Int, row: Int) {
        let params: [String:String] = ["caller": self.items[section][row], "receiver": self.user.pseudo]
        self.apiService.deleteFriendRequest(params, onCompletion: { err in
            dispatch_async(dispatch_get_main_queue()) {
                self.loadItems()
            }
        })
    }
    
    func deleteFriend(indexPath : NSIndexPath) {
        let user = UserService.deleteFriend(self.items[indexPath.section][indexPath.row])
        let jsonUser = JSONSerializer.toJson(user)
        self.apiService.updateUser(jsonUser, onCompletion: { user, err in
            dispatch_async(dispatch_get_main_queue()) {
                if user != nil {
                    self.user = UserService.getUserInSession()
                    self.loadItems()
                }
            }
        })
    }
    
    func sendFriendRequest(name : String) {
        var error = false;
        
        for friendName in self.items[0]{
            if friendName == name {
                self.dispatchAlert("\(name) already sent you a friend request.")
                error = true
            }
        }
        
        if error == false {
            for friendName in items[1]{
                if friendName == name{
                    self.dispatchAlert("You already sent a friend request to \(name).")
                    error = true
                }
            }
        }
        
        if error == false {
            for friendName in items[2]{
                if friendName == name {
                    self.dispatchAlert("\(name) is already in your friendList.")
                    error = true
                }
            }
        }
        
        if error == false {
            let friendRequest = ["caller": self.user.pseudo, "receiver": name]
            let apiService = APIService()
            apiService.sendFriendRequest(friendRequest, onCompletion: { err in
                dispatch_async(dispatch_get_main_queue()) {
                    if err != nil {
                        self.dispatchAlert("\(name) account does not exist.")
                    } else {
                        self.dispatchAlert("\(name) successfully add.", title: "Success")
                        self.loadItems()
                    }
                }
            })
        }
    }
    
    func dispatchAlert(message: String, title:String = "Warning") -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated : true, completion : nil)
    }
}
