//
//  FAAnimatable+Interpolation.swift
//  FlightAnimator-Demo
//
//  Created by Anton on 6/30/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

struct FAAnimationConfig {
    static let InterpolationFrameCount  : CGFloat = 60.0
    
    static let SpringDecayFrequency     : CGFloat = 14.0
    static let SpringDecayDamping       : CGFloat = 0.97
    static let SpringCustomBounceCount  : Int = 12
    
    static let SpringDecayMagnitudeThreshold  : CGFloat = 1.2
}

public struct FAInterpolator<T : FAAnimatable> {
   
    var toValue   : T
    var fromValue : T
    var previousFromValue : T?
    
    var duration : CGFloat
    var easingFunction : FAEasing
    
    mutating func interpolatedAnimationConfig() -> (duration : Double,  values : [AnyObject], springs : Dictionary<String, FASpring>?) {
        
        switch easingFunction {
        case let .SpringDecay(velocity):
            
            let newSprings = fromValue.interpolationSprings(toValue,
                                                     initialVelocity: velocity,
                                                     angularFrequency: FAAnimationConfig.SpringDecayFrequency,
                                                     dampingRatio: FAAnimationConfig.SpringDecayDamping)
            
            return interpolatedSpringValues(newSprings)
            
        case let .SpringCustom(velocity, frequency, damping):
            
            let newSprings = fromValue.interpolationSprings(toValue,
                                                     initialVelocity: velocity,
                                                     angularFrequency: frequency,
                                                     dampingRatio: damping)
            
            
            return interpolatedSpringValues(newSprings)
        default:
            
            duration = relativeDuration()
            return (Double(duration), interpolatedParametricValues(CGFloat(duration),  easingFunction: easingFunction), springs : nil)
        }
    }
    
    private func relativeDuration() -> CGFloat {
        var progress : CGFloat  = CGFloat(1.0)
        
        if previousFromValue == toValue ||
            previousFromValue == nil {
            progress = CGFloat(1.0)
        } else {
            let progressedDiff = previousFromValue!.magnitudeToValue(fromValue)
            let remainingDiff  = fromValue.magnitudeToValue(toValue)
            
            progress  = remainingDiff / (remainingDiff + progressedDiff)
            
            if progress.isNaN {
                progress = CGFloat(1.0)
            }
        }
        
        return  CGFloat(duration) * progress
    }

    private func interpolatedParametricValues(adjustedDuration : CGFloat, easingFunction : FAEasing) -> [AnyObject] {
        
        var newArray = [AnyObject]()
        var animationTime : CGFloat = 0.0
        let frameRateTimeUnit = 1.0 / FAAnimationConfig.InterpolationFrameCount
        
        let newValue = fromValue.interpolatedValue(toValue, progress: 0.0)
        newArray.append(newValue)
        
        repeat {
            animationTime += frameRateTimeUnit
            let progress = easingFunction.parametricProgress(CGFloat(animationTime / duration))
            let newValue = fromValue.interpolatedValue(toValue, progress: progress)
            newArray.append(newValue)
        } while (animationTime <= duration)
        
        newArray.removeLast()
        
        let finalValue = fromValue.interpolatedValue(toValue, progress: 1.0)
        newArray.append(finalValue)
        return newArray
    }

    private func interpolatedSpringValues(springs : Dictionary<String, FASpring>) -> (duration : Double,  values : [AnyObject], springs : Dictionary<String, FASpring>?) {
        
        var valueArray: Array<AnyObject> = Array<AnyObject>()
        var animationTime : CGFloat = 0.0
        let frameRateTimeUnit = 1.0 / FAAnimationConfig.InterpolationFrameCount
        
        var animationComplete = false
        
        switch easingFunction {
        case .SpringDecay(_):
            repeat {
                let newValue = toValue.interpolatedSpringValue(toValue, springs : springs, deltaTime: animationTime)
                let currentAnimatableValue  = newValue.typeValue() as! T
                animationComplete = toValue.magnitudeToValue(currentAnimatableValue)  < FAAnimationConfig.SpringDecayMagnitudeThreshold
                
                valueArray.append(newValue)
                animationTime += frameRateTimeUnit
            } while (animationComplete == false)
            
        default:
            var bouncCount = 0
            
            repeat {
                let newValue = toValue.interpolatedSpringValue(toValue, springs : springs, deltaTime: animationTime)
                let currentAnimatableValue  = newValue.typeValue() as! T
                
                if floor(toValue.magnitudeToValue(currentAnimatableValue)) == 0.0 {
                    bouncCount += 1
                }
                
                valueArray.append(newValue)
                animationTime += frameRateTimeUnit
            } while (bouncCount < FAAnimationConfig.SpringCustomBounceCount)
            
            break
        }
        
        valueArray.append(toValue.valueRepresentation())
        animationTime += frameRateTimeUnit
        
        return (Double(animationTime),  values : valueArray, springs)
    }
}

/**
 This is a simple method that calculates the actual value between
 the relative start and end value, based on the progress
 
 - parameter start:    the relative intial value
 - parameter end:      the relative final value
 - parameter progress: the progress that has been traveled from the relative initial value
 
 - returns: the actual value of hte current progress between the relative start and end point
 */

func interpolateCGFloat(start : CGFloat, end : CGFloat, progress : CGFloat) -> CGFloat {
    return start * (1.0 - progress) + end * progress
}