//
//  RadialMenu.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/5/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit

@IBDesignable
class RadialMenu: UIView {
    
    @IBInspectable var radius: Double = 50
    @IBInspectable var radiusStep: Double = 0
    @IBInspectable var openDelayStep: Double = 0
    @IBInspectable var closeDelayStep: Double = 0
    @IBInspectable var selectedDelay: Double = 50
    @IBInspectable var minAngle: Int = 180
    @IBInspectable var maxAngle: Int = 540
    @IBInspectable var allowMultipleHighlights: Bool = false
    
    var subMenus: Array<RadialSubMenu> {
        didSet(newValue) {
            for subMenu in newValue {
                println("Adding subview")
                self.addSubview(subMenu)
            }
            
        }
    }
    
    var numOpeningSubMenus = 0
    var position = CGPointZero
    
    enum State: Int {
        case Closed = 1, Opening, Opened, Highlighted, Selected, Closing
    }
    
    var state: State = State.Closed {
        willSet(newValue) {
            switch newValue {
                case .Closed:
                    println("State is closed")
                case .Opening:
                    println("State is opening")
                case .Opened:
                    println("State is opened")
                case .Highlighted:
                    println("State is highlighted")
                case .Selected:
                    println("State is selected")
                case .Closing:
                    println("State is closing")
            }
        }
    }

    init(coder decoder: NSCoder!) {
        subMenus = []
        super.init(coder: decoder)
    }
    
    init(menus : Array<RadialSubMenu>) {
        subMenus = menus
        // FIXME: hrmm... this doesn't seem right...
        super.init(coder: nil)
    }
    
    // After: Swift
    
    func openAtPosition(position: CGPoint) {
        
        let max = subMenus.count
        
        if max == 0              { return println("No submenus to open")        }
        if state != State.Closed { return println("Can only open closed menus") }
        
        state = State.Opening
        self.position = position
        
        let fullCircle = isFullCircle(minAngle, maxAngle)
        
        for (idx, subMenu) in enumerate(subMenus) {
            let subMenuPos = getPositionForSubMenu(idx, max: max, overlap: fullCircle)
            let delay = openDelayStep * Double(idx)
            numOpeningSubMenus += 1
            subMenu.openAt(subMenuPos, delay: delay)
        }
        
        
    }
    
    func getPositionForSubMenu(idx: Int, max: Int, overlap: Bool) -> CGPoint {
        
        let absMax = overlap ? max : max - 1
        let absRadius = radius + (radiusStep * Double(idx))
        let relPos = getPointAlongCircle(idx, max, 80, 540, 50)
        let posX = position.x + relPos.x
        let posY = position.y + relPos.y
        return CGPoint(x: posX, y: posY)
    }
    
    
    func close() {
        state = State.Closing
        
        // Animations closed....
        state = State.Closed
    }
    
    func moveAtPosition(position:CGPoint) {
        println("Moving")
    }
    
    
    // FIXME: Why doesn't this update in IB?
    override func prepareForInterfaceBuilder() {
        self.backgroundColor = UIColor.greenColor()
    }
    
}
