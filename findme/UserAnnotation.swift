//
//  Contact.swift
//  findme
//
//  Created by Nicolas Mercier on 15/03/2016.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import UIKit
import MapKit

class UserAnnotation : MKPointAnnotation {
    
    var pinCustomImageName : String?
    
    init(coordinate : CLLocationCoordinate2D, title : String?, subtitle : String?) {
        super.init()
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.pinCustomImageName = "customPin"
    }
    
    func updateCoordinate(newCoordinate : CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
}