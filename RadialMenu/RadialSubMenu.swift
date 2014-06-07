//
//  RadialSubMenu.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/6/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit

class RadialSubMenu: UIView {
    
    enum State: Int {
        case Closed = 1, Opening, Opened, Highlighting, Highlighted, Selected, Unhighlighting, Closing
    }
    
    var state: State = State.Closed {
        willSet(newValue) {
            switch newValue {
                case .Closed:
                    println("Submenu state is closed")
                case .Opening:
                    println("Submenu state is opening")
                case .Opened:
                    println("Submenu state is opened")
                case .Highlighting:
                    println("Submenu state is highlighting")
                case .Highlighted:
                    println("Submenu state is highlighted")
                case .Selected:
                    println("Submenu state is selected")
                case .Unhighlighting:
                    println("Submenu state is Unhighlighting")
                case .Closing:
                    println("Submenu state is closing")
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
