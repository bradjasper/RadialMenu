//
//  RadialSubMenu.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/6/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit

class RadialSubMenu: UIView {

    init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.redColor()
        
    }
    
    func openAt(position: CGPoint, delay: Double) {
        println("Opening at position=%d with delay=%d", position, delay)
    }
}
