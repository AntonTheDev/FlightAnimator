//
//  FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

final public class FAAnimation : CAKeyframeAnimation {
    
    weak var weakLayer : CALayer?
    
    // The easing funtion applied to the duration of the animation
    var easingFunction : FAEasing = FAEasing.Linear
    
    
    // ToValue for the animation
    var toValue: AnyObject?
    
    
    // The start time of the animation, set by the current time of
    // the layer when it is added. Used by the springs to find the
    // current velocity in motion
    var startTime : CFTimeInterval?
    
    
    // FromValue defined automatically during synchronization
    // based on the presentation layer properties
    internal var fromValue: AnyObject?
    
    
    // Flag used to track the animation as a primary influencer for the
    // overall timing within an animation group.
    //
    // To set the value call `setAnimationAsPrimary(primary : Bool)`
    // To access the value call `isAnimationPrimary() -> Bool`
    //
    // If multiple animations are primary animations are within a group, the
    // group will take use the primaryTimingPriority setting for the group,
    // and will then synchronization the duration across the remaining animations
    //
    // FASpringAnimation types will always be considered primary, due to the
    // fact they calculate their duration dynamically based on the spring
    // configuration, and if configured with a lower duration than other
    // non spring animations, it may not progress to the final value.
    private var primaryAnimation : Bool = false
    
    var springs : Dictionary<String, FASpring>?
    
    func setAnimationAsPrimary(primary : Bool) {
        primaryAnimation = primary
    }
    
    func isAnimationPrimary() -> Bool {
        switch self.easingFunction {
        case .SpringDecay:
            return true
        case .SpringCustom(_, _, _):
            return true
        default:
            return primaryAnimation
        }
    }
    
    override init() {
        super.init()
        CALayer.swizzleAddAnimation()
        
        calculationMode = kCAAnimationLinear
        fillMode = kCAFillModeForwards
        removedOnCompletion = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        let animation = super.copyWithZone(zone) as! FAAnimation
        animation.weakLayer         = weakLayer
        animation.fromValue         = fromValue
        animation.toValue           = toValue
        animation.easingFunction    = easingFunction
        animation.startTime         = startTime
        animation.springs           = springs
        return animation
    }
    
    func synchronize(runningAnimation animation : FAAnimation? = nil) {
        configureValues(animation)
    }
    
    func scrubToProgress(progress : CGFloat) {
        self.weakLayer!.speed = 0.0
        self.weakLayer!.timeOffset = CFTimeInterval(duration * Double(progress))
    }
}

extension FAAnimation {

    private func configureValues(runningAnimation : FAAnimation? = nil) {
        if let presentationValue = (weakLayer?.presentationLayer() as? CALayer)?.anyValueForKeyPath(self.keyPath!) {
            if let currentValue = presentationValue as? CGPoint {
                syncValues(currentValue, runningAnimation : runningAnimation)
            } else  if let currentValue = presentationValue as? CGSize {
                syncValues(currentValue, runningAnimation : runningAnimation)
            } else  if let currentValue = presentationValue as? CGRect {
                syncValues(currentValue, runningAnimation : runningAnimation)
            } else  if let currentValue = presentationValue as? CGFloat {
                syncValues(currentValue, runningAnimation : runningAnimation)
            } else  if let currentValue = presentationValue as? CATransform3D {
                syncValues(currentValue, runningAnimation : runningAnimation)
            
                //TODO: Figure out how to unwrap CoreFoundation type in swift
                //There appears to be no way of unwrapping a CGColor by type casting
            } else if self.keyPath == "backgroundColor" {
                syncValues(presentationValue as! CGColor, runningAnimation : runningAnimation)
                
            }
        }
    }
    
