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
import pop

let defaultRadius:CGFloat = 115

@IBDesignable
open class RadialMenu: UIView, RadialSubMenuDelegate {
    
    // configurable properties
    @IBInspectable open var radius:CGFloat = defaultRadius
    @IBInspectable open var subMenuScale:CGFloat = 0.75
    @IBInspectable open var highlightScale:CGFloat = 1.15
    
    var subMenuRadius: CGFloat {
        get {
            return radius * subMenuScale
        }
    }
    
    var subMenuHighlightedRadius: CGFloat {
        get {
            return radius * (subMenuScale * highlightScale)
        }
    }
    
    @IBInspectable open var radiusStep = 0.0
    @IBInspectable open var openDelayStep = 0.05
    @IBInspectable open var closeDelayStep = 0.035
    @IBInspectable open var activatedDelay = 0.0
    @IBInspectable open var minAngle = 180
    @IBInspectable open var maxAngle = 540
    @IBInspectable open var allowMultipleHighlights = false
    
    // get's set automatically on initialized to a percentage of radius
    @IBInspectable open var highlightDistance:CGFloat = 0
    
    // FIXME: Needs better solution
    // Fixes issue with highlighting too close to center (get set automatically..can be changed)
    var minHighlightDistance:CGFloat = 0
    
    
    // Callbacks
    // FIXME: Easier way to handle optional callbacks?
    public typealias RadialMenuCallback = () -> ()
    public typealias RadialSubMenuCallback = (_ subMenu: RadialSubMenu) -> ()
    
    open var onOpening: RadialMenuCallback?
    open var onOpen: RadialMenuCallback?
    open var onClosing: RadialMenuCallback?
    open var onClose: RadialMenuCallback?
    open var onHighlight: RadialSubMenuCallback?
    open var onUnhighlight: RadialSubMenuCallback?
    open var onActivate: RadialSubMenuCallback?
    
    // FIXME: Is it possible to scale a view without changing it's children? Couldn't get that
    // working so put bg on it's own view
    open let backgroundView = UIView()
    
    // FIXME: Make private when Swift adds access controls
    open var subMenus: [RadialSubMenu]
    
    var numOpeningSubMenus = 0
    var numOpenedSubMenus = 0
    var numHighlightedSubMenus = 0
    var addedConstraints = false
    
    var position = CGPoint.zero
    
    enum State {
        case closed, opening, opened, highlighted, unhighlighted, activated, closing
    }
    
    var state: State = .closed {
        didSet {
            if oldValue == state { return }
            // FIXME: open/close callbacks are called up here but (un)highlight/activate are called below
            // we're abusing the fact that state changes are only called once here
            // but can't pass submenu context without ugly global state
            switch state {
                case .closed:
                    onClose?()
                case .opened:
                    onOpen?()
                case .opening:
                    onOpening?()
                case .closing:
                    onClosing?()
                default:
                    break
            }
        }
    }
    
    // MARK: Init

    required public init?(coder decoder: NSCoder) {
        subMenus = []
        super.init(coder: decoder)
    }
    
    override public init(frame: CGRect) {
        subMenus = []
        super.init(frame: frame)
    }
    
    convenience public init(menus: [RadialSubMenu]) {
        self.init(menus: menus, radius: defaultRadius)
    }
    
    convenience public init(menus: [RadialSubMenu], radius: CGFloat) {
        self.init(frame: CGRect(x: 0, y: 0, width: radius*2, height: radius*2))
        self.subMenus = menus
        self.radius = radius
        
        for (i, menu) in subMenus.enumerated() {
            menu.delegate = self
            menu.tag = i
            self.addSubview(menu)
        }
        
        setup()
    }
    
