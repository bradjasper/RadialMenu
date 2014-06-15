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
        
        var subMenus: RadialSubMenu[] = []
        for i in 1...100 {
            subMenus.append(self.createSubMenu())
        }
        self.radialMenu = RadialMenu(menus: subMenus)
        
        self.radialMenu.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        self.radialMenu.center = self.view.center
        self.radialMenu.layer.cornerRadius = 100
        self.radialMenu.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
        self.radialMenu.onOpen = {
            println("RADIAL MENU OPENED")
        }
        self.radialMenu.onClose = {
            println("RADIAL MENU CLOSED")
        }
        
        self.view.addSubview(self.radialMenu)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "pressedButton:")
        self.addButton.addGestureRecognizer(longPress)
        
        // How else to get button to trigger?
        self.view.bringSubviewToFront(self.addButton)
        
    }
    
    func createSubMenu() -> RadialSubMenu {
        let radius = 10
        let subMenu = RadialSubMenu(frame: CGRect(x: 0, y: 0, width: radius*2, height: radius*2))
        subMenu.backgroundColor = UIColor.lightGrayColor()
        subMenu.layer.cornerRadius = CGFloat(radius)
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

