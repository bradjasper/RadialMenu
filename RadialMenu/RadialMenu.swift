//
//  RadialMenu.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/5/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
class RadialMenu: UIView, RadialSubMenuDelegate {
    
    // configurable properties
    @IBInspectable var radius: Double = 100
    @IBInspectable var radiusStep: Double = 0
    @IBInspectable var openDelayStep: Double = 0.05
    @IBInspectable var closeDelayStep: Double = 0.035
    @IBInspectable var activatedDelay: Double = 1
    @IBInspectable var minAngle: Int = 180
    @IBInspectable var maxAngle: Int = 540
    @IBInspectable var highlightDistance = 75.0
    @IBInspectable var allowMultipleHighlights: Bool = false
    
    
    // Callbacks
    // FIXME: Easier way to handle optional callbacks?
    typealias RadialMenuCallback = () -> ()
    typealias RadialSubMenuCallback = (subMenu: RadialSubMenu) -> ()
    
    var onOpen: RadialMenuCallback?
    var onClose: RadialMenuCallback?
    var onHighlight: RadialSubMenuCallback?
    var onUnhighlight: RadialSubMenuCallback?
    var onActivate: RadialSubMenuCallback?
    
    
    // private
    let subMenus: RadialSubMenu[]
    
    var numOpeningSubMenus = 0
    var numOpenedSubMenus = 0
    
    var position = CGPointZero
    
    enum State {
        case Closed, Opening, Opened, Highlighted, Unhighlighted, Activated, Closing
    }
    
    var state: State = .Closed {
        didSet {
            if oldValue == state { return }
            // FIXME: open/close callbacks are called up here but (un)highlight/activate are called below
            // we're abusing the fact that state changes are only called once here
            // but can't pass submenu context without ugly global state
            switch state {
                case .Closed:
                    onClose?()
                case .Opened:
                    onOpen?()
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
    
    func cleanup() {
        for subMenu in subMenus {
            subMenu.removeAllAnimations()
        }
    }
    
    func openAtPosition(position: CGPoint) {
        
        let max = subMenus.count
        
        if max == 0         { return println("No submenus to open")        }
        if state != .Closed { return println("Can only open closed menus") }
        
        self.cleanup()
        state = .Opening
        self.position = position
        numOpenedSubMenus = 0
        numOpeningSubMenus = 0
        
        let fullCircle = isFullCircle(minAngle, maxAngle)
        let relPos = self.convertPoint(position, fromView:self.superview)
        
        for (i, subMenu) in enumerate(subMenus) {
            let subMenuPos = getPositionForSubMenu(subMenu)
            let delay = openDelayStep * Double(i)
            numOpeningSubMenus++
            subMenu.openAt(subMenuPos, fromPosition: relPos, delay: delay)
        }
        
        
    }
    
    func getAngleForSubMenu(subMenu: RadialSubMenu) -> Double {
        let fullCircle = isFullCircle(minAngle, maxAngle)
        let max = fullCircle ? subMenus.count : subMenus.count - 1
        return getAngleForIndex(subMenu.tag, max, Double(minAngle), Double(maxAngle))
    }
    
    func getPositionForSubMenu(subMenu: RadialSubMenu) -> CGPoint {
        return getPositionForSubMenu(subMenu, radius: radius)
    }
    
    func getPositionForSubMenu(subMenu: RadialSubMenu, radius: Double) -> CGPoint {
        let angle = getAngleForSubMenu(subMenu)
        let absRadius = radius + (radiusStep * Double(subMenu.tag))
        let circlePos = getPointForAngle(angle, absRadius)
        let relPos = CGPoint(x: position.x + circlePos.x, y: position.y + circlePos.y)
        return self.convertPoint(relPos, fromView:self.superview)
    }
    
    func close() {
        
        if (state == .Closed || state == .Closing) {
            return println("Menu is already closed/closing")
        }
        
        state = .Closing
        
        for (i, subMenu) in enumerate(subMenus) {
            let delay = closeDelayStep * Double(i)
            
            // FIXME: Why can't I use shortcut enum syntax .Highlighted here?
            if subMenu.state == RadialSubMenu.State.Highlighted {
                let closeDelay = (closeDelayStep * Double(subMenus.count)) + activatedDelay
                subMenu.activate(closeDelay)
            } else {
                subMenu.close(delay)
            }
        }
        
    }
    
    func moveAtPosition(position:CGPoint) {
        
        if state != .Opened && state != .Highlighted && state != .Unhighlighted {
            return
        }
        
        let relPos = self.convertPoint(position, fromView:self.superview)
        
        var distances:(distance: Double, subMenu: RadialSubMenu)[] = []
        for subMenu in subMenus {
            
            // If menu is within highlight distance, add to array
            let distance = distanceBetweenPoints(subMenu.center, relPos)
            if distance <= highlightDistance {
                distances.append(distance: distance, subMenu: subMenu)
                
            } else if subMenu.state == .Highlighted {
                subMenu.unhighlight()
            }
        }
        
        if distances.count == 0 { return }
        
        distances.sort { $0.distance < $1.distance }
        
        for (i, (_, subMenu)) in enumerate(distances) {
            
            switch (i, allowMultipleHighlights) {
                case (0, false):
                    subMenu.highlight()
                case (_, true):
                    subMenu.highlight()
                case (_, _) where subMenu.state == .Highlighted:
                    subMenu.unhighlight()
                default:
                    break
            }
        }
        
    }
    
    // MARK: RadialSubMenuDelegate
    
    func subMenuDidOpen(subMenu: RadialSubMenu) {
        if ++numOpenedSubMenus == numOpeningSubMenus {
            state = .Opened
        }
    }
    
    func subMenuDidClose(subMenu: RadialSubMenu) {
        if --numOpeningSubMenus == 0 || --numOpenedSubMenus == 0 {
            state = .Closed
        }
    }
    
    func subMenuDidHighlight(subMenu: RadialSubMenu) {
        state = .Highlighted
        onHighlight?(subMenu: subMenu)
    }
    
    func subMenuDidUnhighlight(subMenu: RadialSubMenu) {
        state = .Unhighlighted
        onUnhighlight?(subMenu: subMenu)
    }
    
    func subMenuDidActivate(subMenu: RadialSubMenu) {
        state = .Activated
        onActivate?(subMenu: subMenu)
    }
}
