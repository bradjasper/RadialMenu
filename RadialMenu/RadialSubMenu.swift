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

class RadialSubMenu: UIView {
    
    enum State {
        case Closed, Opening, Opened, Highlighting, Highlighted, Selected, Unhighlighting, Closing
    }

    var delegate: RadialSubMenuDelegate?
    var state: State = .Closed {
        didSet {
            if oldValue == state { return }
            switch state {
                case .Opened:
                    println("OPENED")
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
    
    init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(text: String) {
        super.init(frame: frame)
    }
    
    func openAt(position: CGPoint, delay: Double) {
        println("Opening at position=\(position) with delay=\(delay)")
        
        state = .Opening
        
        dispatch_after(1, dispatch_get_main_queue(), {
            self.state = .Opened
        })
    }
    
    func close() {
        
        state = .Closing
        
        dispatch_after(1, dispatch_get_main_queue(), {
            self.state = .Closed
        })
    }
}
