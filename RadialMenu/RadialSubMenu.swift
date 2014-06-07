//
//  RadialSubMenu.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/6/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit

protocol RadialSubMenuDelegate {
    func subMenuDidOpen(subMenu: RadialSubMenu)
    func subMenuDidHighlight(subMenu: RadialSubMenu)
    func subMenuDidSelect(subMenu: RadialSubMenu)
    func subMenuDidUnhighlight(subMenu: RadialSubMenu)
    func subMenuDidClose(subMenu: RadialSubMenu)
}

class RadialSubMenu: UIView {
    
    enum State: Int {
        case Closed = 1, Opening, Opened, Highlighting, Highlighted, Selected, Unhighlighting, Closing
    }
    
    var delegate: RadialSubMenuDelegate?
    var state: State = State.Closed {
        didSet {
            if oldValue == state { return }
            switch state {
                case .Opened:
                    delegate?.subMenuDidOpen(self)
                case .Highlighted:
                    delegate?.subMenuDidHighlight(self)
                case .Selected:
                    delegate?.subMenuDidSelect(self)
                case .Unhighlighting:
                    delegate?.subMenuDidUnhighlight(self)
                case .Closed:
                    delegate?.subMenuDidClose(self)
                default:
                    break
            }
        }
    }
    
    init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.redColor()
        
    }
    
    func openAt(position: CGPoint, delay: Double) {
        println("Opening at position=\(position) with delay=\(delay)")
        self.state = State.Opening
    }
}
