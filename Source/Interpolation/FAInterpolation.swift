//
//  AnimatableProtocol+Interpolation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 4/22/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import QuartzCore

/**
 The timing priority effect how the time is resynchronized across the animation group.
 If the FAAnimation is marked as primary
 
 - MaxTime: <#MaxTime description#>
 - MinTime: <#MinTime description#>
 - Median:  <#Median description#>
 - Average: <#Average description#>
 */
public enum FAPrimaryTimingPriority : Int {
    case MaxTime
    case MinTime
    case Median
    case Average
}

/**
 Knowing the current progress, this method is called by the the FAAnimationGroup to
 get all the values interpolated over the duration during synchronization. From the
 initial value of the animation, to the final value of the animation. The initial
 value is determined by the current value of the presentation layer, for the duration
 adjusted accordingly during synchronization
 
 - parameter initialValue:   The initial value of an animable type
 - parameter finalValue:     The final value of an animable type
 - parameter duration:       the duration of an animation
 - parameter easingFunction: the easing function for the animation
 
 - returns: returns and array of NSValue/CGfloat ovjects for the keyframe animation to perform
 */
func interpolatedParametricValues<T : FAAnimatable>(initialValue : T,
                                  finalValue : T,
                                  duration : CGFloat,
                                  easingFunction : FAEasing) -> [AnyObject] {
    var newArray = [AnyObject]()
    var animationTime : CGFloat = 0.0

    let newValue = initialValue.interpolatedValue(finalValue, progress: 0.0)
    newArray.append(newValue)
    
    repeat {
        animationTime += 1.0 / 60.0
        let progress = easingFunction.parametricProgress(CGFloat(animationTime / duration))
        let newValue = initialValue.interpolatedValue(finalValue, progress: progress)
        newArray.append(newValue)
    } while (animationTime <= duration)

    newArray.removeLast()
    
    let finalValue = initialValue.interpolatedValue(finalValue, progress: 1.0)
    newArray.append(finalValue)
    return newArray
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

func interpolatedSpringValues<T : FAAnimatable>(toValue : T , springs : Dictionary<String, FASpring>, springEasing : FAEasing) -> (duration : Double,  values : [AnyObject]) {
    
    var valueArray: Array<AnyObject> = Array<AnyObject>()
    var animationTime : CGFloat = 0.0
    
    var animationComplete = false

    switch springEasing {
    case .SpringDecay(_):
        repeat {
            let newValue = toValue.interpolatedSpringValue(toValue, springs : springs, deltaTime: animationTime)
            let currentAnimatableValue  = newValue.typeValue() as! T
            animationComplete = toValue.magnitudeToValue(currentAnimatableValue)  < 1.2
        
            valueArray.append(newValue)
            animationTime += 1.0 / 60.0
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
            animationTime += 1.0 / 60.0
        } while (bouncCount < 12)
        
        break
    }

    valueArray.append(toValue.valueRepresentation())
    animationTime += 2.0 / 60.0
    
    return (Double(animationTime),  values : valueArray)
}
