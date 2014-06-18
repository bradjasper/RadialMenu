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
    let num = 8
    let innerRadius = 65.0
    let subMenuRadius = 35.0
    let menuRadius = 115.0
    let colors = ["#C0392B", "#2ECC71", "#E67E22", "#3498DB", "#9B59B6", "#F1C40F",
                  "#16A085", "#8E44AD", "#2C3E50", "#F39C12", "#2980B9", "#27AE60",
                  "#D35400", "#34495E", "#E74C3C", "#1ABC9C"].map { UIColor(rgba: $0) }
    
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
        let subMenu = RadialSubMenu(frame: CGRect(x: 0.0, y: 0.0, width: subMenuRadius*2, height: subMenuRadius*2))
        subMenu.layer.cornerRadius = subMenuRadius
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

