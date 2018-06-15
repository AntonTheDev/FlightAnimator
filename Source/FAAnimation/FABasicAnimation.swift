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

open class FABasicAnimation : CAKeyframeAnimation
{
    open weak var animatingLayer : CALayer?

    open var toValue        : AnyObject? {
        didSet { toAnimatableValue = animatableValue(from: toValue) }
    }
    
    open var fromValue      : AnyObject? {
        didSet { fromAnimatableValue = animatableValue(from: fromValue) }
    }
    
    open var previousValue  : AnyObject? {
        didSet { previousAnimatableValue = animatableValue(from: previousValue) }
    }
    
    internal var toAnimatableValue       : FAAnimatable?
    internal var fromAnimatableValue     : FAAnimatable?
    internal var previousAnimatableValue : FAAnimatable?

    open var easingFunction : FAEasing = .linear
    
    open override var timingFunction: CAMediaTimingFunction? {
        didSet { easingFunction = easingFunction(from : timingFunction) }
    }
    
    internal var springs                 : [FASpring]?
    internal var startTime               : CFTimeInterval?
    internal var isPrimary      : Bool = false

    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initializeInitialValues()
    }
    
    override public init()
    {
        super.init()
        initializeInitialValues()
    }
    
    public convenience init(keyPath path: String?)
    {
        self.init()
        keyPath = path
        initializeInitialValues()
    }
    
    internal func initializeInitialValues()
    {
        CALayer.swizzleAddAnimation()
        
        calculationMode = kCAAnimationLinear
        fillMode = kCAFillModeForwards
        
        isRemovedOnCompletion = true
        values = [AnyObject]()
    }
    
    override open func copy(with zone: NSZone?) -> Any
    {
        let animation = super.copy(with: zone) as! FABasicAnimation
        
        animation.animatingLayer            = animatingLayer
        animation.easingFunction            = easingFunction
        animation.isPrimary                 = isPrimary
        
        animation.toValue                   = toValue
        animation.fromValue                 = fromValue
        animation.previousValue             = previousValue
        
        animation.toAnimatableValue         = toAnimatableValue
        animation.fromAnimatableValue       = fromAnimatableValue
        animation.previousAnimatableValue   = previousAnimatableValue

        animation.springs                   = springs
        animation.startTime                 = startTime
        
        return animation
    }
    
    func animatableValue(from anyObject : AnyObject?) -> FAAnimatable?
    {
        if CFGetTypeID(anyObject as AnyObject) == CGColor.typeID
        {
            return CGColorWrapper(withColor: anyObject as! CGColor)
        }
        
        if let anyObject = anyObject as? UIColor
        {
            return CGColorWrapper(withColor: anyObject.cgColor)
        }
        
        if let anyObject = anyObject as? NSValue
        {
            return anyObject.typedValue() as? FAAnimatable
        }
        
        return nil
    }
    
    internal func easingFunction(from mediaTiming : CAMediaTimingFunction?) -> FAEasing
    {
        guard let mediaTiming = mediaTiming else {
            return .linear
        }
        
        print("timingFunction has no effect, converting to 'easingFunction' property\n")
        
        switch mediaTiming.value(forKey: "name") as! String {
        case kCAMediaTimingFunctionEaseIn:
            return .inCubic
        case kCAMediaTimingFunctionEaseOut:
            return .outCubic
        case kCAMediaTimingFunctionEaseInEaseOut:
            return .inOutCubic
        default:
            return .smoothStep
        }
    }
}

//MARK: - Synchronization Logic

internal extension FABasicAnimation {
    
    internal func synchronize(relativeTo animation : FABasicAnimation? = nil)
    {
        previousValue = animation?.fromValue
		
		configureFromValue()
		
		configuredAnimationValues(relativeTo: animation)
    }
    
    fileprivate func configureFromValue()
    {
        /**
         *  When we add a new animation it appears that if there was a prior animation,
         *  the current layer's presentation value is still the last animation's
         *  final value. Thus, if we change the model layer's value, prior to kicking off
         *  the new animation, we need to check if the current toValue is equal to
         *  the presentation layer's value, if not we need to use the model layer's
         *  value instead of the presentation layer.
         *
         *  Technically if the fromValue (presentation layer's current value) is equal
         *  to the from value, and the current layer's value does not match, it means that
         *  we do not need to intercept the animation in flight, and skip the synchronization.
         *
         */
        guard let animationLayerValue = animatingLayer?.animatableValueForKeyPath(keyPath!),
              let presentationValue = animatingLayer?.presentation()?.animatableValueForKeyPath(keyPath!) else
        {
            return
        }
		
		if animationLayerValue == presentationValue
		{
			fromValue = animationLayerValue.valueRepresentation
		}
		else
		{
			fromValue = presentationValue.valueRepresentation
		}
    }
    
