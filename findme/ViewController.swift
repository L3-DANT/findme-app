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
    
    var users : [User] = []
    
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
        for annotation in mapView.annotations as [MKAnnotation]{
            if annotation.title! == search!{
                mapView.selectAnnotation(annotation, animated: true)
                let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                centerMapOnLocation(location)
            }
        }
        
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
        
        var annotations = [MKAnnotation]()
        
        var users : [User] = []
        
        let feedUrl = "http://localhost:8080/findme/api/user/fixtures"
        
        let request = NSURLRequest(URL: NSURL(string: feedUrl)!)
        
//  utiliser       NSURLSession !!
        
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
                        users.append(jsonUser)
                        
                        let friendLocation = CLLocationCoordinate2D(latitude: x!, longitude: y!)
                        let friend = UserAnnotation(coordinate: friendLocation, title: name, subtitle: "")
                        annotations.append(friend)
                        self.users.append(jsonUser)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.mapView.addAnnotations(annotations)
                        if let location = self.mapView.userLocation.location {
                            self.centerMapOnLocation(location)
                        }
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    })
            }
        }
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

    
    
    @IBAction func findMe(sender: AnyObject) {

        let location = mapView.userLocation.location
        centerMapOnLocation(location!)
        hideButtons()
        rotateMenuButton(menuExpanded)
        menuExpanded = false
    }
    
    //
    func centerMapOnLocation(location: CLLocation) {
        var farFriendDistance:CLLocationDistance = 0
        var newDistance:CLLocationDistance
        var friendLocation:CLLocationCoordinate2D
        for user in users{
            friendLocation = CLLocationCoordinate2D.init(latitude: user.x, longitude: user.y)
            newDistance = location.distanceFromLocation(CLLocation.init(latitude: friendLocation.latitude, longitude: friendLocation.longitude))
            print(user.pseudo)
            print(newDistance)
            if(newDistance > farFriendDistance){
                farFriendDistance = newDistance
            }
        }
        print("farFriendDistance \(farFriendDistance)")
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,farFriendDistance*2, farFriendDistance*2)
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
    

}

