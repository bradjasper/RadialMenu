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
    
    let tapView:UIView
    let microphoneButton:UIView
    let radialMenu:RadialMenu
    let bgView:UIView
    let microphoneButtonImageView:UIImageView
    
    let microphoneBumper:CGFloat = 24
    let microphoneRadius:CGFloat = 12
    let innerRadius:CGFloat = 130
    let subMenuRadius:CGFloat = 25
    let menuRadius:CGFloat = 90
    
    init(coder aDecoder: NSCoder!) {
        let img = UIImage(named: "microphone")
        
        // FIXME: How can I:
        // 1. Create a padding around a UIImageView (think I can do this with a larger frame contentMode = center)
        // 2. Use AutoLayout
        // 3. Without the extra UIView wrapper
        // It seems once you setTranslatesAutoresizingMaskIntoConstraints = false, the padding no longer works--which is required for auto layout
        microphoneButtonImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: microphoneRadius*2, height: microphoneRadius*2))
        
        microphoneButtonImageView.image = img.imageWithRenderingMode(.AlwaysTemplate)
        microphoneButtonImageView.tintColor = UIColor.whiteColor()
        microphoneButtonImageView.contentMode = .Center
        
        microphoneButton = UIView(frame: CGRect(x: 0, y: 0, width: microphoneRadius*2, height: microphoneRadius*2))
        microphoneButton.backgroundColor = UIColor(rgba: "#007aff")
        microphoneButton.layer.cornerRadius = microphoneRadius
        
        
        radialMenu = RadialMenu(text: ["1", "2"])
        radialMenu.frame = CGRectZero
        radialMenu.minAngle = 180
        radialMenu.maxAngle = 270
        radialMenu.layer.cornerRadius = innerRadius
        
        bgView = UIView()
        bgView.backgroundColor = UIColor(rgba: "#bdc3c7")
        bgView.layer.zPosition = -1
        bgView.layer.cornerRadius = innerRadius
        radialMenu.addSubview(bgView)
        
        
        // Improve usability by making a larger tapview
        tapView = UIView()
        
        super.init(coder: aDecoder)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if (!didSetupConstraints) {
            microphoneButton.autoSetDimensionsToSize(CGSize(width: microphoneRadius*2, height: microphoneRadius*2))
            microphoneButton.autoPinToBottomLayoutGuideOfViewController(self, withInset: microphoneBumper)
            microphoneButton.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: microphoneBumper)
            
            radialMenu.autoAlignAxis(.Horizontal, toSameAxisOfView: microphoneButton)
            radialMenu.autoAlignAxis(.Vertical, toSameAxisOfView: microphoneButton)
            
            bgView.autoAlignAxis(.Horizontal, toSameAxisOfView: radialMenu)
            bgView.autoAlignAxis(.Vertical, toSameAxisOfView: radialMenu)
            
            tapView.autoSetDimensionsToSize(CGSize(width: 75, height: 75))
            tapView.autoAlignAxis(.Horizontal, toSameAxisOfView: microphoneButton)
            tapView.autoAlignAxis(.Vertical, toSameAxisOfView: microphoneButton)
            
            didSetupConstraints = true
        }
    }
    
    func radialMenuShowAnimation(delay: CGFloat) -> POPSpringAnimation {
        if let anim = bgView.pop_animationForKey("show") as? POPSpringAnimation {
            return anim
        } else {
            let anim = POPSpringAnimation(propertyNamed:kPOPViewBounds)
            anim.springBounciness = 6.0
            anim.name = "show"
            anim.springSpeed = 20.0
            anim.beginTime = CACurrentMediaTime() + CFTimeInterval(delay)
            anim.delegate = self
            bgView.pop_addAnimation(anim, forKey:"show")
            return anim
        }
    }
    
    func radialMenuCornerRadiusAnimation(delay: CGFloat) -> POPSpringAnimation {
        if let anim = bgView.layer.pop_animationForKey("cornerRadius") as? POPSpringAnimation {
            return anim
        } else {
            let anim = POPSpringAnimation(propertyNamed:kPOPLayerCornerRadius)
            anim.springBounciness = 6.0
            anim.name = "cornerRadius"
            anim.springSpeed = 20.0
            anim.beginTime = CACurrentMediaTime() + CFTimeInterval(delay)
            anim.delegate = self
            bgView.layer.pop_addAnimation(anim, forKey:"cornerRadius")
            return anim
        }
    }
    
    func superExpandRadialMenu() {
        let radialAnim = radialMenuShowAnimation(0)
        radialAnim.toValue = NSValue(CGRect: CGRect(x: 0, y: 0, width: innerRadius*2.25, height: innerRadius*2.25))
        
        let cornerAnim = radialMenuCornerRadiusAnimation(0)
        cornerAnim.toValue = NSNumber(double: innerRadius*1.125)
        
        bgView.alpha = 1.0
    }
    
    func expandRadialMenu() {
        let radialAnim = radialMenuShowAnimation(0)
        radialAnim.toValue = NSValue(CGRect: CGRect(x: 0, y: 0, width: innerRadius*2, height: innerRadius*2))
        let cornerAnim = radialMenuCornerRadiusAnimation(0)
        cornerAnim.toValue = NSNumber(double: innerRadius)
        bgView.alpha = 1.0
    }
    
    
    func shrinkRadialMenu() {
        let radialAnim = radialMenuShowAnimation(0)
        radialAnim.toValue = NSValue(CGRect: CGRectZero)
        let cornerAnim = radialMenuCornerRadiusAnimation(0)
        cornerAnim.toValue = NSNumber(double: 0)
        bgView.alpha = 0.25
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        radialMenu.onOpening = {
            self.expandRadialMenu()
        }
        
        radialMenu.onClosing = {
            self.shrinkRadialMenu()
        }
        
        radialMenu.onHighlight = { subMenu in
            println("Highlighted submenu")
            self.superExpandRadialMenu()
        }
        
        radialMenu.onUnhighlight = { subMenu in
            println("Unhighlighted submenu")
            self.expandRadialMenu()
        }
        
        
        microphoneButton.addSubview(microphoneButtonImageView)
        microphoneButtonImageView.center = microphoneButtonImageView.convertPoint(microphoneButton.center, fromView: view)
        
        view.addSubview(radialMenu)
        view.addSubview(microphoneButton)
        
        view.addSubview(tapView)
        
        
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "pressedButton:")
        tapView.addGestureRecognizer(longPress)
    }
    
    func pressedButton(gesture:UIGestureRecognizer) {
        switch(gesture.state) {
            case .Began:
                println("OPEN")
                radialMenu.openAtPosition(self.microphoneButton.center)
            case .Ended:
                println("CLOSE")
                radialMenu.close()
            case .Changed:
                println("MOVE")
                radialMenu.moveAtPosition(gesture.locationInView(self.view))
            default:
                break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

