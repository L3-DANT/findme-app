//
//  Contact.swift
//  findme
//
//  Created by Nicolas Mercier on 15/03/2016.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import UIKit
import MapKit

class UserAnnotation : NSObject, MKAnnotation {
    
    var coordinate:CLLocationCoordinate2D
    var title:String?
    var subtitle:String?
    var numero:String?
    
    init(coordinate : CLLocationCoordinate2D, title : String?, subtitle : String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}