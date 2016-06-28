//
//  FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public class FAAnimation : CAKeyframeAnimation {
    
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
        removedOnCompletion = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        let animation = super.copyWithZone(zone) as! FAAnimation
        animation.weakLayer          = weakLayer
        animation.fromValue         = fromValue
        animation.toValue           = toValue
        animation.easingFunction    = easingFunction
        animation.startTime         = startTime
        animation.springs           = springs
        return animation
    }
    
    var springs : Dictionary<String, FASpring>?
    
    func synchronizeWithAnimation(oldAnimation : FAAnimation?) {
        
        if let presentationValue = (weakLayer?.presentationLayer() as? CALayer)?.anyValueForKeyPath(self.keyPath!) {
            
            if let currentValue = presentationValue as? CGPoint {
                synchProgress(currentValue, oldAnimation : oldAnimation)
            } else  if let currentValue = presentationValue as? CGSize {
                synchProgress(currentValue, oldAnimation : oldAnimation)
            } else  if let currentValue = presentationValue as? CGRect {
                synchProgress(currentValue, oldAnimation : oldAnimation)
            } else  if let currentValue = presentationValue as? CGFloat {
                synchProgress(currentValue, oldAnimation : oldAnimation)
            } else  if let currentValue = presentationValue as? CATransform3D {
                synchProgress(currentValue, oldAnimation : oldAnimation)
            }
        }
        
        self.weakLayer?.owningView()
    }
    
    func configureValues() {
        if  let fromTypedValue = (fromValue as? NSValue)?.typeValue() {
            
            var configuration : (duration : Double,  values : [AnyObject])?
            
            if let fromValue =  fromTypedValue as? CGPoint {
                configuration = interpolatedValues(fromValue, animation: self)
            }
            else if let fromValue = fromTypedValue as? CGSize {
                configuration = interpolatedValues(fromValue, animation: self)
            }
            else if let fromValue =  fromTypedValue as? CGRect {
                configuration = interpolatedValues(fromValue, animation: self)
            }
            else if let fromValue = fromTypedValue as? CGFloat {
                configuration = interpolatedValues(fromValue, animation: self)
            }
            else if let fromValue = fromTypedValue as? CATransform3D {
                configuration = interpolatedValues(fromValue, animation: self)
            }
            
            if let config = configuration {
                duration = config.duration
                values = config.values
            }
        }
    }

    func scrubToProgress(progress : CGFloat) {
        self.weakLayer!.speed = 0.0
        self.weakLayer!.timeOffset = CFTimeInterval(duration * Double(progress))
    }
    
    private func synchProgress<T : FAAnimatable>(currentValue : T, oldAnimation : FAAnimation?) {
        
        if currentValue.valueRepresentation() != (fromValue as? NSValue) {
            fromValue = currentValue.valueRepresentation()
            
            let typedToValue = (self.toValue as? NSValue)?.typeValue() as! T
            let typedFromValue = (self.fromValue as? NSValue)?.typeValue() as! T
            
            switch self.easingFunction {
            case let .SpringDecay(velocity):
                synchronizeAnimationVelocity(oldAnimation)
                
                self.springs  = currentValue.interpolationSprings(typedToValue,
                                                                  initialVelocity: velocity,
                                                                  angularFrequency: 18,
                                                                  dampingRatio: 1.12)
                break
                
            case let .SpringCustom(velocity, frequency, damping):
                synchronizeAnimationVelocity(oldAnimation)
                
                self.springs  = currentValue.interpolationSprings(typedToValue,
                                                                  initialVelocity: velocity,
                                                                  angularFrequency: frequency,
                                                                  dampingRatio: damping)
                break
            default:
                self.duration = synchronizedConfiguration(typedFromValue,
                                                          newAnimation: self,
                                                          oldAnimation: oldAnimation) as! CFTimeInterval
            }
        }
        
        let typedFromValue = (self.fromValue as? NSValue)?.typeValue() as! T
        
        let config : (duration : Double,  values : [AnyObject])? = interpolatedValues(typedFromValue, animation: self)
        
        if let configurationValues = config  {
            duration = configurationValues.duration
            values = configurationValues.values
        }
    }
    
    private func synchronizeAnimationVelocity(oldAnimation : FAAnimation?) -> CGPoint? {
        
        if  let animation = oldAnimation,
            let presentationLayer = animation.weakLayer?.presentationLayer(),
            let animationStartTime = oldAnimation?.startTime,
            let oldSprings = oldAnimation?.springs {
            
            let currentTime = presentationLayer.convertTime(CACurrentMediaTime(), toLayer: animation.weakLayer)
            let difference = CGFloat(currentTime - animationStartTime)
            var newVelocity = CGPointZero
            
            if  let _fromValue = oldAnimation?.fromValue as? NSValue {
                if let _ =  _fromValue.typeValue() as? CGPoint,
                    let currentXVelocity = oldSprings[SpringAnimationKey.CGPointX]?.velocity(difference),
                    let currentYVelocity = oldSprings[SpringAnimationKey.CGPointY]?.velocity(difference) {
                    newVelocity = CGPointMake(currentXVelocity, currentYVelocity)
                } else if let _ =  _fromValue.typeValue() as? CGSize,
                    let currentXVelocity = oldSprings[SpringAnimationKey.CGSizeWidth]?.velocity(difference),
                    let currentYVelocity = oldSprings[SpringAnimationKey.CGSizeHeight]?.velocity(difference) {
                    newVelocity = CGPointMake(currentXVelocity, currentYVelocity)
                } else if let _ =  _fromValue.typeValue() as? CGRect,
                    let currentXVelocity = oldSprings[SpringAnimationKey.CGPointX]?.velocity(difference),
                    let currentYVelocity = oldSprings[SpringAnimationKey.CGPointY]?.velocity(difference) {
                    newVelocity = CGPointMake(currentXVelocity , currentYVelocity)
                }
            }
            
            switch self.easingFunction {
            case .SpringDecay(_):
                easingFunction = .SpringDecay(velocity: newVelocity)
            case let .SpringCustom(_,frequency,damping):
                easingFunction = .SpringCustom(velocity: newVelocity, frequency: frequency, ratio: damping)
            default:
                break
            }
        }
        
        return CGPointZero
    }
}