//
//  RadialMenu.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/5/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit

class RadialMenu: UIView {

    init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    init(coder decoder: NSCoder!) {
        super.init(coder: decoder)
        self.setup()
    }
    
    func setup() {
        println("Setting RadialMenu up...")
        self.backgroundColor = UIColor.redColor()
    }
    
    
}
