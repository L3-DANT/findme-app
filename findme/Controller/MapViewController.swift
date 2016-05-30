//
//  MapViewController.swift
//  findme
//
//  Created by Maxime Signoret on 05/03/16.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import PusherSwift


class MapViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    let apiService = APIService()
    var user: User = UserService.getUserInSession()
    var searchController: UISearchController!
    var annotation: MKAnnotation!
    var localSearchRequest: MKLocalSearchRequest!
    var localSearch: MKLocalSearch!
    var localSearchResponse: MKLocalSearchResponse!
    var error: NSError!
    var pointAnnotation: MKPointAnnotation!
    var pinAnnotationView: MKPinAnnotationView!
    var menuExpanded = false
    var locationManager = CLLocationManager()
    var pusher : Pusher = Pusher(key: "")
    var channels : [PusherChannel] = []
    var annotations = [MKAnnotation]()
    
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

    @IBAction func testSearch(sender: AnyObject) {
        let search = searchTextField.text
        for user in self.user.friendList! {
            if search == user.pseudo {
                let searchLocation  = CLLocation(latitude: user.latitude, longitude: user.longitude)
                centerMapOnLocation(searchLocation)
                dismissKeyboard()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        initSearchField()
        
        mapView.delegate = self
        
        //initialisation des boutons rond du menu
        initButton(menuButton, icon: "fa-plus", submenu: false)
        initButton(paramButton, icon:"fa-cogs", submenu: true)
        initButton(contactButton, icon:"fa-users", submenu: true)
        initButton(findMeButton, icon:"fa-street-view", submenu: true)
        
        //gestion de la localisation de l'utilisateur
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        //affichage de la position de l'utilisateur
        self.mapView.showsUserLocation = true
        
        self.pusher = Pusher(key: "03576a442aa390f473c6")
        self.pusher.connect()
        self.initChannelsSubscription()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        self.updateLocation()
        self.initContactMarkers()
    }
    
    //update location for pusher
    func updateLocation() {
        self.user.state = User.State.ONLINE
        let currentLocation = locationManager.location!.coordinate
        self.user.latitude = currentLocation.latitude
        self.user.longitude = currentLocation.longitude
        let params: [String: String] = ["pseudo": self.user.pseudo as String, "latitude": String(self.user.latitude), "longitude": String(self.user.longitude), "state": String(self.user.state)]
        self.apiService.updateLocation(params) { (user, err) in
        }
        self.user = UserService.getUserInSession()
        self.mapView.removeAnnotations(self.annotations)
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
    func initContactMarkers() {
        self.annotations = [MKAnnotation]()
        
        for friend in self.user.friendList!{
            let friendLocation = CLLocationCoordinate2D(latitude: friend.latitude, longitude: friend.longitude)
            let friendAnnotation = UserAnnotation(coordinate: friendLocation, title: friend.pseudo, subtitle: "", image:friend.state.rawValue)
            self.annotations.append(friendAnnotation)
        }
        
        self.mapView.addAnnotations(self.annotations)
        
        if let location = self.mapView.userLocation.location {
            self.centerMapOnLocation(location)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        let regionForUpdate : CLRegion = CLCircularRegion(center: center, radius: 20, identifier: "currentRegion")
        locationManager.startMonitoringForRegion(regionForUpdate)

        self.mapView.setRegion(region , animated: true )
        self.locationManager.stopUpdatingLocation()

        if (menuExpanded){
            rotateMenuButton(menuExpanded)
            menuExpanded = !menuExpanded
        }
    }
    
    //when the user exit the circular region of 20 meter from his initial position
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        locationManager.stopMonitoringForRegion(region)
        
        let currentLocation = locationManager.location!.coordinate
        let params: [String: String] = ["pseudo": self.user.pseudo as String, "latitude": String(self.user.latitude), "longitude": String(self.user.longitude), "state": String(self.user.state)]
        self.apiService.updateLocation(params) { (user, err) in
        }
        
        let newRegion : CLRegion = CLCircularRegion(center: currentLocation, radius: 20, identifier: "currentRegion")
        locationManager.startMonitoringForRegion(newRegion)
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
    
    func initSearchField() {
        let paddingView = UIView(frame: CGRectMake(0, 0, 25, self.searchTextField.frame.height))
        self.searchTextField.leftView = paddingView
        self.searchTextField.leftViewMode = UITextFieldViewMode.Always
        self.searchIcon.font = UIFont.fontAwesomeOfSize(15)
        self.searchIcon.text = String.fontAwesomeIconWithName(.Search)
    }
    
    @IBAction func findMe(sender: AnyObject) {
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .NotDetermined, .Restricted, .Denied:
                let locationDisabledController = UIAlertController(title: "Allow us to FindYou", message: "Please let us know where you are", preferredStyle: .Alert)
                
                let settingsAction = UIAlertAction(title: "Settings", style: .Default, handler: {(alert: UIAlertAction!) in
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                
                locationDisabledController.addAction(settingsAction)
                locationDisabledController.addAction(cancelAction)
                
                self.presentViewController(locationDisabledController, animated : true, completion : nil)
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                if mapView.userLocation.location != nil{
                    let location = mapView.userLocation.location
                    centerMapOnLocation(location!)
                    hideButtons()
                    rotateMenuButton(menuExpanded)
                    menuExpanded = false
                }
            }
        }
    }

    func centerMapOnLocation(location: CLLocation) {
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000), animated: true)
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
        if menuExpanded {
            hideButtons()
            rotateMenuButton(menuExpanded)
            menuExpanded = false
        }
    }
    
    func mapView(mapView: MKMapView,
        viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
            
        if annotation.isKindOfClass(UserAnnotation.self) {
            let reuseIdentifier = "pin"
            
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                annotationView!.canShowCallout = true
            }
            else {
                annotationView!.annotation = annotation
            }
            
            let customPointAnnotation = annotation as! UserAnnotation
            annotationView!.image = UIImage(named:customPointAnnotation.pinCustomImageName!)
        
            return annotationView                
        } else {
            return nil
        }
    }
    
    func initChannelsSubscription(){
    
        for friend in self.user.friendList!{
            self.channels.append(self.pusher.subscribe("private-\(friend.pseudo)"))
        }
        
        for channel in channels{
            channel.bind("position-updated", callback: { (data: AnyObject?) -> Void in
                if let data = data as? Dictionary<String, AnyObject> {
                    if let latitude = data["latitude"] as? Double, longitude = data["longitude"] as? Double, name = data["pseudo"] as? String {
                        for annotation in (self.mapView.annotations as? [UserAnnotation])!{
                            if annotation.title == name{
                                let newCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                annotation.updateCoordinate(newCoordinate)
                            }
                        }
                    }
                }
            })
        }
    }
}
