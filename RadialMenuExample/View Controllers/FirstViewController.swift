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
    
    var addButton:UIImageView
    var tapView:UIView
    
    var radialMenu:RadialMenu!
    let num = 4
    let addButtonSize: CGFloat = 25
    let menuRadius: CGFloat = 125.0
    let subMenuRadius: CGFloat = 35.0
    var didSetupConstraints = false
    let colors = ["#C0392B", "#2ECC71", "#E67E22", "#3498DB", "#9B59B6", "#F1C40F",
                  "#16A085", "#8E44AD", "#2C3E50", "#F39C12", "#2980B9", "#27AE60",
                  "#D35400", "#34495E", "#E74C3C", "#1ABC9C"].map { UIColor(rgba: $0) }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        addButton = UIImageView(image: UIImage(named: "plus"))
        tapView = UIView()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(FirstViewController.pressedButton(_:)))
        
        // Setup radial menu
        var subMenus: [RadialSubMenu] = []
        for i in 0..<num {
            subMenus.append(self.createSubMenu(i))
        }
        
        radialMenu = RadialMenu(menus: subMenus, radius: menuRadius)
        radialMenu.center = view.center
        radialMenu.openDelayStep = 0.05
        radialMenu.closeDelayStep = 0.00
        radialMenu.minAngle = 180
        radialMenu.maxAngle = 360
        radialMenu.activatedDelay = 1.0
        radialMenu.backgroundView.alpha = 0.0
        radialMenu.onClose = {
            for subMenu in self.radialMenu.subMenus {
                self.resetSubMenu(subMenu)
            }
        }
        radialMenu.onHighlight = { subMenu in
            self.highlightSubMenu(subMenu)
            
            let color = self.colorForSubMenu(subMenu).withAlphaComponent(1.0)
            
            // TODO: Add nice color transition
            self.view.backgroundColor = color
        }
        
        radialMenu.onUnhighlight = { subMenu in
            self.resetSubMenu(subMenu)
            self.view.backgroundColor = UIColor.white
        }
        
        radialMenu.onClose = {
            self.view.backgroundColor = UIColor.white
        }
        
        view.addSubview(radialMenu)
        
        // Setup add button
        addButton.isUserInteractionEnabled = true
        addButton.alpha = 0.65
        view.addSubview(addButton)
        
        tapView.center = view.center
        tapView.addGestureRecognizer(longPress)
        view.addSubview(tapView)
        
        view.backgroundColor = UIColor.white
    }
    
    // FIXME: Consider moving this to the radial menu and making standard interaction types  that are configurable
    func pressedButton(_ gesture:UIGestureRecognizer) {
        switch(gesture.state) {
            case .began:
                self.radialMenu.openAtPosition(self.addButton.center)
            case .ended:
                self.radialMenu.close()
            case .changed:
                self.radialMenu.moveAtPosition(gesture.location(in: self.view))
            default:
                break
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if (!didSetupConstraints) {
            
            // FIXME: Any way to simplify this?
            addButton.autoAlignAxis(toSuperviewAxis: .horizontal)
            addButton.autoAlignAxis(toSuperviewAxis: .vertical)
            addButton.autoSetDimensions(to: CGSize(width: addButtonSize, height: addButtonSize))
            
            tapView.autoAlignAxis(toSuperviewAxis: .horizontal)
            tapView.autoAlignAxis(toSuperviewAxis: .vertical)
            tapView.autoSetDimensions(to: CGSize(width: addButtonSize*2, height: addButtonSize*2))
            
            didSetupConstraints = true
        }
    }
    
    // MARK - RadialSubMenu helpers
    
    func createSubMenu(_ i: Int) -> RadialSubMenu {
        let subMenu = RadialSubMenu(frame: CGRect(x: 0.0, y: 0.0, width: CGFloat(subMenuRadius*2), height: CGFloat(subMenuRadius*2)))
        subMenu.isUserInteractionEnabled = true
        subMenu.layer.cornerRadius = subMenuRadius
        subMenu.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        subMenu.layer.borderWidth = 1
        subMenu.tag = i
        resetSubMenu(subMenu)
        return subMenu
    }
    
    func colorForSubMenu(_ subMenu: RadialSubMenu) -> UIColor {
        let pos = subMenu.tag % colors.count
        return colors[pos] as UIColor!
    }
    
    func highlightSubMenu(_ subMenu: RadialSubMenu) {
        let color = colorForSubMenu(subMenu)
        subMenu.backgroundColor = color.withAlphaComponent(1.0)
    }
    
    func resetSubMenu(_ subMenu: RadialSubMenu) {
        let color = colorForSubMenu(subMenu)
        subMenu.backgroundColor = color.withAlphaComponent(0.75)
    }
}

