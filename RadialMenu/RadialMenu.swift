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
public class RadialMenu: UIView, RadialSubMenuDelegate {
    
    // configurable properties
    @IBInspectable public var radius:CGFloat = defaultRadius
    @IBInspectable public var subMenuScale:CGFloat = 0.75
    @IBInspectable public var highlightScale:CGFloat = 1.15
    
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
    
    @IBInspectable public var radiusStep = 0.0
    @IBInspectable public var openDelayStep = 0.05
    @IBInspectable public var closeDelayStep = 0.035
    @IBInspectable public var activatedDelay = 0.0
    @IBInspectable public var minAngle = 180
    @IBInspectable public var maxAngle = 540
    @IBInspectable public var allowMultipleHighlights = false
    
    // get's set automatically on initialized to a percentage of radius
    @IBInspectable public var highlightDistance:CGFloat = 0
    
    // FIXME: Needs better solution
    // Fixes issue with highlighting too close to center (get set automatically..can be changed)
    var minHighlightDistance:CGFloat = 0
    
    
    // Callbacks
    // FIXME: Easier way to handle optional callbacks?
    public typealias RadialMenuCallback = () -> ()
    public typealias RadialSubMenuCallback = (subMenu: RadialSubMenu) -> ()
    
    public var onOpening: RadialMenuCallback?
    public var onOpen: RadialMenuCallback?
    public var onClosing: RadialMenuCallback?
    public var onClose: RadialMenuCallback?
    public var onHighlight: RadialSubMenuCallback?
    public var onUnhighlight: RadialSubMenuCallback?
    public var onActivate: RadialSubMenuCallback?
    
    // FIXME: Is it possible to scale a view without changing it's children? Couldn't get that
    // working so put bg on it's own view
    public let backgroundView = UIView()
    
    // FIXME: Make private when Swift adds access controls
    public var subMenus: [RadialSubMenu]
    
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
        
        for (i, menu) in subMenus.enumerate() {
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
    
    public func openAtPosition(newPosition: CGPoint) {
        
        let max = subMenus.count
        
        if max == 0 {
            return print("No submenus to open")
        }
        
        if state != .Closed {
            return print("Can only open closed menus")
        }
        
        resetDefaults()
        
        state = .Opening
        position = newPosition
        
        show()
        
        let relPos = convertPoint(position, fromView:superview)
        
        for (i, subMenu) in subMenus.enumerate() {
            let subMenuPos = getPositionForSubMenu(subMenu)
            let delay = openDelayStep * Double(i)
            numOpeningSubMenus++
            subMenu.openAt(subMenuPos, fromPosition: relPos, delay: delay)
        }
    }
    
    func getAngleForSubMenu(subMenu: RadialSubMenu) -> Double {
        let fullCircle = isFullCircle(minAngle, maxAngle: maxAngle)
        let max = fullCircle ? subMenus.count : subMenus.count - 1
        return getAngleForIndex(subMenu.tag, max: max, minAngle: Double(minAngle), maxAngle: Double(maxAngle))
    }
    
    func getPositionForSubMenu(subMenu: RadialSubMenu) -> CGPoint {
        return getPositionForSubMenu(subMenu, radius: Double(subMenuRadius))
    }
    
    func getExpandedPositionForSubMenu(subMenu: RadialSubMenu) -> CGPoint {
        return getPositionForSubMenu(subMenu, radius: Double(subMenuHighlightedRadius))
    }
    
    func getPositionForSubMenu(subMenu: RadialSubMenu, radius: Double) -> CGPoint {
        let angle = getAngleForSubMenu(subMenu)
        let absRadius = radius + (radiusStep * Double(subMenu.tag))
        let circlePos = getPointForAngle(angle, radius: absRadius)
        let relPos = CGPoint(x: position.x + circlePos.x, y: position.y + circlePos.y)
        return self.convertPoint(relPos, fromView:self.superview)
    }
    
    public func close() {
        
        if (state == .Closed || state == .Closing) {
            return print("Menu is already closed/closing")
        }
        
        state = .Closing
        
        for (i, subMenu) in subMenus.enumerate() {
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
    
    // FIXME: Refactor entire method
    public func moveAtPosition(position:CGPoint) {
        
        if state != .Opened && state != .Highlighted && state != .Unhighlighted {
            return
        }
        
        
        let relPos = convertPoint(position, fromView:superview)
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
                
            } else if subMenu.state == .Highlighted {
                subMenu.unhighlight()
            }
        }
        
        if distances.count == 0 { return }
        
        distances.sortInPlace { $0.distance < $1.distance }
        
        var shouldHighlight: [RadialSubMenu] = []
        
        for (index, element): (Int, (distance: Double, subMenu: RadialSubMenu)) in distances.enumerate() {
            
            switch (index, allowMultipleHighlights) {
                case (0, false), (_, true):
                    shouldHighlight.append(element.1)
                case (_, _) where element.1.state == .Highlighted:
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
    
    func scaleBackgroundView(size: CGFloat) {
        
        var anim = backgroundView.pop_animationForKey("scale") as? POPSpringAnimation
        let toValue = NSValue(CGPoint: CGPoint(x: size, y: size))
        
        if ((anim) != nil) {
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
        
        var anim = subMenu.pop_animationForKey("expand") as? POPSpringAnimation
        let toValue = NSValue(CGPoint: pos)
        
        if ((anim) != nil) {
            anim!.toValue = toValue
        } else {
            anim = POPSpringAnimation(propertyNamed: kPOPViewCenter)
            anim!.toValue = toValue
            subMenu.pop_addAnimation(anim, forKey: "expand")
        }
    }
    
    // MARK: RadialSubMenuDelegate
    
    public func subMenuDidOpen(subMenu: RadialSubMenu) {
        if ++numOpenedSubMenus == numOpeningSubMenus {
            state = .Opened
        }
    }
    
    public func subMenuDidClose(subMenu: RadialSubMenu) {
        if --numOpeningSubMenus == 0 || --numOpenedSubMenus == 0 {
            hide()
            state = .Closed
        }
    }
    
    public func subMenuDidHighlight(subMenu: RadialSubMenu) {
        state = .Highlighted
        onHighlight?(subMenu: subMenu)
        if ++numHighlightedSubMenus >= 1 {
            grow()
        }
    }
    
    public func subMenuDidUnhighlight(subMenu: RadialSubMenu) {
        state = .Unhighlighted
        onUnhighlight?(subMenu: subMenu)
        if --numHighlightedSubMenus == 0 {
            shrink()
        }
    }
    
    public func subMenuDidActivate(subMenu: RadialSubMenu) {
        state = .Activated
        onActivate?(subMenu: subMenu)
    }
}
