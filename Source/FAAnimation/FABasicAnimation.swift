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
    
        /**
         *  When we add a new animation it appears that if there was a prior animation,
         *  the current layer's presentation value is still the last animation's
         *  final value. Thus, if we change the model layer's value, prior to kicking off
         *  the new animation, we need to check if the current toValue is equal to
         *  the presentation layer;s value, if not we need to use the model layer's
         *  current value instead of the presentation layer. 
         *
         *  Technically if the fromValue (presentation layer's current value) is equal
         *  to the from value, and the current layer's value do not match, it means that 
         *  we need not intercept the animation in flight, and there is no need to synchronized.
         *
         */
        
        if  let animationToValue = toValue,
            let animationLayer = animatingLayer,
            let animationLayerValue = animationLayer.anyValueForKeyPath(keyPath!),
            let presentationLayer = animatingLayer?.presentation(),
            let presentationValue = presentationLayer.anyValueForKeyPath(keyPath!) {
            
            if let relativeToValue = presentationValue as? CGPoint {
                
                if animationToValue.cgPointValue.equalTo(relativeToValue) {
                    fromValue = NSValue(cgPoint : animationLayerValue as! CGPoint)
                } else {
                    fromValue = NSValue(cgPoint : relativeToValue)
                }

            } else if let relativeToValue = presentationValue as? CGSize {
                
                if animationToValue.cgSizeValue.equalTo(relativeToValue) {
                    fromValue = NSValue(cgSize : animationLayerValue as! CGSize)
                } else {
                    fromValue = NSValue(cgSize : relativeToValue)
                }

            } else if let relativeToValue = presentationValue as? CGRect {
                
                if animationToValue.cgRectValue.equalTo(relativeToValue) {
                    fromValue = NSValue(cgRect : animationLayerValue as! CGRect)
                } else {
                    fromValue = NSValue(cgRect : relativeToValue)
                }
                
            } else if let relativeToValue = presentationValue as? CGFloat {
                
                if animationToValue.floatValue == Float(relativeToValue) {
                    fromValue = animationToValue
                } else {
                    fromValue = NSNumber(value: Float(relativeToValue) as Float)
                }
            } else if let relativeToValue = presentationValue as? CATransform3D {
    
                if CATransform3DEqualToTransform(animationToValue.caTransform3DValue, relativeToValue) {
                    fromValue = NSValue(caTransform3D : animationLayerValue as! CATransform3D)
                } else {
                    fromValue = NSValue(caTransform3D : relativeToValue)
                }
                
            } else if CFGetTypeID(presentationValue as AnyObject) == CGColor.typeID {
            //    fromValue = animationLayerValue as! CGColor
                fromValue = presentationValue as! CGColor
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
