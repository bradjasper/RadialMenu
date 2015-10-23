// https://raw.githubusercontent.com/yeahdongcn/UIColor-Hex-Swift/master/UIColorExtension.swift
//
//  UIColorExtension.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/13/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(rgba: String) {
        var red: Double   = 0.0
        var green: Double = 0.0
        var blue: Double  = 0.0
        var alpha: Double = 1.0
        
        if rgba.hasPrefix("#") {
            let hex = rgba.substringFromIndex(rgba.startIndex.advancedBy(1))
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                let numElements = hex.characters.count
                if numElements == 6 {
                    red   = Double((hexValue & 0xFF0000) >> 16) / 255.0
                    green = Double((hexValue & 0x00FF00) >> 8)  / 255.0
                    blue  = Double(hexValue & 0x0000FF) / 255.0
                } else if numElements == 8 {
                    red   = Double((hexValue & 0xFF000000) >> 24) / 255.0
                    green = Double((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = Double((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = Double(hexValue & 0x000000FF)         / 255.0
                } else {
                    print("invalid rgb string, length should be 7 or 9", terminator: "")
                }
            } else {
                print("scan hex error")
            }
        } else {
            print("invalid rgb string, missing '#' as prefix", terminator: "")
        }
        
        
        self.init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
}
