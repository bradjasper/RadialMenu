//
//  RadialSubMenu.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/6/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit
import QuartzCore
import pop

let RadialSubMenuOpenAnimation = "openAnimation"
let RadialSubMenuCloseAnimation = "closeAnimation"
let RadialSubMenuFadeInAnimation = "fadeInAnimation"
let RadialSubMenuFadeOutAnimation = "fadeOutAnimation"

// Using @objc here because we want to specify @optional methods which
// you can only do on classes, which you specify with the @objc modifier
@objc public protocol RadialSubMenuDelegate {
    @objc optional func subMenuDidOpen(_ subMenu: RadialSubMenu)
    @objc optional func subMenuDidHighlight(_ subMenu: RadialSubMenu)
    @objc optional func subMenuDidActivate(_ subMenu: RadialSubMenu)
    @objc optional func subMenuDidUnhighlight(_ subMenu: RadialSubMenu)
    @objc optional func subMenuDidClose(_ subMenu: RadialSubMenu)
}

open class RadialSubMenu: UIView, POPAnimationDelegate {
    
    enum State {
        case closed, opening, opened, highlighted, unhighlighted, activated, closing
    }

    open var delegate: RadialSubMenuDelegate?
    var origPosition         = CGPoint.zero
    var currPosition         = CGPoint.zero
    
    var openDelay            = 0.0
    var closeDelay           = 0.0
    
    var closeDuration        = 0.1
    var openSpringSpeed      = 12.0
    var openSpringBounciness = 6.0
    
    var state: State = .closed {
        didSet {
            if oldValue == state { return }
            switch state {
                case .unhighlighted:
                    delegate?.subMenuDidUnhighlight?(self)
                    state = .opened
                case .opened:
                    delegate?.subMenuDidOpen?(self)
                case .highlighted:
                    delegate?.subMenuDidHighlight?(self)
                case .activated:
                    delegate?.subMenuDidActivate?(self)
                case .closed:
                    delegate?.subMenuDidClose?(self)
                default:
                    break
            }
        }
    }
   
    // MARK - Init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        origPosition = self.center
        alpha = 0
        
    }
    
    convenience public init(imageView: UIImageView) {
        self.init(frame: imageView.frame)
        imageView.isUserInteractionEnabled = true
        addSubview(imageView)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK - Main interface
    
    func openAt(_ position: CGPoint, fromPosition: CGPoint, delay: Double) {
        
        state = .opening
        openDelay = delay
        currPosition = position
        origPosition = fromPosition
        
        center = origPosition
        
        openAnimation()
    }
    
    func openAt(_ position: CGPoint, fromPosition: CGPoint) {
        openAt(position, fromPosition: fromPosition, delay: 0)
    }
    
    func close(_ delay: Double) {
        
        state = .closing
        closeDelay = delay
        closeAnimation()
    }
    
    func close() {
        close(0)
    }
    
    func highlight() {
        state = .highlighted
    }
    
    func unhighlight() {
        state = .unhighlighted
    }
    
    func activate(_ delay: Double) {
        closeDelay = delay
        state = .activated
        closeAnimation()
    }
    
    func activate() {
        activate(0)
    }
    
    // MARK - Animations
    
    func openAnimation() {
        if pop_animation(forKey: RadialSubMenuOpenAnimation) as? POPAnimation == nil {
            let anim = POPSpringAnimation(propertyNamed:kPOPViewCenter)
            anim?.name = RadialSubMenuOpenAnimation
            anim?.toValue = NSValue(cgPoint: currPosition)
            anim?.beginTime = CACurrentMediaTime() + openDelay
            anim?.springBounciness = CGFloat(openSpringBounciness)
            anim?.springSpeed = CGFloat(openSpringSpeed)
            anim?.delegate = self
            pop_add(anim, forKey:RadialSubMenuOpenAnimation)
        }
        
    }
    
    func closeAnimation() {
        if pop_animation(forKey: RadialSubMenuCloseAnimation) as? POPAnimation == nil {
            let anim = POPBasicAnimation(propertyNamed:kPOPViewCenter)
            anim?.name = RadialSubMenuCloseAnimation
            anim?.toValue = NSValue(cgPoint: origPosition)
            anim?.duration = closeDuration
            anim?.beginTime = CACurrentMediaTime() + closeDelay
            anim?.delegate = self
            pop_add(anim, forKey:RadialSubMenuCloseAnimation)
        }
        
    }
    
    func fadeInAnimation() {
        
        let toValue = NSNumber(value: 1.0 as Float)
        
        if let existingAnim = pop_animation(forKey: RadialSubMenuFadeInAnimation) as? POPSpringAnimation {
            existingAnim.toValue = toValue
        } else {
            let anim = POPSpringAnimation(propertyNamed:kPOPViewAlpha)
            anim?.name = RadialSubMenuFadeInAnimation
            anim?.toValue = toValue
            anim?.springBounciness = CGFloat(openSpringBounciness)
            anim?.springSpeed = CGFloat(openSpringSpeed)
            anim?.delegate = self
            pop_add(anim, forKey:RadialSubMenuFadeInAnimation)
        }
    }
    
    func fadeOutAnimation() {
        
        let toValue = NSNumber(value: 0.0 as Float)
        
        if let existingAnim = pop_animation(forKey: RadialSubMenuFadeOutAnimation) as? POPBasicAnimation {
            existingAnim.toValue = toValue
        } else {
            let anim = POPBasicAnimation(propertyNamed:kPOPViewAlpha)
            anim?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            anim?.name = RadialSubMenuFadeOutAnimation
            anim?.toValue = toValue
            anim?.duration = closeDuration
            anim?.delegate = self
            pop_add(anim, forKey:RadialSubMenuFadeOutAnimation)
        }
    }
    
    func removeAllAnimations() {
        removeOpenAnimations()
        removeCloseAnimations()
    }
    
    func removeCloseAnimations() {
        pop_removeAnimation(forKey: RadialSubMenuCloseAnimation)
        pop_removeAnimation(forKey: RadialSubMenuFadeOutAnimation)
    }
    
    func removeOpenAnimations() {
        pop_removeAnimation(forKey: RadialSubMenuOpenAnimation)
        pop_removeAnimation(forKey: RadialSubMenuFadeInAnimation)
    }
    
    
    // MARK - POP animation delegates
    
    open func pop_animationDidStart(_ anim: POPAnimation!) {
        switch anim.name {
            case RadialSubMenuOpenAnimation:
                fadeInAnimation()
            case RadialSubMenuCloseAnimation:
                fadeOutAnimation()
            default:
                break
        }
        
    }
    
    open func pop_animationDidStop(_ anim: POPAnimation!, finished: Bool) {
        
        if !finished { return }
        
        switch (anim.name!, state) {
            case (RadialSubMenuOpenAnimation, _):
                state = .opened
            case (RadialSubMenuCloseAnimation, _):
                state = .closed
                removeOpenAnimations()
            case (RadialSubMenuOpenAnimation, .closing):
                closeAnimation()
            case (RadialSubMenuCloseAnimation, .opening):
                openAnimation()
            default:
                break
        }
    }
    

}
