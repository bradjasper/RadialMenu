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
        
        println("Setting up radialMenu")
        self.radialMenu.frame = self.view.frame
        self.radialMenu.subMenus = [
            self.createSubMenu(),
            self.createSubMenu(),
            self.createSubMenu(),
            self.createSubMenu(),
        ]
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "pressedButton:")
        self.addButton.addGestureRecognizer(longPress)
        
        // How else to get button to trigger?
        self.view.bringSubviewToFront(self.addButton)
        
    }
    
    func createSubMenu() -> RadialSubMenu {
        let radius = 50
        let subMenu = RadialSubMenu(frame: CGRect(x: 0, y: 0, width: radius*2, height: radius*2))
        subMenu.backgroundColor = UIColor.orangeColor()
        subMenu.layer.zPosition = -1
        subMenu.userInteractionEnabled = true
        self.radialMenu.addSubview(subMenu)
        return subMenu
    }
    
    func pressedButton(gesture:UIGestureRecognizer) {
        switch(gesture.state) {
            case .Began:
                self.radialMenu.openAtPosition(gesture.locationInView(self.view))
            case .Ended:
                self.radialMenu.close()
            case .Changed:
                self.radialMenu.moveAtPosition(gesture.locationInView(self.view))
            default:
                break
        }
    }
}

