//
//  FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
//MARK: - FABasicAnimation
open class FABasicAnimation : CAKeyframeAnimation
{
    /**
     *
     * This is the animating layer that is part of this animation.
     *
     * A weak reference used later when intercepting the animation
     * in mid flight, the presentation
     * layer is actusally the one representing the current property
     * value for the actual visual representation of the layer
     * while in mid flight
     *
     */
    open weak var animatingLayer : CALayer?                         // Copied


    /**
     * This is the destination toValue for the animation.
     *
     * Supported Types:
     *  * CGFloat
     *  * CGPoint
     *  * CGSize
     *  * CGRect
     *  * CGColor
     *  * CATransform3D
     *
     */
    open var toValue        : AnyObject? {                          // Copied
        didSet {
            toAnimatableValue = animatableValue(from: toValue)
        }
    }
    
    
    /**
     *
     * The fromValue for the animation. Configured from
     * the presentation layer's value when the animation
     * is intercepted in flight.
     *
     * Otherwise, it is set to the layer's current value,
     * when the animation begins.
     *
     * Supported Types:
     *  * CGFloat
     *  * CGPoint
     *  * CGSize
     *  * CGRect
     *  * CGColor
     *  * CATransform3D
     *
     */
    open var fromValue      : AnyObject? {                          // Copied
        didSet {
            fromAnimatableValue = animatableValue(from: fromValue)
        }
    }
    
    
    /**
     *
     * The previous value is set if there is a prior
     * animation in propress for the specific property.
     *
     * So, if it's in mid flight, and a new animation
     * is applied, it uses projection to recalculate
     * the remaiming time to be reapplied for all the
     * propprty animations in progress of animation
     *
     */
    open var previousValue  : AnyObject? {                          // Copied
        didSet {
            previousAnimatableValue = animatableValue(from: previousValue)
        }
    }

    
    /**
     *
     * Animatable interpretation for the animation value, ^ set above
     * in the didSet observer, most values work no problem.
     *
     * Be on the watch out for the CGColorWrapper,
     * kind of an odd exception, something trips out if you
     * cast CGColor to a protocol.
     *
     */
    internal var toAnimatableValue       : FAAnimatable?            // Copied
    
    
    /**
     *
     * Animatable interpretation for the animation value, ^ set above
     * in the didSet observer, most values work no problem.
     *
     * Be on the watch out for the CGColorWrapper,
     * kind of an odd exception, something trips out if you
     * cast CGColor to a protocol.
     *
     */
    internal var fromAnimatableValue     : FAAnimatable?            // Copied
    
    
    /**
     *
     * Animatable interpretation for the animation value, ^ set above
     * in the didSet observer, most values work no problem.
     *
     * Be on the watch out for the CGColorWrapper,
     * kind of an odd exception, something trips out if you
     * cast CGColor to a protocol.
     *
     */
    internal var previousAnimatableValue : FAAnimatable?            // Copied

    /**
     *
     * The easing function of the property animation
     *
     */
    open var easingFunction : FAEasing = .linear                    // Copied
    
    
    /**
     *
     * If you want to pretend this is a CABasicAnimation Animation?
     *
     */
    open override var timingFunction: CAMediaTimingFunction? {
        didSet {
            easingFunction = easingFunction(from : timingFunction)
        }
    }
    

    /**
     *
     * The vector springs, every single property is a vector.
     * every dimention of a vector gets assigned a spring
     * when using the decay of spring easing functions
     *
     */
    internal var springs                 : [FASpring]?              // Copied
    
    
    /**
     *
     * This is the CALayer start time, mapped to the
     * layer's timespace. It's as if each layer lives
     * within a multiverse
     *
     */
    internal var startTime               : CFTimeInterval?          // Copied
    
    
    /**
     *
     * This flag determines if the animation is the primary
     * driver. When multiple animations need to compete
     * to be the source of truth in synchcronizing against,
     * this flag allows for predetrmining one, otherwise the
     * the FAAnimationGroup will determine it based on the
     * timing priority defined.
     *
     */
    internal var isPrimary      : Bool = false                      // Copied


    override public init()
    {
        super.init()
        configureDefaultState()
    }
    
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        configureDefaultState()
    }
    
    
    public convenience init(keyPath path: String?)
    {
        self.init()
        keyPath = path
        configureDefaultState()
    }
    
    
    internal func configureDefaultState()
    {
        CALayer.swizzleAddAnimation()
        
        calculationMode = .linear
        fillMode = .forwards
        
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
        
        animation.easingFunction            = easingFunction
        
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
        guard let mediaTiming = mediaTiming else
        {
            return .linear
        }
        
        print("timingFunction has no effect, converting to 'easingFunction' property\n")
        
        switch mediaTiming.value(forKey: "name") as! String
        {
        case CAMediaTimingFunctionName.easeIn.rawValue:
            
            return .inCubic
        
        case CAMediaTimingFunctionName.easeOut.rawValue:
        
            return .outCubic
        
        case CAMediaTimingFunctionName.easeInEaseOut.rawValue:
        
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
         *  to the from value, and if the current layer's value does not equal to the
         *  presentation layer's value, it means that  we do not need to intercept
         *  the animation in flight, and skip the synchronization.
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
                                      dampingRatio: CGFloat)
    {
        guard let toAnimatableValue = toAnimatableValue,
              let fromAnimatableValue = fromAnimatableValue else
        {
            return
        }
        
        var vectorVelocity = (initialVelocity as? FAAnimatable)?.vector ?? toAnimatableValue.zeroVelocityVector

        springs = [FASpring]()
        
        if toAnimatableValue.vector.count == fromAnimatableValue.vector.count
        {
            for index in 0..<toAnimatableValue.componentCount
            {
                let floatSpring = FASpring(finalValue       : toAnimatableValue.vector[index],
                                           initialValue     : fromAnimatableValue.vector[index],
                                           positionVelocity : vectorVelocity[index],
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
        
        var adjustedVelocity : [CGFloat] = toAnimatableValue.zeroVelocityVector
        
        if  let presentationLayer  = animation?.animatingLayer?.presentation(),
            let animatingLayer = animation?.animatingLayer,
            let animationStartTime = animation?.startTime
        {
            let currentTime = presentationLayer.convertTime(CACurrentMediaTime(), to: animatingLayer)
            let deltaTime = CGFloat(currentTime - animationStartTime) - FAConfig.AnimationTimeAdjustment
			
            var currentVectorVelocity = [CGFloat]()
            
            for index in 0..<toAnimatableValue.componentCount
            {
                currentVectorVelocity.append(springs![index].velocity(deltaTime))
            }
            
            adjustedVelocity = currentVectorVelocity
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
                
                print("\(newValue) - \(toAnimatableValue) \(newValue.magnitude(toValue: toAnimatableValue))")
                valueArray.append(newValue.valueRepresentation)
                animationTime += frameRateTimeUnit
            }
            else if let newValue = interpolatedSpringValue(animationTime) as? CGColorWrapper,
                    let toAnimatableValue = self.toAnimatableValue
            {
                animationComplete = newValue.magnitude(toValue: toAnimatableValue) < FAConfig.SpringDecayMagnitudeThreshold
                valueArray.append(newValue.valueRepresentation)
                animationTime += frameRateTimeUnit
            }
        }
        while (animationComplete == false)
        
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
