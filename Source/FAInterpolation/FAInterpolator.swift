//
//  FAInterpolator.swift
//  FlightAnimator-Demo
//
//  Created by Anton on 6/30/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public func typeCastCGColor(value : Any) -> CGColor? {
    if let currentValue = value as? AnyObject {
        //TODO: There appears to be no way of unwrapping a CGColor by type casting
        //Fix when the following bug is fixed https://bugs.swift.org/browse/SR-1612
        if CFGetTypeID(currentValue) == CGColorGetTypeID() {
            return (currentValue as! CGColor)
        }
    }
    
    return nil
}

struct FAAnimationConfig {
    static let InterpolationFrameCount  : CGFloat = 60.0
    
    static let SpringDecayFrequency     : CGFloat = 14.0
    static let SpringDecayDamping       : CGFloat = 0.97
    static let SpringCustomBounceCount  : Int = 4
    
    static let SpringDecayMagnitudeThreshold  : CGFloat = 1.35
    
    static let AnimationTimeAdjustment   : CGFloat = 2.0 * (1.0 / FAAnimationConfig.InterpolationFrameCount)
}

public class FAInterpolator {
    
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
        
        if previousValue != nil {
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
    
    func interpolatedConfigurationFor(animation : FABasicAnimation, relativeTo oldAnimation : FABasicAnimation?) ->  (duration : Double, easing : FAEasing,  values : [AnyObject])? {
        
        var easing = animation.easingFunction
        
        switch easing {
        case let .SpringDecay(velocity):
            
            if springs == nil {
                decayComponentSprings(velocity)
            }
            
            easing = adjustedVelocitySpring(easing, relativeTo : oldAnimation)
            
            let springConfig = interpolatedSpringValues(easing)
            
            return (duration : springConfig.duration, easing : easing, values : springConfig.values)
            
        case let .SpringCustom(velocity, frequency, damping):
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
    
    internal func adjustedVelocitySpring(easingFunction : FAEasing, relativeTo animation : FABasicAnimation?) -> FAEasing {
        
        var adjustedVelocity = zeroVelocityValue()
        
        if let animation = animation,
            presentationLayer  = animation.animatingLayer?.presentationLayer(),
            animationStartTime = animation.startTime {
            
            let currentTime = presentationLayer.convertTime(CACurrentMediaTime(), toLayer: animation.animatingLayer)
            let deltaTime = CGFloat(currentTime - animationStartTime) - FAAnimationConfig.AnimationTimeAdjustment
            
            adjustedVelocity = self.adjustedVelocity(at : deltaTime)
        }
        
        switch easingFunction {
        case .SpringDecay(_):
            return .SpringDecay(velocity:adjustedVelocity)
        case let .SpringCustom(_,frequency,damping):
            return .SpringCustom(velocity:adjustedVelocity, frequency: frequency, ratio: damping)
        default:
            return easingFunction
        }
    }
    
    internal func adjustedVelocity(at deltaTime : CGFloat?) -> Any {
        
        guard let deltaTime = deltaTime else {
            return zeroVelocityValue()
        }
        
        var progressComponents = [CGFloat]()
        
        for index in 0..<toVectoCount {
            progressComponents.append(springs![index].velocity(deltaTime))
        }
        
        return FAVector(comps : progressComponents).typeRepresentation(toValue)
    }
}

extension FAInterpolator {
    
    public func valueProgress(value : Any) -> CGFloat {
        let currentVector = FAVector(value: value)
        
        let progressedMagnitude = currentVector.magnitudeToVector(fromVector!)
        let overallMagnitude = fromVector!.magnitudeToVector(toVector!)
        return progressedMagnitude / overallMagnitude
    }
    
    private func relativeProgress() -> CGFloat {
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
                zeroValue = CGPointZero
            } else if let _ = toValue as? CGSize {
                zeroValue = CGSizeZero
            } else  if let _ = toValue as? CGRect {
                zeroValue = CGRectZero
            } else  if let _ = toValue as? CGFloat {
                zeroValue = CGFloat(0.0)
            } else  if let _ = toValue as? CATransform3D {
                zeroValue =  CATransform3DIdentity
            } else if let _ = typeCastCGColor(toValue) {
                zeroValue = UIColor().CGColor
            }
            return zeroValue
        }
        
        if let _ = presentationValue.typeValue() as? CGPoint {
            zeroValue = CGPointZero
        } else  if let _ = presentationValue.typeValue() as? CGSize {
            zeroValue = CGSizeZero
        } else  if let _ = presentationValue.typeValue() as? CGRect {
            zeroValue = CGRectZero
        } else  if let _ = presentationValue.typeValue() as? CATransform3D {
            zeroValue = CATransform3DIdentity
        }
        
        return zeroValue
    }
    
}

extension FAInterpolator {
    
    private func decayComponentSprings(initialVelocity: Any?) {
        customComponentSprings(initialVelocity,
                               angularFrequency: FAAnimationConfig.SpringDecayFrequency,
                               dampingRatio: FAAnimationConfig.SpringDecayDamping)
    }
    
    private func customComponentSprings(initialVelocity: Any?,
                                        angularFrequency: CGFloat,
                                        dampingRatio: CGFloat) {
        
        var vectorVelocity = FAVector(value :zeroVelocityValue())
        
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
    
    private func interpolatedParametricValues(duration : CGFloat, easingFunction : FAEasing) -> [AnyObject] {
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
    
    private func interpolatedValue(progress : CGFloat) -> FAVector {
        var progressComponents = [CGFloat]()
        
        for index in 0..<toVectoCount {
            progressComponents.append(interpolateCGFloat(fromVector!.components[index], end : toVector!.components[index], progress: progress))
        }
        
        return FAVector(comps: progressComponents)
    }
    
    private func interpolatedSpringValues(easingFunction : FAEasing) -> (duration : Double,  values : [AnyObject]) {
        
        var valueArray: Array<AnyObject> = Array<AnyObject>()
        var animationTime : CGFloat = 0.0
        let frameRateTimeUnit = 1.0 / FAAnimationConfig.InterpolationFrameCount
        
        var animationComplete = false
        
        switch easingFunction {
        case .SpringDecay(_):
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
    
    private func interpolatedSpringValue(deltaTime: CGFloat) -> FAVector {
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
    
    func interpolateCGFloat(start : CGFloat, end : CGFloat, progress : CGFloat) -> CGFloat {
        return start * (1.0 - progress) + end * progress
    }
}




