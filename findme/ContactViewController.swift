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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        print("Row: \(row)")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
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
        if editingStyle == UITableViewCellEditingStyle.None {
            let url = NSURL(string: "tel://0667479299")
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if (indexPath.section == 0){
            let accept = UITableViewRowAction(style: .Default, title: "Accept") { action, index in
                print("accept button tapped")
                self.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.Insert, forRowAtIndexPath: indexPath)
            }
            
            accept.backgroundColor = UIColor.greenColor()
            
            let decline = UITableViewRowAction(style: .Normal, title: "Decline") { action, index in
                print("decline button tapped")
                self.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.None, forRowAtIndexPath: indexPath)
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
                print("cancel button tapped")
                self.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.Insert, forRowAtIndexPath: indexPath)
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
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var dataTask: NSURLSessionDataTask?
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8080/findme/api/user/fixtures")!)
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
                    if httpResponse.statusCode == 200 {
                        if self.navigationController != nil
                        {
                            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [NSDictionary] {
                                dispatch_async(dispatch_get_main_queue(), {
                                    for user : NSDictionary in jsonResult{
                                        let name = user["pseudo"] as? String
                                        self.items[2].append(name!)
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
    
    func loadAsked(){
        self.items[1] = []
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var dataTask: NSURLSessionDataTask?
        
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
                    if httpResponse.statusCode == 200 {
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
                    if httpResponse.statusCode == 200 {
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
}
