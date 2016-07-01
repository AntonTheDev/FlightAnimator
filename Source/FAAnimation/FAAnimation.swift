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
    
    func synchronizeWithAnimation(oldAnimation : FAAnimation? = nil) {
        configureValues(oldAnimation)
    }
    
    func configureValues(oldAnimation : FAAnimation? = nil) {
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
    }
    
    func scrubToProgress(progress : CGFloat) {
        self.weakLayer!.speed = 0.0
        self.weakLayer!.timeOffset = CFTimeInterval(duration * Double(progress))
    }
    
    private func synchProgress<T : FAAnimatable>(currentValue : T, oldAnimation : FAAnimation?) {
        
        fromValue = currentValue.valueRepresentation()
        
        synchronizeAnimationVelocity(currentValue, oldAnimation : oldAnimation)
        
        if let typedToValue = (toValue as? NSValue)?.typeValue() as? T {
            
            let previousFromValue = (oldAnimation?.fromValue as? NSValue)?.typeValue() as? T
    
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
    
    private func synchronizeAnimationVelocity<T : FAAnimatable>(fromValue : T, oldAnimation : FAAnimation?) {
       
        if  let presentationLayer = oldAnimation?.weakLayer?.presentationLayer(),
            let animationStartTime = oldAnimation?.startTime,
            let oldSprings = oldAnimation?.springs {
            
            let currentTime = presentationLayer.convertTime(CACurrentMediaTime(), toLayer: oldAnimation!.weakLayer)
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

