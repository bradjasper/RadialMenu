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
    @IBInspectable var openDelayStep: Double = 0.5
    @IBInspectable var closeDelayStep: Double = 0.25
    @IBInspectable var selectedDelay: Double = 50
    @IBInspectable var minAngle: Int = 180
    @IBInspectable var maxAngle: Int = 540
    @IBInspectable var allowMultipleHighlights: Bool = false
    
    // FIXME: shorter syntax?
    var onOpen: () -> () = {}
    var onClose: () -> () = {}
    
    let subMenus: RadialSubMenu[]
    
    var numOpeningSubMenus = 0
    var numOpenedSubMenus = 0
    
    var position = CGPointZero
    
    enum State {
        case Closed, Opening, Opened, Highlighted, Selected, Closing
    }
    
    var state: State = .Closed {
        didSet {
            if oldValue == state { return }
            switch state {
                case .Closed:
                    onClose()
                case .Opened:
                    onOpen()
                default:
                    break
            }
        }
    }
    
    // MARK: Init

    init(coder decoder: NSCoder!) {
        subMenus = []
        super.init(coder: decoder)
    }
    
    init(frame: CGRect) {
        subMenus = []
        super.init(frame: frame)
    }
    
    init(menus: RadialSubMenu[]) {
        subMenus = menus
        super.init(frame: CGRectZero)
        
        for (i, menu) in enumerate(subMenus) {
            menu.delegate = self
            menu.tag = i
            self.addSubview(menu)
        }
    }
    
    convenience init(text: String[]) {
        var menus: RadialSubMenu[] = []
        for string in text {
            menus.append(RadialSubMenu(text: string))
        }
        
        self.init(menus: menus)
    }
    
    // After: Swift
    
    func openAtPosition(position: CGPoint) {
        
        let max = subMenus.count
        
        if max == 0         { return println("No submenus to open")        }
        if state != .Closed { return println("Can only open closed menus") }
        
        state = .Opening
        self.position = position
        numOpenedSubMenus = 0
        numOpeningSubMenus = 0
        
        let fullCircle = isFullCircle(minAngle, maxAngle)
        
        for (i, subMenu) in enumerate(subMenus) {
            let subMenuPos = getPositionForSubMenu(i, max: max, overlap: fullCircle)
            let delay = openDelayStep * Double(i)
            numOpeningSubMenus++
            subMenu.openAt(subMenuPos, fromPosition: position, delay: delay)
        }
        
        
    }
    
    func getPositionForSubMenu(idx: Int, max: Int, overlap: Bool) -> CGPoint {
        
        let absMax = overlap ? max : max - 1
        let absRadius = radius + (radiusStep * Double(idx))
        let relPos = getPointAlongCircle(idx, max, Double(minAngle), Double(maxAngle), radius)
        let posX = position.x + relPos.x
        let posY = position.y + relPos.y
        return CGPoint(x: posX, y: posY)
    }
    
    
    func close() {
        
        if (state == .Closed) { return println("Menu is already closed") }
        
        state = .Closing
        
        for (i, subMenu) in enumerate(subMenus) {
            let delay = closeDelayStep * Double(i)
            subMenu.close(delay)
        }
        
    }
    
    func moveAtPosition(position:CGPoint) {
        
    }
    
    // MARK: RadialSubMenuDelegate
    
    func subMenuDidOpen(subMenu: RadialSubMenu) {
        if ++numOpenedSubMenus == numOpeningSubMenus {
            state = .Opened
        }
    }
    
    func subMenuDidClose(subMenu: RadialSubMenu) {
        if --numOpenedSubMenus == 0 {
            state = .Closed
        }
    }
    
    func subMenuDidHighlight(subMenu: RadialSubMenu) {
        
    }
    
    func subMenuDidUnhighlight(subMenu: RadialSubMenu) {
        
    }
    
    func subMenuDidSelect(subMenu: RadialSubMenu) {
        
    }
}
