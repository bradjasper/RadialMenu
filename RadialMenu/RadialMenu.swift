//
//  RadialMenu.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/5/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit

@IBDesignable
class RadialMenu: UIView {
    
    @IBInspectable var radius: Int = 50

    init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    init(coder decoder: NSCoder!) {
        super.init(coder: decoder)
        self.backgroundColor = UIColor.redColor()
        self.setup()
    }
    
    func setup() {
        println("Setting RadialMenu up...")
        
        self.backgroundColor = UIColor.redColor()
    }
    
    // Doesn't work for some reason...
    override func prepareForInterfaceBuilder()
    {
        self.backgroundColor = UIColor.redColor()
        self.alpha = 0.5
    }
    
    
}