    func setup() {
        
        layer.zPosition = -2
        
        // set a sane highlight distance by default..might need to be tweaked based on your needs
        highlightDistance = radius * 0.75 // allow aggressive highlights near submenu
        minHighlightDistance = radius * 0.25 // but not within 25% of center
        
        backgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        backgroundView.layer.zPosition = -1
        backgroundView.frame = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
        backgroundView.layer.cornerRadius = radius
        backgroundView.center = center
        
        // Initial transform size can't be 0 - https://github.com/facebook/pop/issues/24
        backgroundView.transform = CGAffineTransform(scaleX: 0.000001, y: 0.000001)
        
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
    
    open func openAtPosition(_ newPosition: CGPoint) {
        
        let max = subMenus.count
        
        if max == 0 {
            return print("No submenus to open")
        }
        
        if state != .closed {
            return print("Can only open closed menus")
        }
        
        resetDefaults()
        
        state = .opening
        position = newPosition
        
        show()
        
        let relPos = convert(position, from:superview)
        
        for (i, subMenu) in subMenus.enumerated() {
            let subMenuPos = getPositionForSubMenu(subMenu)
            let delay = openDelayStep * Double(i)
            numOpeningSubMenus += 1
            subMenu.openAt(subMenuPos, fromPosition: relPos, delay: delay)
        }
    }
    
    func getAngleForSubMenu(_ subMenu: RadialSubMenu) -> Double {
        let fullCircle = isFullCircle(minAngle, maxAngle: maxAngle)
        let max = fullCircle ? subMenus.count : subMenus.count - 1
        return getAngleForIndex(subMenu.tag, max: max, minAngle: Double(minAngle), maxAngle: Double(maxAngle))
    }
    
    func getPositionForSubMenu(_ subMenu: RadialSubMenu) -> CGPoint {
        return getPositionForSubMenu(subMenu, radius: Double(subMenuRadius))
    }
    
    func getExpandedPositionForSubMenu(_ subMenu: RadialSubMenu) -> CGPoint {
        return getPositionForSubMenu(subMenu, radius: Double(subMenuHighlightedRadius))
    }
    
    func getPositionForSubMenu(_ subMenu: RadialSubMenu, radius: Double) -> CGPoint {
        let angle = getAngleForSubMenu(subMenu)
        let absRadius = radius + (radiusStep * Double(subMenu.tag))
        let circlePos = getPointForAngle(angle, radius: absRadius)
        let relPos = CGPoint(x: position.x + circlePos.x, y: position.y + circlePos.y)
        return self.convert(relPos, from:self.superview)
    }
    
    open func close() {
        
        if (state == .closed || state == .closing) {
            return print("Menu is already closed/closing")
        }
        
        state = .closing
        
        for (i, subMenu) in subMenus.enumerated() {
            let delay = closeDelayStep * Double(i)
            
            if subMenu.state == .highlighted {
                let closeDelay = (closeDelayStep * Double(subMenus.count)) + activatedDelay
                subMenu.activate(closeDelay)
            } else {
                subMenu.close(delay)
            }
        }
    }
    
    // FIXME: Refactor entire method
    open func moveAtPosition(_ position:CGPoint) {
        
        if state != .opened && state != .highlighted && state != .unhighlighted {
            return
        }
        
        
        let relPos = convert(position, from:superview)
        let distanceFromCenter = distanceBetweenPoints(position, p2: center)
        
        // Add all submenus within a certain distance to array
        var distances:[(distance: Double, subMenu: RadialSubMenu)] = []
        
        var highlightDistance = self.highlightDistance
        if numHighlightedSubMenus > 0 {
            highlightDistance = highlightDistance * highlightScale
        }
        
        for subMenu in subMenus {
            
            let distance = distanceBetweenPoints(subMenu.center, p2: relPos)
            if distanceFromCenter >= Double(minHighlightDistance) && distance <= Double(highlightDistance) {
                distances.append(distance: distance, subMenu: subMenu)
                
            } else if subMenu.state == .highlighted {
                subMenu.unhighlight()
            }
        }
        
        if distances.count == 0 { return }
        
        distances.sort { $0.distance < $1.distance }
        
        var shouldHighlight: [RadialSubMenu] = []
        
        for (index, element): (Int, (distance: Double, subMenu: RadialSubMenu)) in distances.enumerated() {
            
            switch (index, allowMultipleHighlights) {
                case (0, false), (_, true):
                    shouldHighlight.append(element.1)
                case (_, _) where element.1.state == .highlighted:
                    element.1.unhighlight()
                default:
                    break
            }
        }
        
        // Make sure all submenus are unhighlighted before any should be highlighted
        for subMenu in shouldHighlight {
            subMenu.highlight()
        }
    }
    
    // FIXME: Clean this up & make it more clear what's happening
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
    
    func scaleBackgroundView(_ size: CGFloat) {
        
        var anim = backgroundView.pop_animation(forKey: "scale") as? POPSpringAnimation
        let toValue = NSValue(cgPoint: CGPoint(x: size, y: size))
        
        if ((anim) != nil) {
            anim!.toValue = toValue
        } else {
            anim = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
            anim!.toValue = toValue
            backgroundView.pop_add(anim, forKey: "scale")
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
    
    func moveSubMenuToPosition(_ subMenu: RadialSubMenu, pos: CGPoint) {
        
        var anim = subMenu.pop_animation(forKey: "expand") as? POPSpringAnimation
        let toValue = NSValue(cgPoint: pos)
        
        if ((anim) != nil) {
            anim!.toValue = toValue
        } else {
            anim = POPSpringAnimation(propertyNamed: kPOPViewCenter)
            anim!.toValue = toValue
            subMenu.pop_add(anim, forKey: "expand")
        }
    }
    
    // MARK: RadialSubMenuDelegate
    
    open func subMenuDidOpen(_ subMenu: RadialSubMenu) {
        numOpenedSubMenus += 1
        if numOpenedSubMenus == numOpeningSubMenus {
            state = .opened
        }
    }
    
    open func subMenuDidClose(_ subMenu: RadialSubMenu) {
        numOpeningSubMenus -= 1
        numOpenedSubMenus -= 1
        if numOpeningSubMenus == 0 || numOpenedSubMenus == 0 {
            hide()
            state = .closed
        }
    }
    
    open func subMenuDidHighlight(_ subMenu: RadialSubMenu) {
        state = .highlighted
        onHighlight?(subMenu)
        numHighlightedSubMenus += 1
        if numHighlightedSubMenus >= 1 {
            grow()
        }
    }
    
    open func subMenuDidUnhighlight(_ subMenu: RadialSubMenu) {
        state = .unhighlighted
        numHighlightedSubMenus -= 1
        onUnhighlight?(subMenu)
        if numHighlightedSubMenus == 0 {
            shrink()
        }
    }
    
    open func subMenuDidActivate(_ subMenu: RadialSubMenu) {
        state = .activated
        onActivate?(subMenu)
    }
}
