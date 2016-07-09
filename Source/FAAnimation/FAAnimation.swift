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

    var interpolator : Interpolator?
    
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
        removedOnCompletion = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        let animation = super.copyWithZone(zone) as! FAAnimation
        animation.primaryAnimation  = primaryAnimation
        animation.weakLayer         = weakLayer
        animation.fromValue         = fromValue
        animation.toValue           = toValue
        animation.easingFunction    = easingFunction
        animation.startTime         = startTime
        animation.interpolator      = interpolator
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
        if let presentationLayer = (weakLayer?.presentationLayer() as? CALayer),
           let presentationValue = presentationLayer.anyValueForKeyPath(self.keyPath!) {
        
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

            interpolator  = Interpolator(toValue: toValue,
                                         fromValue: fromValue,
                                         previousValue : runningAnimation?.fromValue)
            
            synchronizeAnimationVelocity(fromValue, runningAnimation: runningAnimation)
            
            let config = interpolator?.interpolatedConfiguration(CGFloat(duration), easingFunction: self.easingFunction)
            
            duration = config!.duration
            values = config!.values
        }
    }

    private func synchronizeAnimationVelocity(fromValue : Any, runningAnimation : FAAnimation?) {
        
        if  let presentationLayer = runningAnimation?.weakLayer?.presentationLayer(),
            let animationStartTime = runningAnimation?.startTime,
            let oldInterpolator = runningAnimation?.interpolator {
            
            let currentTime = presentationLayer.convertTime(CACurrentMediaTime(), toLayer: runningAnimation!.weakLayer)
            let deltaTime = CGFloat(currentTime - animationStartTime)
            
            easingFunction = oldInterpolator.adjustedVelocityEasing(deltaTime, easingFunction:  easingFunction)
        } else {
        
            switch easingFunction {
            case .SpringDecay(_):
                easingFunction =  FAEasing.SpringDecay(velocity: interpolator?.zeroValueVelocity())
            
            case let .SpringCustom(_,frequency,damping):
                easingFunction = FAEasing.SpringCustom(velocity: interpolator?.zeroValueVelocity() ,
                                                       frequency: frequency,
                                                       ratio: damping)
            default:
                break
            }
        }
    }
}

extension FAAnimation {
    
    func valueProgress() -> CGFloat {
        if let presentationValue = (weakLayer?.presentationLayer() as? CALayer)?.anyValueForKeyPath(self.keyPath!) {
            return interpolator!.valueProgress(presentationValue)
        }
    
        return 0.0
    }
    
    func timeProgress() -> CGFloat {
        let currentTime = weakLayer?.presentationLayer()!.convertTime(CACurrentMediaTime(), toLayer: nil)
        let difference = currentTime! - startTime!
        
        return CGFloat(round(100 * (difference / duration))/100) + 0.03333333333
    }
}

