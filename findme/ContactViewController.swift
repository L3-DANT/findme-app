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
    
    var users : [User] = []

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        
        loadUsers()
        
        navigationController!.navigationBar.barTintColor = UIColor(colorLiteralRed: 52/255, green: 73/255, blue: 94/255, alpha: 1.0)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        loadUsers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        print("Row: \(row)")
        
        //print(meetingArray[row] as! String)
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = "\(self.users[indexPath.row].pseudo)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // Add method to remove friend server side
            users.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        if editingStyle == UITableViewCellEditingStyle.Insert {
            // Fix with true sms number
            let number = "sms:+33667479299"
            UIApplication.sharedApplication().openURL(NSURL(string: number)!)
        }
        if editingStyle == UITableViewCellEditingStyle.None {
            let url = NSURL(string: "tel://0667479299")
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
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
    }
    
    func loadUsers(){
        
        self.users = []
        
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var dataTask: NSURLSessionDataTask?
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8080/findme/api/user/v1/users")!)
        request.HTTPMethod = "GET"
        
        dataTask = defaultSession.dataTaskWithRequest(request) {
            data, response, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
            do{
                if let error = error {
                    print(error.localizedDescription)
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    print(httpResponse.statusCode)
                    if httpResponse.statusCode == 200 {
                        if self.navigationController != nil
                        {
                            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [NSDictionary] {
                                dispatch_async(dispatch_get_main_queue(), {
                                    for user : NSDictionary in jsonResult{
                                        let name = user["pseudo"] as? String
                                        let latitude = user["latitude"] as? Double
                                        let longitude = user["longitude"] as? Double
                                        let friendList = user["friendList"] as? [User]
                                        let phoneNumber = user["phoneNumber"] as? String
                                        let jsonUser = User(pseudo: name!, latitude: latitude!, longitude: longitude!, friendList: friendList!, phoneNumber : phoneNumber!)
                                        self.users.append(jsonUser)
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
    }
}
