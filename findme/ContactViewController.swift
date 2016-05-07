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

class ContactViewController: UITableViewController, NSURLConnectionDelegate{

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
            users.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
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
        let feedUrl = "http://localhost:8080/findme/api/user/fixtures"
        
        let request = NSURLRequest(URL: NSURL(string: feedUrl)!)
        
        self.users = []
        
        NSURLConnection.sendAsynchronousRequest(request,queue: NSOperationQueue.mainQueue()) {
            response, data, error in if let jsonData = data,
            json = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers)) as? [NSDictionary]{
                for user : NSDictionary in json{
                    let name = user["pseudo"] as? String
                    let password = user["password"] as? String
                    let x = user["x"] as? Double
                    let y = user["y"] as? Double
                    let friendList = user["friendList"] as? [User]
                    let jsonUser = User(pseudo: name!, x: x!, y: y!, password: password!, friendList: friendList!)
                    self.users.append(jsonUser)
                }
                
                //Vu que c'est asynchrone on doit reload le tableau dans la closure !
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.friendsTable.reloadData()
                    
                    // Masquer l'icône de chargement dans la barre de status
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                })
            }
        }
    }
}
