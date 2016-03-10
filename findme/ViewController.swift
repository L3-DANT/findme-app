//
//  ViewController.swift
//  findme
//
//  Created by Maxime Signoret on 05/03/16.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var menuExpanded = false
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchIcon: UITextField!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var paramButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var findMeButton: UIButton!
    
    @IBAction func showSearchBar(sender: AnyObject) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        presentViewController(searchController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSearchField()
        initButton(menuButton, icon: "fa-plus")
        initButton(paramButton, icon:"fa-cogs")
        initButton(contactButton, icon:"fa-users")
        initButton(findMeButton, icon:"fa-street-view")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initButton(button:UIButton, icon:String){
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.fontAwesomeOfSize(25)
        button.setTitle(String.fontAwesomeIconWithCode(icon), forState: .Normal)
    }
    
    func initSearchField(){
        let paddingView = UIView(frame: CGRectMake(0, 0, 25, self.searchTextField.frame.height))
        searchTextField.leftView = paddingView
        searchTextField.leftViewMode = UITextFieldViewMode.Always
        searchIcon.font = UIFont.fontAwesomeOfSize(15)
        searchIcon.text = String.fontAwesomeIconWithName(.Search)
    }

    //MARK: UISearchBar Delegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        //1
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        //2
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        }
    }
    
    @IBAction func showMenu(sender: AnyObject) {
        if menuExpanded == false{
            rotateMenuButton()
            showButtons()
            menuExpanded = true
        }
        else{
            rotateMenuButton()
            hideButtons()
            menuExpanded = false
        }
    }
    
    func rotateMenuButton(){
        if menuExpanded == false{
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(M_PI_4)
            rotateAnimation.duration = 0.3
            menuButton.layer.addAnimation(rotateAnimation, forKey: nil)
            menuButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        }
        else{
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = CGFloat(M_PI_4)
            rotateAnimation.toValue = 0.0
            rotateAnimation.duration = 0.3
            menuButton.layer.addAnimation(rotateAnimation, forKey: nil)
            menuButton.transform = CGAffineTransformMakeRotation(0)
        }
    }
    
    func showButtons(){
        UIView.animateWithDuration(0.2, delay: 0, options: [],animations: {
            self.findMeButton.center.x -= 90
            }, completion: nil)
        
        UIView.animateWithDuration(0.2, delay: 0.1, options: [], animations: {
            self.contactButton.center.x -= 60
            self.contactButton.center.y -= 60
            }, completion: nil)
        
        UIView.animateWithDuration(0.2, delay: 0.2, options: [], animations: {
            self.paramButton.center.y -= 90
            }, completion: nil)
    }
    
    func hideButtons(){
        UIView.animateWithDuration(0.2, delay: 0, options: [],animations: {
            self.findMeButton.center.x += 90
            }, completion: nil)
        
        UIView.animateWithDuration(0.2, delay: 0.1, options: [], animations: {
            self.contactButton.center.x += 60
            self.contactButton.center.y += 60
            }, completion: nil)
        
        UIView.animateWithDuration(0.2, delay: 0.2, options: [], animations: {
            self.paramButton.center.y += 90
            }, completion: nil)
    }


}

