//
//  FAInterpolator.swift
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
    static let SpringCustomBounceCount  : Int = 4
    
    static let SpringDecayMagnitudeThreshold  : CGFloat = 1.35
    
    static let AnimationTimeAdjustment   : CGFloat = 2.0 * (1.0 / FAAnimationConfig.InterpolationFrameCount)
}

open class FAInterpolator {
    
    var toValue : Any
    var fromValue : Any
    var previousValue : Any?
    
    var toVector : FAVector?
    var fromVector : FAVector?
    var previousValueVector : FAVector?
    
    var springs : [FASpring]?
    
    init(_ toValue : Any, _ fromValue : Any, relativeTo previousValue : Any?) {
        
        if let typedToValue = (toValue as? NSValue)?.typeValue(),
            let typedFromValue = (fromValue as? NSValue)?.typeValue() {
            
            let previousFromValue = (previousValue as? NSValue)?.typeValue()
            
            self.toValue = typedToValue
            self.fromValue = typedFromValue
            self.previousValue = previousFromValue
            
        } else {
            self.toValue = toValue
            self.fromValue = fromValue
            self.previousValue = previousValue
        }
        
        self.toVector = FAVector(value: self.toValue)
        self.fromVector = FAVector(value: self.fromValue)
        
        if let previousValue = previousValue {
            self.previousValueVector = FAVector(value: previousValue)
        }
    }
    
    deinit {
        previousValue = nil
        
        toVector = nil
        fromVector = nil
        previousValueVector = nil
        
        springs = nil
    }
    
    func interpolatedConfigurationFor(_ animation : FABasicAnimation, relativeTo oldAnimation : FABasicAnimation?) ->  (duration : Double, easing : FAEasing,  values : [AnyObject])? {
        
        var easing = animation.easingFunction
        
        switch easing {
        case let .springDecay(velocity):
            
            if springs == nil {
                decayComponentSprings(velocity)
            }
            
            easing = adjustedVelocitySpring(easing, relativeTo : oldAnimation)
            
            let springConfig = interpolatedSpringValues(easing)
            
            return (duration : springConfig.duration, easing : easing, values : springConfig.values)
            
        case let .springCustom(velocity, frequency, damping):
            if springs == nil {
                customComponentSprings(velocity, angularFrequency: frequency, dampingRatio: damping)
            }
            
            easing = adjustedVelocitySpring(easing, relativeTo : oldAnimation)
            
            let springConfig = interpolatedSpringValues(easing)
            
            return (duration : springConfig.duration, easing : easing, values : springConfig.values)
        default:
            break
        }
        
        let adjustedDuration = CGFloat(animation.duration) * relativeProgress()
        let values = interpolatedParametricValues(adjustedDuration, easingFunction: easing)
        
        return (duration : Double(adjustedDuration), easing :easing, values : values)
    }
    
    internal func adjustedVelocitySpring(_ easingFunction : FAEasing, relativeTo animation : FABasicAnimation?) -> FAEasing {
        
        var adjustedVelocity = zeroVelocityValue()
        
        if let animation = animation,
            let presentationLayer  = animation.animatingLayer?.presentation(),
            let animationStartTime = animation.startTime {
            
            let currentTime = presentationLayer.convertTime(CACurrentMediaTime(), to: animation.animatingLayer)
            let deltaTime = CGFloat(currentTime - animationStartTime) - FAAnimationConfig.AnimationTimeAdjustment
            
            adjustedVelocity = self.adjustedVelocity(at : deltaTime)
        }
        
        switch easingFunction {
        case .springDecay(_):
            return .springDecay(velocity:adjustedVelocity)
        case let .springCustom(_,frequency,damping):
            return .springCustom(velocity:adjustedVelocity, frequency: frequency, ratio: damping)
        default:
            return easingFunction
        }
    }
    
    internal func adjustedVelocity(at deltaTime : CGFloat?) -> Any {
        
        guard let deltaTime = deltaTime else {
            
            if let zeroValue = zeroVelocityValue() {
                return zeroValue
            }
            
            fatalError("Unable to Determine Zero Value Type")
        }
        
        var progressComponents = [CGFloat]()
        
        for index in 0..<toVectoCount {
            progressComponents.append(springs![index].velocity(deltaTime))
        }
        
        if let vertor = FAVector(comps : progressComponents).typeRepresentation(toValue) {
            return vertor
        }
        
        fatalError("Unable to Create Vector for Adjusted Velocity Zero Value Type")
    }
}

extension FAInterpolator {
    
    public func valueProgress(_ value : Any) -> CGFloat {
        let currentVector = FAVector(value: value)
        
        let progressedMagnitude = currentVector.magnitudeToVector(fromVector!)
        let overallMagnitude = fromVector!.magnitudeToVector(toVector!)
        return progressedMagnitude / overallMagnitude
    }
    
    fileprivate func relativeProgress() -> CGFloat {
        if previousValueVector != nil ||
            previousValueVector == toVector {
            return 1.0
        }
        
        var progress : CGFloat  = 1.0
        
        if previousValueVector != nil {
            let progressedMagnitude = previousValueVector!.magnitudeToVector(fromVector!)
            let overallMagnitude = fromVector!.magnitudeToVector(toVector!)
            
            progress = progressedMagnitude / overallMagnitude
        }
        
        if progress.isNaN {
            progress = 1.0
        }
        
        return progress
    }
    
