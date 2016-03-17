//
//  UserAnnotationView.swift
//  findme
//
//  Created by Nicolas Mercier on 17/03/2016.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import UIKit
import MapKit

class UserAnnotationView: MKAnnotationView {
    
    let selectedLabel:UILabel = UILabel.init(frame:CGRectMake(0, 0, 140, 40))

    var text : String?
    
    
    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(false, animated: animated)
        
        if(selected)
        {
            // Do customization, for example:
            selectedLabel.text = (self.annotation?.title)!
            selectedLabel.textColor = UIColor.whiteColor()
            
            selectedLabel.textAlignment = .Center
            selectedLabel.font = UIFont.init(name: "HelveticaBold", size: 15)
            selectedLabel.backgroundColor = UIColor(colorLiteralRed: 52.0/255, green: 73.0/255, blue: 94.0/255, alpha: 1.0)

            selectedLabel.layer.borderWidth = 0
            selectedLabel.layer.cornerRadius = 5
            selectedLabel.layer.masksToBounds = true
            
            selectedLabel.center.x = 0.5 * self.frame.size.width;
            selectedLabel.center.y = -0.5 * selectedLabel.frame.height;
            
            self.addSubview(selectedLabel)
        }
        else
        {
            selectedLabel.removeFromSuperview()
        }
    }
}