//
//  SecondViewController.swift
//  RadialMenu
//
//  Created by Brad Jasper on 6/5/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

import UIKit
import QuartzCore

class SecondViewController: UIViewController {
    var didSetupConstraints = false
    
    let highlightColor = UIColor(rgba: "#007aff")
    let tapView:UIView
    let microphoneButton:UIView
    var radialMenu:RadialMenu
    let microphoneButtonImageView:UIImageView
    let stopButton:UIView
    
    let menuRadius:CGFloat = 125
    let subMenuRadius:CGFloat = 16
    let microphoneBumper:CGFloat = 24
    let microphoneRadius:CGFloat = 12
    
    init(coder aDecoder: NSCoder!) {
        
        // FIXME: How can I:
        // 1. Create a padding around a UIImageView (think I can do this with a larger frame contentMode = center)
        // 2. Use AutoLayout
        // 3. Without the extra UIView wrapper
        // It seems once you setTranslatesAutoresizingMaskIntoConstraints = false, the padding no longer works--which is required for auto layout
        microphoneButtonImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: microphoneRadius*2, height: microphoneRadius*2))
        
        microphoneButtonImageView.image = UIImage(named: "microphone").imageWithRenderingMode(.AlwaysTemplate)
        microphoneButtonImageView.tintColor = UIColor.whiteColor()
        microphoneButtonImageView.contentMode = .Center
        
        microphoneButton = UIView(frame: CGRect(x: 0, y: 0, width: microphoneRadius*2, height: microphoneRadius*2))
        microphoneButton.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        microphoneButton.layer.cornerRadius = microphoneRadius
        microphoneButton.addSubview(microphoneButtonImageView)
        
        // FIXME: Possibly move center image/button to RadialMenu
        stopButton = UIView(frame: CGRect(x: 0, y: 0, width: microphoneRadius*2.2, height: microphoneRadius*2.2))
        stopButton.layer.borderWidth = 2
        stopButton.layer.borderColor = UIColor.whiteColor().CGColor
        stopButton.layer.cornerRadius = microphoneRadius*1.1
        
        let innerStopButton = UIView(frame: CGRect(x: 0, y: 0, width: microphoneRadius, height: microphoneRadius))
        innerStopButton.backgroundColor = UIColor.redColor()
        innerStopButton.layer.cornerRadius = 2
        innerStopButton.center = innerStopButton.convertPoint(stopButton.center, fromView: stopButton)
        stopButton.addSubview(innerStopButton)
        stopButton.alpha = 0
        
        // Improve usability by making a larger tapview
        tapView = UIView()
        
        radialMenu = RadialMenu()
        
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "pressedButton:")
        
        radialMenu = RadialMenu(menus: [createSubMenu("cancel"), createSubMenu("save")], radius: menuRadius)
        radialMenu.minAngle = 180
        radialMenu.maxAngle = 270
        radialMenu.alpha = 0.75
        
        radialMenu.onOpening = {
            // FIXME: Add transitions
            self.microphoneButtonImageView.alpha = 0.0
            self.stopButton.alpha = 1.0
        }
        
        radialMenu.onClosing = {
            // FIXME: Add transitions
            self.microphoneButtonImageView.alpha = 1.0
            self.stopButton.alpha = 0.0
        }
        
        radialMenu.onHighlight = { subMenu in
            subMenu.backgroundColor = self.highlightColor
        }
        
        radialMenu.onUnhighlight = { subMenu in
            subMenu.backgroundColor = UIColor.whiteColor()
        }
        
        radialMenu.onClose = {
            for subMenu in self.radialMenu.subMenus {
                subMenu.backgroundColor = UIColor.whiteColor()
            }
        }
        
        microphoneButtonImageView.center = microphoneButtonImageView.convertPoint(microphoneButton.center, fromView: view)
        
        view.addSubview(radialMenu)
        view.addSubview(microphoneButton)
        view.addSubview(tapView)
        view.addSubview(stopButton)
        
        tapView.addGestureRecognizer(longPress)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // FIXME: See radialMenu auto layout bug above
        radialMenu.center = microphoneButton.center
    }
        func createSubMenu(icon: String) -> RadialSubMenu {
        let img = UIImageView(image: UIImage(named: icon))
        let subMenu = RadialSubMenu(imageView: img)
        subMenu.frame = CGRect(x: 0.0, y: 0.0, width: CGFloat(subMenuRadius*2), height: CGFloat(subMenuRadius*2))
        subMenu.layer.cornerRadius = CGFloat(subMenuRadius)
        subMenu.backgroundColor = UIColor.whiteColor()
        img.center = subMenu.center
        
        return subMenu
    }
    
    func pressedButton(gesture:UIGestureRecognizer) {
        switch(gesture.state) {
            case .Began:
                radialMenu.openAtPosition(self.microphoneButton.center)
            case .Changed:
                radialMenu.moveAtPosition(gesture.locationInView(self.view))
            case .Ended:
                radialMenu.close()
            default:
                break
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if (!didSetupConstraints) {
            
            // FIXME: Any way to simplify this?
            
            microphoneButton.autoSetDimensionsToSize(CGSize(width: microphoneRadius*2, height: microphoneRadius*2))
            microphoneButton.autoPinToBottomLayoutGuideOfViewController(self, withInset: microphoneBumper)
            microphoneButton.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: microphoneBumper)
            
            stopButton.autoPinToBottomLayoutGuideOfViewController(self, withInset: microphoneBumper)
            stopButton.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: microphoneBumper)
            stopButton.autoSetDimensionsToSize(CGSize(width: microphoneRadius*2.2, height: microphoneRadius*2.2))
            
            radialMenu.autoAlignAxis(.Horizontal, toSameAxisOfView: microphoneButton)
            radialMenu.autoAlignAxis(.Vertical, toSameAxisOfView: microphoneButton)
            radialMenu.autoSetDimensionsToSize(CGSize(width: menuRadius*2, height: menuRadius*2))
            
            tapView.autoSetDimensionsToSize(CGSize(width: 75, height: 75))
            tapView.autoAlignAxis(.Horizontal, toSameAxisOfView: microphoneButton)
            tapView.autoAlignAxis(.Vertical, toSameAxisOfView: microphoneButton)
            
            didSetupConstraints = true
        }
    }
}

