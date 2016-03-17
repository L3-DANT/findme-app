//
//  ViewController.swift
//  findme
//
//  Created by Maxime Signoret on 05/03/16.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var menuExpanded = false
    
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchIcon: UITextField!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var paramButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
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
        
        mapView.delegate = self
        
        //initialisation des boutons rond du menu
        initButton(menuButton, icon: "fa-plus", submenu: false)
        initButton(paramButton, icon:"fa-cogs", submenu: true)
        initButton(contactButton, icon:"fa-users", submenu: true)
        initButton(findMeButton, icon:"fa-street-view", submenu: true)
        
        initContactMarkers()
        
        //gestion de la localisation de l'utilisateur
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        //affichage de la position de l'utilisateur
        self.mapView.showsUserLocation = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    @IBAction func paramButtonClic(sender: AnyObject) {
        hideButtons()
        rotateMenuButton(menuExpanded)
        menuExpanded = false
    }
    @IBAction func contactButtonClic(sender: AnyObject) {
        hideButtons()
        rotateMenuButton(menuExpanded)
        menuExpanded = false
    }
    
    //fonction qui initialise les markers des amis sur la carte
    
    func initContactMarkers(){
        let antoineLocation = CLLocationCoordinate2D(latitude: 48.846813, longitude: 2.359335)
        let antoine = UserAnnotation(coordinate: antoineLocation, title: "Antoine", subtitle: "")
        
        let maximeLocation = CLLocationCoordinate2D(latitude: 48.846347, longitude: 2.356632)
        let maxime = UserAnnotation(coordinate: maximeLocation, title: "Maxime", subtitle: "")
        
        let francoisLocation = CLLocationCoordinate2D(latitude: 48.848507, longitude: 2.361116)
        let francois = UserAnnotation(coordinate: francoisLocation, title: "Francois", subtitle: "")
        
        var annotations = [MKAnnotation]()
        annotations.append(francois)
        annotations.append(maxime)
        annotations.append(antoine)
        
        mapView.addAnnotations(annotations)
    }
    
    //fonction appelée a chaque refresh de la location utilisée pour recentrer la caméra sur l'utilisateur automatiquement
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        self.mapView.setRegion(region , animated: true )
        self.locationManager.stopUpdatingLocation()
    }
    
    //fonction appelée en cas d'erreur
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error" + error.localizedDescription)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initButton(button:UIButton, icon:String, submenu : Bool){
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.fontAwesomeOfSize(25)
        button.setTitle(String.fontAwesomeIconWithCode(icon), forState: .Normal)
        if submenu{
            button.transform = CGAffineTransformMakeScale(0.5, 0.5)
        }
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
    
    @IBAction func findMe(sender: AnyObject) {

        let location = mapView.userLocation.location
        centerMapOnLocation(location!)
        hideButtons()
        rotateMenuButton(menuExpanded)
        menuExpanded = false
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //action au clic du bouton du menu
    @IBAction func showMenu(sender: AnyObject){
        rotateMenuButton(menuExpanded)
        if menuExpanded == false {
            showButtons()
        } else {
            hideButtons()
        }
        
        menuExpanded = !menuExpanded
    }
    
    //fonction qui permet d'effectuer une rotation sur le bouton du menu
    func rotateMenuButton(expanded : Bool){
        if expanded == false {
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(M_PI + M_PI_4)
            rotateAnimation.duration = 0.30
            menuButton.layer.addAnimation(rotateAnimation, forKey: nil)
            menuButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI + M_PI_4))
        } else {
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = CGFloat(M_PI + M_PI_4)
            rotateAnimation.toValue = 0.0
            rotateAnimation.duration = 0.30
            menuButton.layer.addAnimation(rotateAnimation, forKey: nil)
            menuButton.transform = CGAffineTransformMakeRotation(0)
        }
    }
    
    // fonction qui permet d'afficher les options du menu
    func showButtons(){
        UIView.animateWithDuration(0.2, delay: 0, options: [.CurveEaseOut],animations: {
            self.findMeButton.center.x -= 90
            self.findMeButton.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
        
        UIView.animateWithDuration(0.2, delay: 0.1, options: [.CurveEaseOut], animations: {
            self.contactButton.center.x -= 60
            self.contactButton.center.y -= 60
            self.contactButton.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
        
        UIView.animateWithDuration(0.2, delay: 0.2, options: [.CurveEaseOut], animations: {
            self.paramButton.center.y -= 90
            self.paramButton.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
    }
    
    //fonction qui permet de cacher les option du menu
    func hideButtons(){
        UIView.animateWithDuration(0.2, delay: 0, options: [.CurveEaseOut],animations: {
            self.findMeButton.center.x += 90
            self.findMeButton.transform = CGAffineTransformMakeScale(0.5, 0.5)
            }, completion: nil)
        
        UIView.animateWithDuration(0.2, delay: 0.1, options: [.CurveEaseOut], animations: {
            self.contactButton.center.x += 60
            self.contactButton.center.y += 60
            self.contactButton.transform = CGAffineTransformMakeScale(0.5, 0.5)
            }, completion: nil)
        
        UIView.animateWithDuration(0.2, delay: 0.2, options: [.CurveEaseOut], animations: {
            self.paramButton.center.y += 90
            self.paramButton.transform = CGAffineTransformMakeScale(0.5, 0.5)
            }, completion: nil)
    }
    
    
    //fonction qui permet de fermer le menu lors d'un clic sur une annotation
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        hideButtons()
        rotateMenuButton(menuExpanded)
        menuExpanded = false
    }
    
    
    //fonction qui permet de changer les annotation
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "UserAnnotation"
        if annotation.isKindOfClass(UserAnnotation.self) {
            
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            
            if annotationView == nil {
                
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                let callButton = UIButton(type: .Custom)
                callButton.frame.size.width = 44
                callButton.frame.size.height = 44
                callButton.titleLabel?.font = UIFont.fontAwesomeOfSize(25)
                callButton.setTitle(String.fontAwesomeIconWithCode("fa-phone"), forState: .Normal)
                callButton.setTitleColor(UIColor(colorLiteralRed:0.0, green:122.0/255.0, blue:1.0, alpha:1.0), forState: .Normal)
                annotationView!.leftCalloutAccessoryView = callButton
                
                let smsButton = UIButton(type: .Custom)
                smsButton.frame.size.width = 44
                smsButton.frame.size.height = 44
                smsButton.titleLabel?.font = UIFont.fontAwesomeOfSize(25)
                smsButton.setTitle(String.fontAwesomeIconWithCode("fa-envelope"), forState: .Normal)
                smsButton.setTitleColor(UIColor(colorLiteralRed:0.0, green:122.0/255.0, blue:1.0, alpha:1.0), forState: .Normal)
                annotationView!.rightCalloutAccessoryView = smsButton
                
            } else {
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
        
        return nil
    }


}

