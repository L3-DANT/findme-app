//
//  AboutViewController.swift
//  findme
//
//  Created by Maxime Signoret on 04/05/16.
//  Copyright © 2016 Maxime Signoret. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBAction func closeModal(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
}
