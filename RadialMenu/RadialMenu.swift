//
//  RadialMenu.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/5/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit

@IBDesignable
class RadialMenu: UIView, RadialSubMenuDelegate {
    
    @IBInspectable var radius: Double = 50
    @IBInspectable var radiusStep: Double = 0
    @IBInspectable var openDelayStep: Double = 0
    @IBInspectable var closeDelayStep: Double = 0
    @IBInspectable var selectedDelay: Double = 50
    @IBInspectable var minAngle: Int = 180
    @IBInspectable var maxAngle: Int = 540
    @IBInspectable var allowMultipleHighlights: Bool = false
    
    // FIXME: shorter syntax?
    var onOpen: () -> () = {}
    var onClose: () -> () = {}
    
    var subMenus: Array<RadialSubMenu>
    
    var numOpeningSubMenus = 0
    var numOpenedSubMenus = 0
    
    var position = CGPointZero
    
    enum State: Int {
        case Closed = 1, Opening, Opened, Highlighted, Selected, Closing
    }
    
    var state: State = State.Closed {
        didSet {
            if oldValue == state { return }
            switch state {
                case .Closed:
                    println("State is closed")
                    onClose()
                case .Opening:
                    println("State is opening")
                case .Opened:
                    println("RadialMenu is opened")
                    onOpen()
                case .Highlighted:
                    println("State is highlighted")
                case .Selected:
                    println("State is selected")
                case .Closing:
                    println("State is closing")
            }
        }
    }
    
    // MARK: Init

    init(coder decoder: NSCoder!) {
        subMenus = []
        println("InitWithCoder")
        super.init(coder: decoder)
    }
    
    init(text: Array<String>) {
        subMenus = text.map { itemText in
            let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            return RadialSubMenu(frame: frame)
        }
        
        // FIXME: hrmm... this doesn't seem right...
        super.init(coder: nil)
        
        for subMenu in subMenus {
            self.addSubview(subMenu)
            subMenu.delegate = self
        }
        
        println("InitWithMenus = \(subMenus)")
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
            numOpeningSubMenus++
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
        
        // FIXME: Animations closed....
        state = State.Closed
    }
    
    func moveAtPosition(position:CGPoint) {
        println("Moving")
        
    }
    
    // MARK: RadialSubMenuDelegate
    func subMenuDidOpen(subMenu: RadialSubMenu) {
        if (++numOpenedSubMenus == numOpeningSubMenus) {
            state = State.Opened
        }
    }
    
    func subMenuDidClose(subMenu: RadialSubMenu) {
        if (--numOpenedSubMenus == 0) {
            state = State.Closed
        }
    }
    
    func subMenuDidHighlight(subMenu: RadialSubMenu) {
        
    }
    
    func subMenuDidUnhighlight(subMenu: RadialSubMenu) {
        
    }
    
    func subMenuDidSelect(subMenu: RadialSubMenu) {
        
    }
    
    // FIXME: Why doesn't this update in IB?
    override func prepareForInterfaceBuilder() {
        self.backgroundColor = UIColor.greenColor()
    }
    
}
