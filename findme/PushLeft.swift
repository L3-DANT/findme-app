//
//  PushLeft.swift
//  findme
//
//  Created by Nicolas Mercier on 14/03/2016.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import UIKit

class SegueFromLeft: UIStoryboardSegue
{
    override func perform()
    {
        let src = self.sourceViewController
        let dst = self.destinationViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransformMakeTranslation(-src.view.frame.size.width, 0)
        
        UIView.animateWithDuration(0.25,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                dst.view.transform = CGAffineTransformMakeTranslation(0, 0)
            },
            completion: { finished in
                src.presentViewController(dst, animated: false, completion: nil)
            }
        )
    }
}
