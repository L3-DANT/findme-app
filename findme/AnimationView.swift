//
//  launchAnimationView.swift
//  findme
//
//  Created by Nicolas Mercier on 13/05/2016.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import Foundation
import UIKit


class AnimationView : UIImageView{
    
    override var animationImages: [UIImage]?{
        didSet{
            var images: [UIImage] = []
            for i in 1...9 {
                images.append(UIImage(named: "3 lines_0000\(i)")!)
            }
            for i in 10...99 {
                images.append(UIImage(named: "3 lines_000\(i)")!)
            }
            for i in 100...133 {
                images.append(UIImage(named: "3 lines_00\(i)")!)
            }
            animationImages = images
            animationDuration = 3.0
            startAnimating()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}