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
    optional func subMenuDidOpen(subMenu: RadialSubMenu)
    optional func subMenuDidHighlight(subMenu: RadialSubMenu)
    optional func subMenuDidActivate(subMenu: RadialSubMenu)
    optional func subMenuDidUnhighlight(subMenu: RadialSubMenu)
    optional func subMenuDidClose(subMenu: RadialSubMenu)
}

class RadialSubMenu: UIView, POPAnimationDelegate {
    
    enum State {
        case Closed, Opening, Opened, Highlighted, Unhighlighted, Activated, Closing
    }

    var delegate: RadialSubMenuDelegate?
    var origPosition         = CGPointZero
    var currPosition         = CGPointZero
    
    var openDelay            = 0.0
    var closeDelay           = 0.0
    
    var closeDuration        = 0.1
    var openSpringSpeed      = 12.0
    var openSpringBounciness = 6.0
    
    var state: State = .Closed {
        didSet {
            if oldValue == state { return }
            switch state {
                case .Unhighlighted:
                    delegate?.subMenuDidUnhighlight?(self)
                    state = .Opened
                case .Opened:
                    delegate?.subMenuDidOpen?(self)
                case .Highlighted:
                    delegate?.subMenuDidHighlight?(self)
                case .Activated:
                    delegate?.subMenuDidActivate?(self)
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
        origPosition = self.center
        alpha = 0
        
    }
    
    convenience init(imageView: UIImageView) {
        self.init(frame: imageView.frame)
        imageView.userInteractionEnabled = true
        addSubview(imageView)
    }
    
    
    // MARK - Main interface
    
    func openAt(position: CGPoint, fromPosition: CGPoint, delay: Double) {
        
        state = .Opening
        openDelay = delay
        currPosition = position
        origPosition = fromPosition
        
        center = origPosition
        
        openAnimation()
    }
    
    func openAt(position: CGPoint, fromPosition: CGPoint) {
        openAt(position, fromPosition: fromPosition, delay: 0)
    }
    
    func close(delay: Double) {
        
        state = .Closing
        closeDelay = delay
        closeAnimation()
    }
    
    func close() {
        close(0)
    }
    
    func highlight() {
        state = .Highlighted
    }
    
    func unhighlight() {
        state = .Unhighlighted
    }
    
    func activate(delay: Double) {
        closeDelay = delay
        state = .Activated
        closeAnimation()
    }
    
    func activate() {
        activate(0)
    }
    
    // MARK - Animations
    
    func openAnimation() {
        // FIXME: Is there a way to do the opposite of "if let"? Make these two statements one?
        let existingAnim = pop_animationForKey(RadialSubMenuOpenAnimation) as? POPAnimation
        if !existingAnim {
            let anim = POPSpringAnimation(propertyNamed:kPOPViewCenter)
            anim.name = RadialSubMenuOpenAnimation
            anim.toValue = NSValue(CGPoint: currPosition)
            anim.beginTime = CACurrentMediaTime() + openDelay
            anim.springBounciness = CGFloat(openSpringBounciness)
            anim.springSpeed = CGFloat(openSpringSpeed)
            anim.delegate = self
            pop_addAnimation(anim, forKey:RadialSubMenuOpenAnimation)
        }
        
    }
    
    func closeAnimation() {
        // FIXME: Is there a way to do the opposite of "if let"? Make these two statements one?
        let existingAnim = pop_animationForKey(RadialSubMenuCloseAnimation) as? POPAnimation
        if !existingAnim {
            let anim = POPBasicAnimation(propertyNamed:kPOPViewCenter)
            anim.name = RadialSubMenuCloseAnimation
            anim.toValue = NSValue(CGPoint: origPosition)
            anim.duration = closeDuration
            anim.beginTime = CACurrentMediaTime() + closeDelay
            anim.delegate = self
            pop_addAnimation(anim, forKey:RadialSubMenuCloseAnimation)
        }
        
    }
    
    func fadeInAnimation() {
        
        let toValue = NSNumber(float: 1.0)
        
        if let existingAnim = pop_animationForKey(RadialSubMenuFadeInAnimation) as? POPSpringAnimation {
            existingAnim.toValue = toValue
        } else {
            let anim = POPSpringAnimation(propertyNamed:kPOPViewAlpha)
            anim.name = RadialSubMenuFadeInAnimation
            anim.toValue = toValue
            anim.springBounciness = CGFloat(openSpringBounciness)
            anim.springSpeed = CGFloat(openSpringSpeed)
            anim.delegate = self
            pop_addAnimation(anim, forKey:RadialSubMenuFadeInAnimation)
        }
    }
    
    func fadeOutAnimation() {
        
        let toValue = NSNumber(float: 0.0)
        
        if let existingAnim = pop_animationForKey(RadialSubMenuFadeOutAnimation) as? POPBasicAnimation {
            existingAnim.toValue = toValue
        } else {
            let anim = POPBasicAnimation(propertyNamed:kPOPViewAlpha)
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            anim.name = RadialSubMenuFadeOutAnimation
            anim.toValue = toValue
            anim.duration = closeDuration
            anim.delegate = self
            pop_addAnimation(anim, forKey:RadialSubMenuFadeOutAnimation)
        }
    }
    
    func removeAllAnimations() {
        removeOpenAnimations()
        removeCloseAnimations()
    }
    
    func removeCloseAnimations() {
        pop_removeAnimationForKey(RadialSubMenuCloseAnimation)
        pop_removeAnimationForKey(RadialSubMenuFadeOutAnimation)
    }
    
    func removeOpenAnimations() {
        pop_removeAnimationForKey(RadialSubMenuOpenAnimation)
        pop_removeAnimationForKey(RadialSubMenuFadeInAnimation)
    }
    
    
    // MARK - POP animation delegates
    
    func pop_animationDidStart(anim: POPAnimation!) {
        switch anim.name {
            case RadialSubMenuOpenAnimation:
                fadeInAnimation()
            case RadialSubMenuCloseAnimation:
                fadeOutAnimation()
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
                removeOpenAnimations()
            case (RadialSubMenuOpenAnimation, .Closing):
                closeAnimation()
            case (RadialSubMenuCloseAnimation, .Opening):
                openAnimation()
            default:
                break
        }
    }
    

}
