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
    
    func testEventStateTransitions() {
        
        // Setup radial menu
        let radialMenu = RadialMenu(text: ["1", "2", "3", "4"])
        
        radialMenu.openDelayStep = 0.0
        radialMenu.closeDelayStep = 0.0
        
        // Setup expectations
        let openExpectation = self.expectationWithDescription("opens")
        let closeExpectation = self.expectationWithDescription("closes")
    
        // Setup event handlers for open/close
        radialMenu.onOpen = {
            XCTAssertEqual(radialMenu.state, .Opened)
            for subMenu in radialMenu.subMenus { XCTAssertEqual(subMenu.state, .Opened) }
            openExpectation.fulfill()
            
            radialMenu.close()
            XCTAssertEqual(radialMenu.state, .Closing)
        }
        
        radialMenu.onClose = {
            XCTAssertEqual(radialMenu.state, .Closed)
            for subMenu in radialMenu.subMenus { XCTAssertEqual(subMenu.state, .Closed) }
            closeExpectation.fulfill()
        }
        
        
        
        // Verify initial state
        XCTAssertEqual(radialMenu.subMenus.count, 4, "Unknown number of subMenus")
        XCTAssertEqual(radialMenu.state, .Closed)
        
        // Open & verify opening state
        radialMenu.openAtPosition(CGPointZero)
        XCTAssertEqual(radialMenu.state, .Opening)
        for subMenu in radialMenu.subMenus { XCTAssertEqual(subMenu.state, .Opening) }
        
        // Wait for expectations & verify final state
        self.waitForExpectationsWithTimeout(4, handler: { _ in
            XCTAssertEqual(radialMenu.state, .Closed)
            for subMenu in radialMenu.subMenus { XCTAssertEqual(subMenu.state, .Closed) }
        })
    }
    
    func testStateChangeEventsFireOnce() {
        
        let radialMenu = RadialMenu(text: ["1", "2", "3", "4"])
        
        var opened = 0, closed = 0
        radialMenu.onOpen  = { opened += 1}
        radialMenu.onClose = { closed += 1}
        
        XCTAssertEqual(radialMenu.state, .Closed)
        
        radialMenu.state = .Closed
        
        XCTAssertEqual(closed, 0)
        XCTAssertEqual(opened, 0)
        
        radialMenu.state = .Opened
        
        XCTAssertEqual(closed, 0)
        XCTAssertEqual(opened, 1)
        
        radialMenu.state = .Closed
        
        XCTAssertEqual(closed, 1)
        XCTAssertEqual(opened, 1)
        
        // Calling the same state many times shouldn't trigger a state change
        radialMenu.state = .Closed
        radialMenu.state = .Closed
        radialMenu.state = .Closed
        
        XCTAssertEqual(closed, 1)
        XCTAssertEqual(opened, 1)
    }

}
