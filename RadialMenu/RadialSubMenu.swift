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
let RadialSubMenuFadeInAnimation = "fadeInAnimation"
let RadialSubMenuFadeOutAnimation = "fadeOutAnimation"

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
    
    var openDelay            = 0.0
    var closeDelay           = 0.0
    
    var closeDuration        = 0.25
    var openSpringSpeed      = 12.0
    var openSpringBounciness = 12.0
    
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
                    
                    // A race condition exists where an open could get triggered after
                    // a close due to a long delay. So cancel any open animations once closed
                    self.pop_removeAnimationForKey(RadialSubMenuOpenAnimation)
                    self.pop_removeAnimationForKey(RadialSubMenuFadeInAnimation)
                default:
                    break
            }
        }
    }
   
    // MARK - Init
    
    init(frame: CGRect) {
        super.init(frame: frame)
        origPosition = self.center
        self.alpha = 0
    }
    
    convenience init(text: String) {
        self.init(frame: CGRectZero)
    }
    
    // MARK - Main interface
    
    func openAt(position: CGPoint, fromPosition: CGPoint, delay: Double) {
        println("Opening at \(position) from \(fromPosition) with delay=\(delay)")
        
        
        state = .Opening
        openDelay = delay
        currPosition = position
        origPosition = fromPosition
        
        // reset center to origPosition
        self.center = origPosition
        
        self.openAnimation()
    }
    
    func openAt(position: CGPoint, fromPosition: CGPoint) {
        
        // Race condition
        self.openAt(position, fromPosition: fromPosition, delay: 0)
    }
    
    func close(delay: Double) {
        
        if (state == .Opening) {
        }
        
        state = .Closing
        closeDelay = delay
        self.closeAnimation()
    }
    
    func close() {
        self.close(0)
    }
    
    // MARK - Animations
    
    func openAnimation() {
        // FIXME: Is there a way to do the opposite of "if let"? Make these two statements one?
        let existingAnim = self.pop_animationForKey(RadialSubMenuOpenAnimation) as? POPAnimation
        if !existingAnim {
            let anim = POPSpringAnimation(propertyNamed:kPOPViewCenter)
            anim.name = RadialSubMenuOpenAnimation
            anim.toValue = NSValue(CGPoint: currPosition)
            anim.beginTime = CACurrentMediaTime() + openDelay
            anim.springBounciness = CGFloat(openSpringBounciness)
            anim.springSpeed = CGFloat(openSpringSpeed)
            anim.delegate = self
            self.pop_addAnimation(anim, forKey:RadialSubMenuOpenAnimation)
        }
        
    }
    
    func closeAnimation() {
        // FIXME: Is there a way to do the opposite of "if let"? Make these two statements one?
        let existingAnim = self.pop_animationForKey(RadialSubMenuCloseAnimation) as? POPAnimation
        if !existingAnim {
            let anim = POPBasicAnimation(propertyNamed:kPOPViewCenter)
            anim.name = RadialSubMenuCloseAnimation
            anim.toValue = NSValue(CGPoint: origPosition)
            anim.duration = closeDuration
            anim.beginTime = CACurrentMediaTime() + closeDelay
            anim.delegate = self
            self.pop_addAnimation(anim, forKey:RadialSubMenuCloseAnimation)
        }
        
    }
    
    func fadeInAnimation() {
        
        let toValue = NSNumber(float: 1.0)
        
        if let existingAnim = self.pop_animationForKey(RadialSubMenuFadeInAnimation) as? POPSpringAnimation {
            existingAnim.toValue = toValue
        } else {
            let anim = POPSpringAnimation(propertyNamed:kPOPViewAlpha)
            anim.name = RadialSubMenuFadeInAnimation
            anim.toValue = toValue
            anim.springBounciness = CGFloat(openSpringBounciness)
            anim.springSpeed = CGFloat(openSpringSpeed)
            anim.delegate = self
            self.pop_addAnimation(anim, forKey:RadialSubMenuFadeInAnimation)
        }
    }
    
    func fadeOutAnimation() {
        
        let toValue = NSNumber(float: 0.0)
        
        if let existingAnim = self.pop_animationForKey(RadialSubMenuFadeOutAnimation) as? POPBasicAnimation {
            existingAnim.toValue = toValue
        } else {
            let anim = POPBasicAnimation(propertyNamed:kPOPViewAlpha)
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            anim.name = RadialSubMenuFadeOutAnimation
            anim.toValue = toValue
            anim.duration = closeDuration
            anim.delegate = self
            self.pop_addAnimation(anim, forKey:RadialSubMenuFadeOutAnimation)
        }
    }
    
    func removeAllAnimations() {
        self.pop_removeAnimationForKey(RadialSubMenuOpenAnimation)
        self.pop_removeAnimationForKey(RadialSubMenuCloseAnimation)
        self.pop_removeAnimationForKey(RadialSubMenuFadeInAnimation)
        self.pop_removeAnimationForKey(RadialSubMenuFadeOutAnimation)
    }
    
    
    // MARK - POP animation delegates
    
    func pop_animationDidStart(anim: POPAnimation!) {
        switch anim.name {
            case RadialSubMenuOpenAnimation:
                self.fadeInAnimation()
            case RadialSubMenuCloseAnimation:
                self.fadeOutAnimation()
            default:
                break
        }
        
    }
    
    func pop_animationDidStop(anim: POPAnimation!, finished: Bool) {
        
        if !finished { return }
        
        switch (anim.name!, state) {
            case (RadialSubMenuOpenAnimation, _):
                println("\(tag) OPENED")
                state = .Opened
            case (RadialSubMenuCloseAnimation, _):
                println("\(tag) CLOSED")
                state = .Closed
            case (RadialSubMenuOpenAnimation, .Closing):
                println("\(tag) OPENED -> CLOSE")
                self.closeAnimation()
            case (RadialSubMenuCloseAnimation, .Opening):
                println("\(tag) CLOSED -> OPEN")
                self.openAnimation()
            default:
                break
        }
    }
    

}
