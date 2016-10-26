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

public class FABasicAnimation : CAKeyframeAnimation {
    
    public weak var animatingLayer : CALayer?
    
    public var toValue: AnyObject?
    public var fromValue: AnyObject?
    
    public var easingFunction : FAEasing = .Linear
    public var isPrimary : Bool = false
    
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
        removedOnCompletion = true
        values = [AnyObject]()
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        let animation = super.copyWithZone(zone) as! FABasicAnimation
        
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
        if let presentationLayer = animatingLayer?.presentationLayer(),

            let presentationValue = presentationLayer.anyValueForKeyPath(keyPath!) {
            
            if let currentValue = presentationValue as? CGPoint {
                fromValue = NSValue(CGPoint : currentValue)
            } else  if let currentValue = presentationValue as? CGSize {
                fromValue = NSValue(CGSize : currentValue)
            } else  if let currentValue = presentationValue as? CGRect {
                fromValue = NSValue(CGRect : currentValue)
            } else  if let currentValue = presentationValue as? CGFloat {
                fromValue = NSNumber(float : Float(currentValue))
            } else  if let currentValue = presentationValue as? CATransform3D {
                fromValue = NSValue(CATransform3D : currentValue)
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
        
        switch timingFunction?.valueForKey("name") as! String {
        case kCAMediaTimingFunctionEaseIn:
            easingFunction = .InCubic
        case kCAMediaTimingFunctionEaseOut:
            easingFunction = .OutCubic
        case kCAMediaTimingFunctionEaseInEaseOut:
            easingFunction = .InOutCubic
        default:
            easingFunction = .SmoothStep
        }
    }
}


//MARK: - Animation Progress Values

internal extension FABasicAnimation {
    
    func valueProgress() -> CGFloat {
        if let presentationValue = animatingLayer?.presentationLayer()?.anyValueForKeyPath(keyPath!),
            let interpolator = interpolator {
            return interpolator.valueProgress(presentationValue)
        }
        
        return 0.0
    }
    
    func timeProgress() -> CGFloat {
        if let presentationLayer = animatingLayer?.presentationLayer() {
            let currentTime = presentationLayer.convertTime(CACurrentMediaTime(), toLayer: nil)
            let difference = currentTime - startTime!
            
            return CGFloat(round(100 * (difference / duration))/100)
        }
        
        return 0.0
    }
}
