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
    
    var radialMenu = RadialMenu()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.radialMenu = RadialMenu(menus: [
            self.createSubMenu(),
            self.createSubMenu(),
            self.createSubMenu(),
            self.createSubMenu()
        ])
        
        self.radialMenu.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        self.radialMenu.center = self.view.center
        self.radialMenu.radius = 100
        self.radialMenu.backgroundColor = UIColor.redColor()
        
        self.view.addSubview(self.radialMenu)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "pressedButton:")
        self.addButton.addGestureRecognizer(longPress)
        
        // How else to get button to trigger?
        self.view.bringSubviewToFront(self.addButton)
        
    }
    
    func createSubMenu() -> RadialSubMenu {
        let radius = 50
        let subMenu = RadialSubMenu(frame: CGRect(x: 0, y: 0, width: radius*2, height: radius*2))
        subMenu.backgroundColor = UIColor.orangeColor()
        subMenu.userInteractionEnabled = true
        return subMenu
    }
    
    func pressedButton(gesture:UIGestureRecognizer) {
        switch(gesture.state) {
            case .Began:
                self.radialMenu.openAtPosition(self.addButton.center)
                //self.radialMenu.openAtPosition(gesture.locationInView(self.view))
            case .Ended:
                self.radialMenu.close()
            case .Changed:
                self.radialMenu.moveAtPosition(gesture.locationInView(self.view))
            default:
                break
        }
    }
}

