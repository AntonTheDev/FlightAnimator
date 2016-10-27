//
//  FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

//MARK: - FABasicAnimation

open class FABasicAnimation : CAKeyframeAnimation {
    
    open weak var animatingLayer : CALayer?
    
    open var toValue: AnyObject?
    open var fromValue: AnyObject?
    
    open var easingFunction : FAEasing = .linear
    open var isPrimary : Bool = false
    
    internal var interpolator :  FAInterpolator?
    internal var startTime : CFTimeInterval?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInitialValues()
    }
    
    override public init() {
        super.init()
        initializeInitialValues()
    }
    
    public convenience init(keyPath path: String?) {
        self.init()
        keyPath = path
        initializeInitialValues()
    }
    
    internal func initializeInitialValues() {
        CALayer.swizzleAddAnimation()
        
        calculationMode = kCAAnimationLinear
        fillMode = kCAFillModeForwards
        isRemovedOnCompletion = true
        values = [AnyObject]()
    }
    
    override open func copy(with zone: NSZone?) -> Any {
        let animation = super.copy(with: zone) as! FABasicAnimation
        
        animation.animatingLayer            = animatingLayer
        
        animation.toValue                   = toValue
        animation.fromValue                 = fromValue
        animation.easingFunction            = easingFunction
        animation.isPrimary                 = isPrimary
        
        animation.interpolator              = interpolator
        return animation
    }
}

//MARK: - Synchronization Logic

internal extension FABasicAnimation {
    
    internal func synchronize(relativeTo animation : FABasicAnimation? = nil) {
        
        synchronizeFromValue()
        
        guard let toValue = toValue, let fromValue = fromValue else {
            return
        }
        
        interpolator = FAInterpolator(toValue, fromValue, relativeTo : animation?.fromValue)
        
        let config = interpolator?.interpolatedConfigurationFor(self, relativeTo: animation)
        easingFunction = config!.easing
        duration = config!.duration
        values = config!.values
    }
    

    internal func synchronizeFromValue() {
        if let presentationLayer = animatingLayer?.presentation(),

            let presentationValue = presentationLayer.anyValueForKeyPath(keyPath!) {
            
            if let currentValue = presentationValue as? CGPoint {
                fromValue = NSValue(cgPoint : currentValue)
            } else  if let currentValue = presentationValue as? CGSize {
                fromValue = NSValue(cgSize : currentValue)
            } else  if let currentValue = presentationValue as? CGRect {
                fromValue = NSValue(cgRect : currentValue)
            } else  if let currentValue = presentationValue as? CGFloat {
                fromValue = NSNumber(value: Float(currentValue) as Float)
            } else  if let currentValue = presentationValue as? CATransform3D {
                fromValue = NSValue(caTransform3D : currentValue)
            } else if let currentValue = typeCastCGColor(presentationValue) {
                fromValue = currentValue
            }
        }
    }
    
    func adjustSpringVelocityIfNeeded(relativeTo animation : FABasicAnimation?) {
        
        guard easingFunction.isSpring() == true else {
            return
        }
        
        if easingFunction.isSpring() {
            if let adjustedEasing = interpolator?.adjustedVelocitySpring(easingFunction, relativeTo : animation) {
                easingFunction = adjustedEasing
            }
        }
    }
    
    internal func convertTimingFunction() {
        
        print("timingFunction has no effect, converting to 'easingFunction' property\n")
        
        switch timingFunction?.value(forKey: "name") as! String {
        case kCAMediaTimingFunctionEaseIn:
            easingFunction = .inCubic
        case kCAMediaTimingFunctionEaseOut:
            easingFunction = .outCubic
        case kCAMediaTimingFunctionEaseInEaseOut:
            easingFunction = .inOutCubic
        default:
            easingFunction = .smoothStep
        }
    }
}


//MARK: - Animation Progress Values

internal extension FABasicAnimation {
    
    func valueProgress() -> CGFloat {
        if let presentationValue = animatingLayer?.presentation()?.anyValueForKeyPath(keyPath!),
            let interpolator = interpolator {
            return interpolator.valueProgress(presentationValue)
        }
        
        return 0.0
    }
    
    func timeProgress() -> CGFloat {
        if let presentationLayer = animatingLayer?.presentation() {
            let currentTime = presentationLayer.convertTime(CACurrentMediaTime(), to: nil)
            let difference = currentTime - startTime!
            
            return CGFloat(round(100 * (difference / duration))/100)
        }
        
        return 0.0
    }
}
