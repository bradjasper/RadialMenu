//
//  CircleHelpers.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/7/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit

func degreesToRadians(degrees:Double) -> Double {
    return degrees * M_PI / 180
}

func radiansToDegrees(radians:Double) -> Double {
    return radians * 180 / M_PI
}

func isFullCircle(minAngle: Double, maxAngle: Double) -> Bool {
    return ((maxAngle - minAngle) % 360) == 0
}

func isFullCircle(minAngle: Int, maxAngle: Int) -> Bool {
    return isFullCircle(Double(minAngle), Double(maxAngle))
}

func getPointAlongCircle(idx: Int, max: Int, minAngle: Double, maxAngle: Double, radius: Double) -> CGPoint {
    let spreadAngle = maxAngle - minAngle
    let percentage = Double(idx) / Double(max)
    let angle = degreesToRadians(minAngle + (percentage * spreadAngle))
    let pointX = CGFloat(radius * cos(angle))
    let pointY = CGFloat(radius * sin(angle))
    return CGPoint(x: pointX, y: pointY)
}