    func configuredAnimationValues(relativeTo oldAnimation : FABasicAnimation?)
    {
        var newValues : [Any]?
        
        switch easingFunction {
        case let .springDecay(velocity):
            
            if springs == nil
            {
                springComponents(velocity,
                                 angularFrequency: FAConfig.SpringDecayFrequency,
                                 dampingRatio: FAConfig.SpringDecayDamping)
            }
            
            easingFunction = adjustedVelocityEasing(easingFunction, relativeTo : oldAnimation)
            
            let springConfig = interpolatedSpringDecayValues()
            
            duration = springConfig.duration
            newValues = springConfig.values
       
        case let .springCustom(velocity, frequency, damping):
            
            if springs == nil
            {
                springComponents(velocity, angularFrequency: frequency, dampingRatio: damping)
            }
            
            easingFunction = adjustedVelocityEasing(easingFunction, relativeTo : oldAnimation)
            
            let springConfig = interpolatedSpringValues()
            duration = springConfig.duration
            newValues = springConfig.values
            
        default:
            
            duration = CFTimeInterval(CGFloat(duration) * relativeProgress())
            newValues = interpolatedParametricValues(CGFloat(duration), easingFunction: easingFunction)
        }
        
        duration = CFTimeInterval(CGFloat(duration) * relativeProgress())
        values = newValues
    }
}


//MARK: - Animation Progress Calculations

internal extension FABasicAnimation {
   
    func valueProgress() -> CGFloat
    {
        guard let presentationValue = animatingLayer?.presentation()?.animatableValueForKeyPath(keyPath!),
              let toValue = toAnimatableValue,
              let fromValue = fromAnimatableValue else
        {
            return 0.0
        }
        
        return toValue.valueProgress(fromValue: fromValue, atValue: presentationValue)
    }
    
    func timeProgress() -> CGFloat
    {
        if let presentationLayer = animatingLayer?.presentation()
        {
            let currentTime = presentationLayer.convertTime(CACurrentMediaTime(), to: nil)
            let difference = currentTime - startTime!
            
            return CGFloat(round(100 * (difference / duration))/100)
        }
        
        return 0.0
    }
    
    fileprivate func relativeProgress() -> CGFloat
    {
        guard let toAnimatableValue = toAnimatableValue,
              let fromAnimatableValue = fromAnimatableValue else
        {
            return 0.0
        }
        
        guard let previousValue = previousAnimatableValue,
                  previousValue == toAnimatableValue else
        {
            return 1.0
        }
        
        var progress : CGFloat  = 1.0
        
        let progressedMagnitude = previousValue.magnitude(toValue:fromAnimatableValue)
        let overallMagnitude = fromAnimatableValue.magnitude(toValue:toAnimatableValue)
        
        progress = progressedMagnitude / overallMagnitude
        
        if progress.isNaN
        {
            progress = 1.0
        }
        
        return progress
    }
}


//MARK: Parametric Interpolation
internal extension FABasicAnimation
{
    fileprivate func interpolatedParametricValue(fromValue : FAAnimatable,
                                                 toValue : FAAnimatable,
                                                 atProgress progress : CGFloat) -> FAAnimatable
    {
		return fromValue.progressValue(to: toValue, atProgress: progress)
    }
	
    fileprivate func interpolatedParametricValues(_ duration : CGFloat,
                                                  easingFunction : FAEasing) -> [AnyObject]
    {
        var newArray = [AnyObject]()
        
        guard let toAnimatableValue = toAnimatableValue,
            let fromAnimatableValue = fromAnimatableValue else
        {
            return newArray
        }
        
        var animationTime : CGFloat = 0.0
        let frameRateTimeUnit = 1.0 / FAConfig.InterpolationFrameCount
    
        let firstValue = fromAnimatableValue.progressValue(to:toAnimatableValue, atProgress: 0.0).valueRepresentation

        newArray.append(firstValue)
        
        repeat
        {
            animationTime += frameRateTimeUnit
            let progress = easingFunction.parametricProgress(CGFloat(animationTime / duration))
           
            let newValue = fromAnimatableValue.progressValue(to:toAnimatableValue, atProgress: progress).valueRepresentation

            newArray.append(newValue)
            
        } while (animationTime <= duration)
    
        let finalValue = fromAnimatableValue.progressValue(to:toAnimatableValue, atProgress: 1.0).valueRepresentation
       
        newArray.removeLast()
        newArray.append(finalValue)
		
		return newArray
    }
}

//MARK: Spring Configuration

internal extension FABasicAnimation
{
    fileprivate func springComponents(_ initialVelocity: Any?,
                                            angularFrequency: CGFloat,
                                            dampingRatio: CGFloat) {
        
        guard let toAnimatableValue = toAnimatableValue,
            let fromAnimatableValue = fromAnimatableValue else
        {
            return
        }
        
        var vectorVelocity = toAnimatableValue.zeroVelocityValue
        
        if let velocity = initialVelocity as? FAAnimatable {
            vectorVelocity = velocity
        }
        
        springs = [FASpring]()
        
        if toAnimatableValue.vector.count == fromAnimatableValue.vector.count
        {
            for index in 0..<toAnimatableValue.componentCount
            {
                let floatSpring = FASpring(finalValue       : toAnimatableValue.vector[index],
                                           initialValue     : fromAnimatableValue.vector[index],
                                           positionVelocity : vectorVelocity.vector[index],
                                           angularFrequency : angularFrequency,
                                           dampingRatio     : dampingRatio)
                
                springs!.append(floatSpring)
            }
        }
    }

