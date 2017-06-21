//
//  CircleHelpers.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/7/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit

func degreesToRadians(_ degrees:Double) -> Double {
    return degrees * M_PI / 180
}

func radiansToDegrees(_ radians:Double) -> Double {
    return radians * 180 / M_PI
}

func isFullCircle(_ minAngle: Double, maxAngle: Double) -> Bool {
    return ((maxAngle - minAngle).truncatingRemainder(dividingBy: 360)) == 0
}

func isFullCircle(_ minAngle: Int, maxAngle: Int) -> Bool {
    return isFullCircle(Double(minAngle), maxAngle: Double(maxAngle))
}

func getAngleForIndex(_ idx: Int, max: Int, minAngle: Double, maxAngle: Double) -> Double {
    let spreadAngle = maxAngle - minAngle
    let percentage = Double(idx) / Double(max)
    let angle = degreesToRadians(minAngle + (percentage * spreadAngle))
    return angle
}

func getPointForAngle(_ angle: Double, radius: Double) -> CGPoint {
    let pointX = CGFloat(radius * cos(angle))
    let pointY = CGFloat(radius * sin(angle))
    return CGPoint(x: pointX, y: pointY)
}

func getPointAlongCircle(_ idx: Int, max: Int, minAngle: Double, maxAngle: Double, radius: Double) -> CGPoint {
    let angle = getAngleForIndex(idx, max: max, minAngle: minAngle, maxAngle: maxAngle)
    return getPointForAngle(angle, radius: radius)
}

func distanceBetweenPoints(_ p1: CGPoint, p2: CGPoint) -> Double {
    return sqrt(pow(Double(p2.x-p1.x), 2) + pow(Double(p2.y-p1.y), 2))
}
