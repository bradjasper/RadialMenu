//
//  RadialMenuTests.swift
//  RadialMenuTests
//
//  Created by Brad Jasper on 6/5/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit
import XCTest

class RadialMenuTests: XCTestCase {
    
    func testOpenAtPosition() {
        
        // Setup radial menu
        let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let radialMenu = RadialMenu(menus: [
            RadialSubMenu(frame: frame),
            RadialSubMenu(frame: frame),
            RadialSubMenu(frame: frame),
            RadialSubMenu(frame: frame),
        ])
        
        // Verify initial state
        XCTAssertEqual(radialMenu.subMenus.count, 4, "Unknown number of subMenus")
        XCTAssertEqual(radialMenu.state, RadialMenu.State.Closed)
        
        // Open. Verify state of menu & submenus is opening
        radialMenu.openAtPosition(CGPoint(x: 100, y: 100))
        XCTAssertEqual(radialMenu.state, RadialMenu.State.Opening)
        
        for subMenu in radialMenu.subMenus {
            XCTAssertEqual(subMenu.state, RadialSubMenu.State.Opening)
        }
        
    }
}
