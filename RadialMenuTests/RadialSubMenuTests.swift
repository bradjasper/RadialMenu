//
//  RadialSubMenuTests.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/9/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit
import XCTest

class RadialSubMenuTests: XCTestCase, RadialSubMenuDelegate {

    var opened = 0, closed = 0
    
    // delegate helpers....maybe better to use closures for more localized testing?
    func subMenuDidOpen(subMenu: RadialSubMenu)  { opened += 1 }
    func subMenuDidClose(subMenu: RadialSubMenu) { closed += 1 }
    
    func testStateChangeEventsFireOnce() {
        
        let radialSubMenu = RadialSubMenu(frame: CGRectZero)
        radialSubMenu.delegate = self
        
        XCTAssertEqual(radialSubMenu.state, .Closed)
        
        radialSubMenu.state = .Closed
        
        XCTAssertEqual(closed, 0)
        XCTAssertEqual(opened, 0)
        
        radialSubMenu.state = .Opened
        
        XCTAssertEqual(closed, 0)
        XCTAssertEqual(opened, 1)
        
        radialSubMenu.state = .Closed
        
        XCTAssertEqual(closed, 1)
        XCTAssertEqual(opened, 1)
        
        // Calling the same state many times shouldn't trigger a state change
        radialSubMenu.state = .Closed
        radialSubMenu.state = .Closed
        radialSubMenu.state = .Closed
        
        XCTAssertEqual(closed, 1)
        XCTAssertEqual(opened, 1)
    }
}
