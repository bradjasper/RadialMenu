//
//  CircleHelpersTests.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/7/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import XCTest

class CircleHelpersTests: XCTestCase {

    func testDeegreesToRadians() {
        XCTAssertEqual(degreesToRadians(0), 0)
        XCTAssertEqual(degreesToRadians(180), M_PI)
        XCTAssertEqual(degreesToRadians(360), M_PI*2)
    }
    
    func testRadiansToDegreese() {
        XCTAssertEqual(radiansToDegrees(0), 0)
        XCTAssertEqual(radiansToDegrees(M_PI), 180)
        XCTAssertEqual(radiansToDegrees(M_PI*2), 360)
    }
    
    func testIsFullCircle() {
        XCTAssertTrue(isFullCircle(180, 540))
        XCTAssertTrue(isFullCircle(0, 360))
        XCTAssertTrue(isFullCircle(180.0, 540.0))
        XCTAssertTrue(isFullCircle(0.1, 360.1))
        XCTAssertTrue(isFullCircle(180, 900))
    }
    
    func testGetPointAlongCircle() {
        let max = 10, minAngle = 0.0, maxAngle = 360.0, radius = 100.0
        
        let firstPoint = getPointAlongCircle(0, max, minAngle, maxAngle, radius)
        XCTAssertEqual(firstPoint.x, 100.0)
        XCTAssertEqual(firstPoint.y, 0)
        
        // better way to check this?
        let secondPoint = getPointAlongCircle(1, max, minAngle, maxAngle, radius)
        XCTAssertTrue(secondPoint.x > 80 && secondPoint.x < 81, "X pos is wrong \(secondPoint.x)")
        XCTAssertTrue(secondPoint.y > 58 && secondPoint.y < 59, "Y pos is wrong \(secondPoint.y)")
    }
}
