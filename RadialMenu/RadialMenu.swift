//
//  RadialMenu.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/5/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

// FIXME: Split out into smaller pieces

import UIKit
import QuartzCore

@IBDesignable
class RadialMenu: UIView, RadialSubMenuDelegate {
    
    // configurable properties
    @IBInspectable var radius:Float = 135
    @IBInspectable var subMenuScale:Float = 0.7
    @IBInspectable var highlightScale:Float = 1.2
    
    var subMenuRadius: Float {
        get {
            return Float(radius) * subMenuScale
        }
    }
    
    var subMenuExpandedRadius: Float {
        get {
            return Float(radius) * (subMenuScale * highlightScale)
        }
    }
    
    @IBInspectable var radiusStep = 0.0
    @IBInspectable var openDelayStep = 0.05
    @IBInspectable var closeDelayStep = 0.035
    @IBInspectable var activatedDelay = 1.0
    @IBInspectable var minAngle = 180
    @IBInspectable var maxAngle = 540
    @IBInspectable var highlightDistance = 65.0
    @IBInspectable var allowMultipleHighlights = false
    
    
    // Callbacks
    // FIXME: Easier way to handle optional callbacks?
    typealias RadialMenuCallback = () -> ()
    typealias RadialSubMenuCallback = (subMenu: RadialSubMenu) -> ()
    
    var onOpening: RadialMenuCallback?
    var onOpen: RadialMenuCallback?
    var onClosing: RadialMenuCallback?
    var onClose: RadialMenuCallback?
    var onHighlight: RadialSubMenuCallback?
    var onUnhighlight: RadialSubMenuCallback?
    var onActivate: RadialSubMenuCallback?
    
    // FIXME: Is it possible to scale a view without changing it's children? Couldn't get that
    // working so put bg on it's own view
    let backgroundView = UIView()
    
    // FIXME: Make private when Swift adds access controls
    let subMenus: RadialSubMenu[]
    
    var numOpeningSubMenus = 0
    var numOpenedSubMenus = 0
    var numHighlightedSubMenus = 0
    var addedConstraints = false
    
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
                case .Opening:
                    onOpening?()
                case .Closing:
                    onClosing?()
                default:
                    break
            }
        }
    }
    
    // MARK: Init

    init(coder decoder: NSCoder!) {
        subMenus = []
        super.init(coder: decoder)
        setup()
    }
    
    init(frame: CGRect) {
        subMenus = []
        super.init(frame: frame)
        setup()
    }
    
    convenience init(menus: RadialSubMenu[]) {
        // FIXME: Magic number. Can't use radius here because it uses self....how to make DRY?
        self.init(menus: menus, radius: 100)
    }
    
    convenience init(menus: RadialSubMenu[], radius: Float) {
        self.init(frame: CGRect(x: 0, y: 0, width: radius*2, height: radius*2))
        subMenus = menus
        
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
    
    func setup() {
        layer.zPosition = -2
        backgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        backgroundView.layer.zPosition = -1
        backgroundView.frame = CGRectMake(0, 0, radius*2, radius*2)
        backgroundView.layer.cornerRadius = radius
        backgroundView.center = center
        
        // Initial transform size can't be 0 - https://github.com/facebook/pop/issues/24
        backgroundView.transform = CGAffineTransformMakeScale(0.000001, 0.000001)
        
        addSubview(backgroundView)
    }
    
    func resetDefaults() {
        
        numOpenedSubMenus = 0
        numOpeningSubMenus = 0
        numHighlightedSubMenus = 0
        
        for subMenu in subMenus {
            subMenu.removeAllAnimations()
        }
    }
    
    func openAtPosition(newPosition: CGPoint) {
        
        let max = subMenus.count
        
        if max == 0 {
            return println("No submenus to open")
        }
        
        if state != .Closed {
            return println("Can only open closed menus")
        }
        
        resetDefaults()
        
        state = .Opening
        position = newPosition
        
        show()
        
        let relPos = convertPoint(position, fromView:superview)
        
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
        return getPositionForSubMenu(subMenu, radius: Double(subMenuRadius))
    }
    
    func getExpandedPositionForSubMenu(subMenu: RadialSubMenu) -> CGPoint {
        return getPositionForSubMenu(subMenu, radius: Double(subMenuExpandedRadius))
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
        
        let relPos = convertPoint(position, fromView:superview)
        
        // Add all submenus within a certain distance to array
        var distances:(distance: Double, subMenu: RadialSubMenu)[] = []
        for subMenu in subMenus {
            
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
    
    func grow() {
        scaleBackgroundView(highlightScale)
        growSubMenus()
    }
    
    func shrink() {
        scaleBackgroundView(1)
        shrinkSubMenus()
    }
    
    func show() {
        scaleBackgroundView(1)
    }
    
    func hide() {
        scaleBackgroundView(0)
    }
    
    func scaleBackgroundView(size: Float) {
        
        var anim = backgroundView.pop_animationForKey("scale") as? POPSpringAnimation
        let toValue = NSValue(CGPoint: CGPoint(x: size, y: size))
        
        if (anim) {
            anim!.toValue = toValue
        } else {
            anim = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
            anim!.toValue = toValue
            backgroundView.pop_addAnimation(anim, forKey: "scale")
        }
    }
    
    
    func growSubMenus() {
        
        // FIXME: Refactor
        for subMenu in subMenus {
            let subMenuPos = getExpandedPositionForSubMenu(subMenu)
            moveSubMenuToPosition(subMenu, pos: subMenuPos)
        }
    }
    
    func shrinkSubMenus() {
        
        // FIXME: Refactor
        for subMenu in subMenus {
            let subMenuPos = getPositionForSubMenu(subMenu)
            moveSubMenuToPosition(subMenu, pos: subMenuPos)
        }
    }
    
    func moveSubMenuToPosition(subMenu: RadialSubMenu, pos: CGPoint) {
        
        println("EXPAND!")
        
        var anim = subMenu.pop_animationForKey("expand") as? POPSpringAnimation
        let toValue = NSValue(CGPoint: pos)
        
        if (anim) {
            anim!.toValue = toValue
        } else {
            anim = POPSpringAnimation(propertyNamed: kPOPViewCenter)
            anim!.toValue = toValue
            subMenu.pop_addAnimation(anim, forKey: "expand")
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
            hide()
            state = .Closed
        }
    }
    
    func subMenuDidHighlight(subMenu: RadialSubMenu) {
        state = .Highlighted
        onHighlight?(subMenu: subMenu)
        if ++numHighlightedSubMenus >= 1 {
            grow()
        }
    }
    
    func subMenuDidUnhighlight(subMenu: RadialSubMenu) {
        state = .Unhighlighted
        onUnhighlight?(subMenu: subMenu)
        if --numHighlightedSubMenus == 0 {
            shrink()
        }
    }
    
    func subMenuDidActivate(subMenu: RadialSubMenu) {
        state = .Activated
        onActivate?(subMenu: subMenu)
    }
}
