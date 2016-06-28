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
 This method returns the remaining progress for the new animation, is added for the same key.
 for a parametric animation it returns the value progress, which is then used to calculate
 adjust the initial time for the new animation from the current animatable value. interpolate over
 
 To find the progress, first it calculates the magnitude from the old animation's toValue to
 the currrent value of the presentation layer. Then it calculates the magnitude of currentValue
 of the presentation layer, to the final value of the new animation.
 
 The remaining progress is then applied to the duration, and all the values are calculated
 accordingly to the parametric timing function.
 
 ||remaining|| / ||remaining|| + ||fromOldToValue||
 
 - parameter currentValue: the current animatable property value determined by the current presentation layer state
 - parameter lastToValue:  the last toValue from the previous animation applied to the layer for the same key
 - parameter toValue:      the final animatable property value the new animation is to be interpolated to
 
 - returns: the progress values remaining for the new animation, relative to it's current state
 */
func parametricProgressValue <T : FAAnimatable>(currentValue : T, oldFromValue: T, toValue : T) -> CGFloat {
    
    if oldFromValue == toValue {
        return CGFloat(1.0)
    }
    
    var progress : CGFloat  = CGFloat(FLT_EPSILON)
    
    let progressedDiff = oldFromValue.magnitudeToValue(currentValue)
    let remainingDiff  = currentValue.magnitudeToValue(toValue)
    
    progress  = remainingDiff / (remainingDiff + progressedDiff)

    if progress.isNaN {
        progress = CGFloat(1.0)
    }
    
    return  progress
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
        animationTime += 1.0 / 120.0
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

func synchronizedConfiguration<T : FAAnimatable>(currentValue : T, newAnimation : FAAnimation?, oldAnimation : FAAnimation?) -> Any? { // (fromValue :
    
    if oldAnimation == nil {
        let duration = CFTimeInterval(CGFloat((newAnimation?.duration)!) * (1.0))
        return duration
    }

    if let toValue = (newAnimation?.toValue as? NSValue)?.typeValue() as? T,
       let oldFromValue = (oldAnimation?.fromValue as? NSValue)?.typeValue() as? T {
        
        let progress = parametricProgressValue(currentValue,
                                               oldFromValue : oldFromValue,
                                               toValue : toValue)
        
        let duration = CFTimeInterval(CGFloat((newAnimation?.duration)!) * (progress))
        
        return duration
    }
    
    return CFTimeInterval(CGFloat((newAnimation?.duration)!))
}

func interpolatedValues<T : FAAnimatable>(fromValue : T, animation : FAAnimation?) -> (duration : Double,  values : [AnyObject]) {
    
    if let toValue = (animation?.toValue as? NSValue)?.typeValue() as? T {
        
        switch animation!.easingFunction {
        case let .SpringDecay(velocity):
            if let springs = animation?.springs {
                return interpolatedSpringValues(toValue, springs: springs, springEasing : .SpringDecay(velocity: velocity))
            }
        case let .SpringCustom(velocity,frequency,damping):
            if let springs = animation?.springs {
                return interpolatedSpringValues(toValue, springs: springs, springEasing : .SpringCustom(velocity: velocity,frequency: frequency,ratio: damping))
            }
        default:
            return (animation!.duration, interpolatedParametricValues(fromValue,
                finalValue: toValue ,
                duration: CGFloat(animation!.duration),
                easingFunction: (animation?.easingFunction)!))
        }
    }
    
    return (0.0, [AnyObject]())
}