    func zeroVelocityValue() -> Any? {
        
        var zeroValue : Any?
        
        guard let presentationValue = toValue as? NSValue else {
            if let _ = toValue as? CGPoint {
                zeroValue = CGPoint.zero
            } else if let _ = toValue as? CGSize {
                zeroValue = CGSize.zero
            } else  if let _ = toValue as? CGRect {
                zeroValue = CGRect.zero
            } else  if let _ = toValue as? CGFloat {
                zeroValue = CGFloat(0.0)
            } else  if let _ = toValue as? CATransform3D {
                zeroValue =  CATransform3DIdentity
            } else if CFGetTypeID(toValue as AnyObject) == CGColor.typeID {
                zeroValue = UIColor().cgColor
            }
            return zeroValue
        }
        
        if let _ = presentationValue.typeValue() as? CGPoint {
            zeroValue = CGPoint.zero
        } else  if let _ = presentationValue.typeValue() as? CGSize {
            zeroValue = CGSize.zero
        } else  if let _ = presentationValue.typeValue() as? CGRect {
            zeroValue = CGRect.zero
        } else  if let _ = presentationValue.typeValue() as? CATransform3D {
            zeroValue = CATransform3DIdentity
        } 
        
        return zeroValue
    }
    
}

extension FAInterpolator {
    
    fileprivate func decayComponentSprings(_ initialVelocity: Any?) {
        customComponentSprings(initialVelocity,
                               angularFrequency: FAAnimationConfig.SpringDecayFrequency,
                               dampingRatio: FAAnimationConfig.SpringDecayDamping)
    }
    
    fileprivate func customComponentSprings(_ initialVelocity: Any?,
                                            angularFrequency: CGFloat,
                                            dampingRatio: CGFloat) {
        
        guard let zeroValue = zeroVelocityValue() else {
            fatalError("Unable to Determine Zero Value Type")
        }
        
        var vectorVelocity = FAVector(value : zeroValue)
        
        if let velocity = initialVelocity {
            vectorVelocity = FAVector(value :velocity)
        }

        springs = [FASpring]()
        
        for index in 0..<toVectoCount {
            let floatSpring = FASpring(finalValue   : toVector!.components[index],
                                       initialValue : fromVector!.components[index],
                                       positionVelocity: vectorVelocity.components[index],
                                       angularFrequency:angularFrequency,
                                       dampingRatio: dampingRatio)
            
            springs!.append(floatSpring)
        }
    }
}

extension FAInterpolator {
    
    fileprivate func interpolatedParametricValues(_ duration : CGFloat, easingFunction : FAEasing) -> [AnyObject] {
        var newArray = [AnyObject]()
        var animationTime : CGFloat = 0.0
        let frameRateTimeUnit = 1.0 / FAAnimationConfig.InterpolationFrameCount
        
        let firstValue = interpolatedValue(0.0)
        newArray.append(firstValue.valueRepresentation(toValue)!)
        
        repeat {
            animationTime += frameRateTimeUnit
            let progress = easingFunction.parametricProgress(CGFloat(animationTime / duration))
            let newValue = interpolatedValue(progress)
            if let valueRep = newValue.valueRepresentation(toValue) {
                newArray.append(valueRep)
            }
            
        } while (animationTime <= duration)
        
        newArray.removeLast()
        
        let finalValue = interpolatedValue(1.0)
        newArray.append(finalValue.valueRepresentation(toValue)!)
        return newArray
    }
    
    fileprivate func interpolatedValue(_ progress : CGFloat) -> FAVector {
        var progressComponents = [CGFloat]()
        
        for index in 0..<toVectoCount {
            progressComponents.append(interpolateCGFloat(fromVector!.components[index], end : toVector!.components[index], progress: progress))
        }
        
        return FAVector(comps: progressComponents)
    }
    
    fileprivate func interpolatedSpringValues(_ easingFunction : FAEasing) -> (duration : Double,  values : [AnyObject]) {
        
        var valueArray: Array<AnyObject> = Array<AnyObject>()
        var animationTime : CGFloat = 0.0
        let frameRateTimeUnit = 1.0 / FAAnimationConfig.InterpolationFrameCount
        
        var animationComplete = false
        
        switch easingFunction {
        case .springDecay(_):
            repeat {
                let newValue = interpolatedSpringValue(animationTime)
                animationComplete = newValue.magnitudeToVector(toVector!) < FAAnimationConfig.SpringDecayMagnitudeThreshold
                valueArray.append(newValue.valueRepresentation(toValue)!)
                animationTime += frameRateTimeUnit
            } while (animationComplete == false)
            
        default:
            var bouncCount = 0
            
            repeat {
                let newValue = interpolatedSpringValue(animationTime)
                if floor(newValue.magnitudeToVector(toVector!)) == 0.0 {
                    bouncCount += 1
                }
                
                valueArray.append(newValue.valueRepresentation(toValue)!)
                animationTime += frameRateTimeUnit
            } while (bouncCount < FAAnimationConfig.SpringCustomBounceCount)
            
            break
        }
        
        valueArray.append(toVector!.valueRepresentation(toValue)!)
        animationTime += frameRateTimeUnit
        
        return (Double(animationTime),  values : valueArray)
    }
    
    fileprivate func interpolatedSpringValue(_ deltaTime: CGFloat) -> FAVector {
        var progressComponents = [CGFloat]()
        
        for index in 0..<toVectoCount {
            progressComponents.append(springs![index].updatedValue(deltaTime))
        }
        
        return FAVector(comps: progressComponents)
    }
    
    var toVectoCount :Int {
        get {
            if let toVector = toVector {
                return toVector.components.count
            } else if let fromVector = fromVector {
                return fromVector.components.count
            } else {
                return 0
            }
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
    
    func interpolateCGFloat(_ start : CGFloat, end : CGFloat, progress : CGFloat) -> CGFloat {
        return start * (1.0 - progress) + end * progress
    }
}
