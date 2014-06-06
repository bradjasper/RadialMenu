//
//  FirstViewController.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/5/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    @IBOutlet var addButton:UIImageView
    
    @IBOutlet var radialMenu:RadialMenu
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var radialMenu = RadialMenu(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        self.view.addSubview(radialMenu)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

