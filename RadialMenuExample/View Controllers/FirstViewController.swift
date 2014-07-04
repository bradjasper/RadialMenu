//
//  FirstViewController.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/5/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit
import QuartzCore

class FirstViewController: UIViewController {
    
    @IBOutlet var addButton:UIImageView
    
    var radialMenu = RadialMenu()
    let backgroundLayer = CALayer()
    let num = 12
    var numHighlighted = 0
    let innerRadius:CGFloat = 55.0
    let subMenuRadius:CGFloat = 25.0
    let menuRadius: Float = 125.0
    let radialStep = 0.0
    let allowMultipleHighlights = false
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
        
        
        radialMenu = RadialMenu(menus: subMenus)
        radialMenu.frame = CGRect(x: 0, y: 0, width: CGFloat(innerRadius*2), height: CGFloat(innerRadius*2))
        radialMenu.center = view.center
        radialMenu.radius = menuRadius
        radialMenu.radiusStep = radialStep
        //radialMenu.backgroundColor = UIColor(rgba: "#bdc3c7")
        radialMenu.allowMultipleHighlights = allowMultipleHighlights
        radialMenu.onOpen = {
            println("RADIAL MENU OPENED")
        }
        
        radialMenu.onClose = {
            println("RADIAL MENU CLOSED")
            
            self.numHighlighted = 0
            self.resetRadialMenuBackground()
            
            for subMenu in self.radialMenu.subMenus {
                self.resetSubMenu(subMenu)
            }
            
        }
        
        radialMenu.onHighlight = { subMenu in
            println("Highlighted subMenu \(subMenu)")
            
            if (self.numHighlighted++ == 0) {
                self.growRadialMenuBackground()
            }
            
            self.highlightSubMenu(subMenu)
        }
        
        radialMenu.onUnhighlight = { subMenu in
            println("Unhighlighted subMenu \(subMenu)")
            
            if (--self.numHighlighted == 0) {
                self.resetRadialMenuBackground()
            }
            
            self.resetSubMenu(subMenu)
        }
        
        radialMenu.onActivate = { subMenu in
            println("Activated \(subMenu)")
        }
        
        // FIXME: Couldn't figure out how to resize UIView without also having to change subview pos
        //resetRadialMenuBackground()
        backgroundLayer.position = radialMenu.center
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: CGFloat(innerRadius*2), height: CGFloat(innerRadius*2))
        backgroundLayer.cornerRadius = innerRadius
        backgroundLayer.backgroundColor = UIColor(rgba: "#bdc3c7").colorWithAlphaComponent(0.5).CGColor
        backgroundLayer.zPosition = -1
        radialMenu.layer.addSublayer(backgroundLayer)
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
        let subMenu = RadialSubMenu(frame: CGRect(x: 0.0, y: 0.0, width: CGFloat(subMenuRadius*2), height: CGFloat(subMenuRadius*2)))
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
        subMenu.backgroundColor = color.colorWithAlphaComponent(0.5)
    }
    
    func growRadialMenuBackground() {
        println("grow")
        backgroundLayer.bounds = CGRect(x: 0, y: 0, width: innerRadius*6, height: innerRadius*6)
        backgroundLayer.cornerRadius = innerRadius*3
    }
    
    func resetRadialMenuBackground() {
        println("reset")
        backgroundLayer.bounds = CGRect(x: 0, y: 0, width: innerRadius*2, height: innerRadius*2)
        backgroundLayer.cornerRadius = innerRadius
    }
    
}