    internal func adjustedVelocityEasing(_ easingFunction : FAEasing,
										 relativeTo animation : FABasicAnimation?) -> FAEasing
    {
        guard let toAnimatableValue = animation?.toAnimatableValue else
        {
            return easingFunction
        }
        
        var adjustedVelocity : Any = toAnimatableValue.zeroVelocityValue
        
        if  let presentationLayer  = animation?.animatingLayer?.presentation(),
            let animatingLayer = animation?.animatingLayer,
            let animationStartTime = animation?.startTime
        {
            let currentTime = presentationLayer.convertTime(CACurrentMediaTime(), to: animatingLayer)
            let deltaTime = CGFloat(currentTime - animationStartTime) - FAConfig.AnimationTimeAdjustment
			
            var progressComponents = [CGFloat]()
            
            for index in 0..<toAnimatableValue.componentCount
            {
                progressComponents.append(springs![index].velocity(deltaTime))
            }
            
            adjustedVelocity = toAnimatableValue.valueFromComponents(progressComponents)
        }
        
        switch easingFunction
        {
        case .springDecay(_):
            
            return .springDecay(velocity:adjustedVelocity)
            
        case let .springCustom(_,frequency,damping):
            
            return .springCustom(velocity:adjustedVelocity, frequency: frequency, ratio: damping)
            
        default:
            
            return easingFunction
        }
    }
}


//MARK: Spring Calculations

internal extension FABasicAnimation
{
    fileprivate func interpolatedSpringValue(_ deltaTime: CGFloat) -> AnyObject
    {
        guard let fromAnimatableValue = fromAnimatableValue else
        {
            return NSNumber(floatLiteral: 0.0)
        }
        
        var progressComponents = [CGFloat]()
        
        for index in 0..<fromAnimatableValue.componentCount
        {
            progressComponents.append(springs![index].updatedValue(deltaTime))
        }
        
        return fromAnimatableValue.valueFromComponents(progressComponents)
    }
    
    fileprivate func interpolatedSpringDecayValues() -> (duration : Double, values : [AnyObject])
    {
        guard let toAnimatableValue = toAnimatableValue else
        {
            return (Double(0.0),  values : Array<AnyObject>())
        }
        
        var valueArray: Array<AnyObject> = Array<AnyObject>()
        var animationTime : CGFloat = 0.0
        let frameRateTimeUnit = 1.0 / FAConfig.InterpolationFrameCount
        
        var animationComplete = false
        
        repeat {
            
            if  let newObjectValue = interpolatedSpringValue(animationTime) as? NSValue,
                let newValue = newObjectValue.typedValue() as? FAAnimatable,
                let toAnimatableValue = self.toAnimatableValue
            {
                animationComplete = newValue.magnitude(toValue: toAnimatableValue) < FAConfig.SpringDecayMagnitudeThreshold
                valueArray.append(newValue.valueRepresentation)
                animationTime += frameRateTimeUnit
            }
            
        } while (animationComplete == false)
        
        valueArray.append(toAnimatableValue.valueRepresentation)
        return (duration : Double(animationTime), values : valueArray)
    }
    
    fileprivate func interpolatedSpringValues() -> (duration : Double, values : [AnyObject])
    {
        guard let toAnimatableValue = toAnimatableValue else
        {
            return (Double(0.0),  values : Array<AnyObject>())
        }
        
        var valueArray: Array<AnyObject> = Array<AnyObject>()
        var animationTime : CGFloat = 0.0
        let frameRateTimeUnit = 1.0 / FAConfig.InterpolationFrameCount
        
        var bounceCount = 0
        
        repeat
        {
            if let nsValue = interpolatedSpringValue(animationTime) as? NSValue,
               let newValue = nsValue.typedValue() as? FAAnimatable
            {
                if floor(newValue.magnitude(toValue: toAnimatableValue)) == 0.0
                {
                    bounceCount += 1
                }
                
                valueArray.append(newValue.valueRepresentation)
            }
            else if let newValue = interpolatedSpringValue(animationTime) as? CGColorWrapper
            {
                if floor(newValue.magnitude(toValue: toAnimatableValue)) == 0.0
                {
                    bounceCount += 1
                }
                
                valueArray.append(newValue.valueRepresentation)
            }
            
            animationTime += frameRateTimeUnit
            
        } while (bounceCount < FAConfig.SpringCustomBounceCount)
        
        
        valueArray.append(toAnimatableValue.valueRepresentation as AnyObject)
        animationTime += frameRateTimeUnit
        
        return (duration : Double(animationTime), values : valueArray)
    }
}