    private func syncValues<T : FAAnimatable>(currentValue : T, runningAnimation : FAAnimation?) {
        
        fromValue = currentValue.valueRepresentation()
        
        synchronizeAnimationVelocity(currentValue, runningAnimation : runningAnimation)
        
        if let typedToValue = (toValue as? NSValue)?.typeValue() as? T {
            
            let previousFromValue = (runningAnimation?.fromValue as? NSValue)?.typeValue() as? T
            
            var interpolator  = FAInterpolator(toValue : typedToValue,
                                               fromValue: currentValue,
                                               previousFromValue : previousFromValue,
                                               duration: CGFloat(duration),
                                               easingFunction : easingFunction)
            
            let config = interpolator.interpolatedAnimationConfig()
            
            springs = config.springs
            duration = config.duration
            values = config.values
            
            
            // TODO: Figure out how to unwrap CoreFoundation type in swift
            // There appears to be no way of unwrapping a CGColor by type casting
            // So there is a check to see if the value itself conforms to FAAnimatable,
            // otherwise it should get caught above as an NSValue
        } else  if let typedToValue = toValue  as? T {
            
            let previousFromValue = runningAnimation?.fromValue as? T
            
            var interpolator  = FAInterpolator(toValue : typedToValue,
                                               fromValue: currentValue,
                                               previousFromValue : previousFromValue,
                                               duration: CGFloat(duration),
                                               easingFunction : easingFunction)
            
            let config = interpolator.interpolatedAnimationConfig()
            
            springs = config.springs
            duration = config.duration
            values = config.values
        }
    }
    
    private func synchronizeAnimationVelocity<T : FAAnimatable>(fromValue : T, runningAnimation : FAAnimation?) {
        
        if  let presentationLayer = runningAnimation?.weakLayer?.presentationLayer(),
            let animationStartTime = runningAnimation?.startTime,
            let oldSprings = runningAnimation?.springs {
            
            let currentTime = presentationLayer.convertTime(CACurrentMediaTime(), toLayer: runningAnimation!.weakLayer)
            let deltaTime = CGFloat(currentTime - animationStartTime)
            
            let newVelocity =  fromValue.springVelocity(oldSprings, deltaTime: deltaTime)
            
            switch easingFunction {
            case .SpringDecay(_):
                easingFunction = .SpringDecay(velocity: newVelocity)
            case let .SpringCustom(_,frequency,damping):
                easingFunction = .SpringCustom(velocity: newVelocity, frequency: frequency, ratio: damping)
            default:
                break
            }
        }
    }
}


extension FAAnimation {
    
    func valueProgress() -> CGFloat {
        if let presentationValue = (weakLayer?.presentationLayer() as? CALayer)?.anyValueForKeyPath(self.keyPath!) {
            
            if let currentValue = presentationValue as? CGPoint {
                return valueProgress(currentValue)
            } else  if let currentValue = presentationValue as? CGSize {
                return valueProgress(currentValue)
            } else  if let currentValue = presentationValue as? CGRect {
                return valueProgress(currentValue)
            } else  if let currentValue = presentationValue as? CGFloat {
                return valueProgress(currentValue)
            } else  if let currentValue = presentationValue as? CATransform3D {
                return valueProgress(currentValue)
                
                //TODO: Figure out how to unwrap CoreFoundation type in swift
                //There appears to be no way of unwrapping a CGColor by type casting
            } else if self.keyPath == "backgroundColor" {
                return valueProgress(presentationValue as! CGColor)
            }
        }
    
        return 0.0
    }
    
    func timeProgress() -> CGFloat {
        let currentTime = weakLayer?.presentationLayer()!.convertTime(CACurrentMediaTime(), toLayer: nil)
        let difference = currentTime! - startTime!
        
        return CGFloat(round(100 * (difference / duration))/100) + 0.03333333333
    }
    
    private func valueProgress<T : FAAnimatable>(currentValue : T) -> CGFloat {
       
        if let typedToValue = (toValue as? NSValue)?.typeValue() as? T,
           let typedFromValue = (fromValue as? NSValue)?.typeValue() as? T{
            
            return currentValue.magnitudeToValue(typedToValue) / typedFromValue.magnitudeToValue(typedToValue)
       
            //TODO: Figure out how to unwrap CoreFoundation type in swift
            //There appears to be no way of unwrapping a CGColor by type casting
        } else if let typedToValue = toValue  as? T,
                  let typedFromValue = fromValue  as? T {
            
            return currentValue.magnitudeToValue(typedToValue) / typedFromValue.magnitudeToValue(typedToValue)
        }
        
        return 0.0
    }
}

