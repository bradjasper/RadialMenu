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
    
    // TODO: Break this up into smaller tests
    func testOpenAtPosition() {
        
        // test expectations (async)
        let openExpectation = self.expectationWithDescription("opens")
        let closeExpectation = self.expectationWithDescription("closes")
    
        // Setup radial menu
        let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let radialMenu = RadialMenu(text: ["1", "2", "3", "4"])
        
        radialMenu.onOpen = {
            println("radialMenu opened")
            openExpectation.fulfill()
        }
        
        radialMenu.onClose = {
            println("BLAH radialMenu closed")
            closeExpectation.fulfill()
        }
        
        // Verify initial state
        XCTAssertEqual(radialMenu.subMenus.count, 4, "Unknown number of subMenus")
        XCTAssertEqual(radialMenu.state, .Closed)
        
        // Open. Verify state of menu & submenus is opening
        radialMenu.openAtPosition(CGPoint(x: 100, y: 100))
        XCTAssertEqual(radialMenu.state, .Opening)
        
        for subMenu in radialMenu.subMenus {
            XCTAssertEqual(subMenu.state, .Opening)
        }
        
        // FIXME: This is a temp fix until real animation is working
        for subMenu in radialMenu.subMenus {
            subMenu.state = .Opened
        }
        
        // OPENED
        
        // FIXME: This is a temp fix until real animation is working
        for subMenu in radialMenu.subMenus {
            subMenu.state = .Closed
        }
        
        // Set it again
        radialMenu.state = .Closed
        radialMenu.state = .Closed
        radialMenu.state = .Closed
        radialMenu.state = .Closed
        
        self.waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testEventsOnlyFireOnce() {
        let radialMenu = RadialMenu(text: ["1", "2"])
        var numTimesClosed = 0
        
        radialMenu.onClose = {
            println("CLOSED")
            numTimesClosed++
        }
        
        radialMenu.state = .Opened
        radialMenu.state = .Closed
        radialMenu.state = .Closed
        radialMenu.state = .Closed
        
        XCTAssertEqual(numTimesClosed, 1)
    }

}
