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
    let num = 12
    let innerRadius = 50.0
    let menuRadius = 100.0
    let subMenuRadius = 25.0
    var colors = [
        UIColor(rgba: "#C0392B"),
        UIColor(rgba: "#2ECC71"),
        UIColor(rgba: "#E67E22"),
        UIColor(rgba: "#3498DB"),
        UIColor(rgba: "#9B59B6"),
        UIColor(rgba: "#F1C40F"),
        UIColor(rgba: "#16A085"),
        UIColor(rgba: "#8E44AD"),
        UIColor(rgba: "#2C3E50"),
        UIColor(rgba: "#F39C12"),
        UIColor(rgba: "#2980B9"),
        UIColor(rgba: "#27AE60"),
        UIColor(rgba: "#D35400"),
        UIColor(rgba: "#34495E"),
        UIColor(rgba: "#E74C3C"),
        UIColor(rgba: "#1ABC9C"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRadialMenu()
        
        self.view.addSubview(self.radialMenu)
        self.view.backgroundColor = UIColor(rgba: "#ecf0f1")
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "pressedButton:")
        self.addButton.addGestureRecognizer(longPress)
        
        // How else to get button to trigger?
        self.view.bringSubviewToFront(self.addButton)
        
    }
    
    func setupRadialMenu() {
        
        var subMenus: RadialSubMenu[] = []
        for i in 0..num {
            subMenus.append(self.createSubMenu(i))
        }
        
        self.radialMenu = RadialMenu(menus: subMenus)
        self.radialMenu.frame = CGRect(x: 0, y: 0, width: innerRadius*2, height: innerRadius*2)
        self.radialMenu.center = self.view.center
        self.radialMenu.layer.cornerRadius = innerRadius
        self.radialMenu.radius = menuRadius
        self.radialMenu.backgroundColor = UIColor(rgba: "#bdc3c7")
        
        self.radialMenu.onOpen = {
            println("RADIAL MENU OPENED")
        }
        
        self.radialMenu.onClose = {
            println("RADIAL MENU CLOSED")
            
            for subMenu in self.radialMenu.subMenus {
                self.resetSubMenu(subMenu)
            }
        }
        
        self.radialMenu.onHighlight = { subMenu in
            println("Highlighted subMenu \(subMenu)")
            self.highlightSubMenu(subMenu)
        }
        
        self.radialMenu.onUnhighlight = { subMenu in
            println("Unhighlighted subMenu \(subMenu)")
            self.resetSubMenu(subMenu)
        }
        
        self.radialMenu.onActivate = { subMenu in
            println("Activated \(subMenu)")
        }
        
    }
    
    func pressedButton(gesture:UIGestureRecognizer) {
        switch(gesture.state) {
            case .Began:
                self.radialMenu.openAtPosition(self.addButton.center)
            case .Ended:
                self.radialMenu.close()
            case .Changed:
                self.radialMenu.moveAtPosition(gesture.locationInView(self.view))
            default:
                break
        }
    }
    
    // MARK - RadialSubMenu helpers
    
    func createSubMenu(i: Int) -> RadialSubMenu {
        let subMenu = RadialSubMenu(frame: CGRect(x: 0, y: 0, width: subMenuRadius*2, height: subMenuRadius*2))
        subMenu.layer.cornerRadius = CGFloat(subMenuRadius)
        subMenu.userInteractionEnabled = true
        subMenu.tag = i
        resetSubMenu(subMenu)
        return subMenu
    }
    
    func colorForSubMenu(subMenu: RadialSubMenu) -> UIColor {
        let pos = subMenu.tag % colors.count
        return colors[pos] as UIColor!
    }
    
    func highlightSubMenu(subMenu: RadialSubMenu) {
        let color = colorForSubMenu(subMenu)
        subMenu.backgroundColor = color.colorWithAlphaComponent(1.0)
    }
    
    func resetSubMenu(subMenu: RadialSubMenu) {
        let color = colorForSubMenu(subMenu)
        subMenu.backgroundColor = color.colorWithAlphaComponent(0.75)
    }
    
}

