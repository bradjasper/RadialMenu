//
//  RadialSubMenu.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/6/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit
import QuartzCore

let RadialSubMenuOpenAnimation = "openAnimation"
let RadialSubMenuCloseAnimation = "closeAnimation"

// Using @objc here because we want to specify @optional methods which
// you can only do on classes, which you specify with the @objc modifier
@objc protocol RadialSubMenuDelegate {
    @optional func subMenuDidOpen(subMenu: RadialSubMenu)
    @optional func subMenuDidHighlight(subMenu: RadialSubMenu)
    @optional func subMenuDidSelect(subMenu: RadialSubMenu)
    @optional func subMenuDidUnhighlight(subMenu: RadialSubMenu)
    @optional func subMenuDidClose(subMenu: RadialSubMenu)
}

class RadialSubMenu: UIView, POPAnimationDelegate {
    
    enum State {
        case Closed, Opening, Opened, Highlighting, Highlighted, Selected, Unhighlighting, Closing
    }

    var delegate: RadialSubMenuDelegate?
    var origPosition         = CGPointZero
    var currPosition         = CGPointZero
    var origBounds           = CGRectZero
    var origFrame            = CGRectZero
    
    var openDelay            = 0.0
    var closeDelay           = 0.0
    
    var closeDuration        = 1.0
    var openSpringSpeed      = 12.0
    var openSpringBounciness = 4.0
    
    var state: State = .Closed {
        didSet {
            if oldValue == state { return }
            switch state {
                case .Opened:
                    delegate?.subMenuDidOpen?(self)
                case .Highlighted:
                    delegate?.subMenuDidHighlight?(self)
                case .Selected:
                    delegate?.subMenuDidSelect?(self)
                case .Unhighlighting:
                    delegate?.subMenuDidUnhighlight?(self)
                case .Closed:
                    delegate?.subMenuDidClose?(self)
                default:
                    break
            }
        }
    }
   
    // MARK - Init
    
    init(frame: CGRect) {
        super.init(frame: frame)
        origFrame = self.frame
        origBounds = self.bounds
        origPosition = self.center
    }
    
    convenience init(text: String) {
        self.init(frame: CGRectZero)
    }
    
    // MARK - Main interface
    
    func openAt(position: CGPoint, fromPosition: CGPoint, delay: Double) {
        println("Opening at position=\(position) with delay=\(delay)")
        
        state = .Opening
        openDelay = delay
        currPosition = position
        origPosition = fromPosition
        
        // reset center to origPosition
        self.center = origPosition
        
        self.openAnimation()
    }
    
    func openAt(position: CGPoint, fromPosition: CGPoint) {
        self.openAt(position, fromPosition: fromPosition, delay: 0)
    }
    
    func close(delay: Double) {
        state = .Closing
        closeDelay = delay
        self.closeAnimation()
    }
    
    func close() {
        self.close(0)
    }
    
    // MARK - Animations
    
    func openAnimation() {
        // Is there a way to do the opposite of "if let"? Make these two statements one?
        let existingAnim = self.pop_animationForKey(RadialSubMenuOpenAnimation) as? POPAnimation
        if !existingAnim {
            let anim = POPSpringAnimation(propertyNamed:kPOPViewCenter)
            anim.name = RadialSubMenuOpenAnimation
            anim.toValue = NSValue(CGPoint: currPosition)
            anim.beginTime = CACurrentMediaTime() + openDelay
            anim.springBounciness = CGFloat(openSpringBounciness)
            anim.springSpeed = CGFloat(openSpringSpeed)
            anim.delegate = self
            self.pop_addAnimation(anim, forKey: RadialSubMenuOpenAnimation)
        }
        
    }
    
    func closeAnimation() {
        let existingAnim = self.pop_animationForKey(RadialSubMenuCloseAnimation) as? POPAnimation
        if !existingAnim {
            let anim = POPBasicAnimation(propertyNamed:kPOPViewCenter)
            anim.name = RadialSubMenuCloseAnimation
            anim.toValue = NSValue(CGPoint: origPosition)
            anim.duration = closeDuration
            anim.beginTime = CACurrentMediaTime() + closeDelay
            anim.delegate = self
            self.pop_addAnimation(anim, forKey: RadialSubMenuCloseAnimation)
        }
        
    }
    
    // MARK - POP animation delegates
    
    func pop_animationDidStart(anim: POPAnimation!) {
        switch anim.name {
            case RadialSubMenuOpenAnimation:
                break
            case RadialSubMenuCloseAnimation:
                break
            default:
                break
        }
        
    }
    
    func pop_animationDidStop(anim: POPAnimation!, finished: Bool) {
        
        if !finished { return }
        
        switch (anim.name!, state) {
            case (RadialSubMenuOpenAnimation, _):
                state = .Opened
            case (RadialSubMenuCloseAnimation, _):
                state = .Closed
            case (RadialSubMenuOpenAnimation, .Closing):
                self.closeAnimation()
            case (RadialSubMenuCloseAnimation, .Opening):
                self.openAnimation()
            default:
                break
        }
    }
    

}
