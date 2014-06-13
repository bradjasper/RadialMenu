//
//  RadialSubMenu.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/6/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit

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
    
    var origPosition = CGPointZero
    var currPosition = CGPointZero
    var origBounds = CGRectZero
    var origFrame = CGRectZero
    var openDelay = 0.0
    var closeDelay = 0.0
    
    enum State {
        case Closed, Opening, Opened, Highlighting, Highlighted, Selected, Unhighlighting, Closing
    }

    var delegate: RadialSubMenuDelegate?
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
    
    var openAnimation:POPAnimation?
    
    init(frame: CGRect) {
        super.init(frame: frame)
        origFrame = self.frame
        origBounds = self.bounds
        origPosition = self.center
    }
    
    convenience init(text: String) {
        self.init(frame: CGRectZero)
    }
    
    func openAt(position: CGPoint, fromPosition: CGPoint, delay: Double) {
        println("Opening at position=\(position) with delay=\(delay)")
        
        state = .Opening
        openDelay = delay
        currPosition = position
        origPosition = fromPosition
        
        // reset center to origPosition
        self.center = origPosition
        
        
        if let existingAnim = self.pop_animationForKey("open") as? POPAnimation {
            println("Existing animation!")
        } else {
            println("Creating animation")
            let anim = POPSpringAnimation(propertyNamed:kPOPViewCenter)
            anim.name = "open"
            anim.toValue = NSValue(CGPoint: currPosition)
            anim.delegate = self
            self.pop_addAnimation(anim, forKey: "open")
        }
        
    }
    
    func pop_animationDidStart(anim: POPAnimation!) {
        if anim.name == "open" {
            println("Starting open ANIM")
        }
        
    }
    
    func pop_animationDidStop(anim: POPAnimation!, finished: Bool) {
        
        if anim.name == "open" {
            switch state {
                case .Opening:
                    state = .Opened
                case .Closing:
                    println("NEED TO CLOSE")
                default:
                    break
            }
            println("Ending open ANIM")
        } else if anim.name == "close" {
            switch state {
                case .Opening:
                    println("NEEDS TO OPEN")
                case .Closing:
                    state = .Closed
                default:
                    break
            }
            
        }
        
    }
    
    func openAt(position: CGPoint, fromPosition: CGPoint) {
        self.openAt(position, fromPosition: fromPosition, delay: 0)
    }
    
    func close() {
        self.close(0)
    }
    
    func close(delay: Double) {
        
        state = .Closing
        closeDelay = delay
        
        if let existingAnim = self.pop_animationForKey("close") as? POPAnimation {
            println("Existing animation!")
        } else {
            println("Creating animation")
            let anim = POPBasicAnimation(propertyNamed:kPOPViewCenter)
            anim.name = "close"
            anim.toValue = NSValue(CGPoint: origPosition)
            anim.delegate = self
            self.pop_addAnimation(anim, forKey: "close")
        }
        
    }
}
