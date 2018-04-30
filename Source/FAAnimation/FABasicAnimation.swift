//
//  FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

struct FAAnimationConfig
{
    static let InterpolationFrameCount  : CGFloat = 60.0
    
    static let SpringDecayFrequency     : CGFloat = 15.0
    static let SpringDecayDamping       : CGFloat = 0.97
    static let SpringCustomBounceCount  : Int = 4
    
    static let SpringDecayMagnitudeThreshold  : CGFloat = 0.01
    
    static let AnimationTimeAdjustment   : CGFloat = 2.0 * (1.0 / FAAnimationConfig.InterpolationFrameCount)
}

//MARK: - FABasicAnimation

open class FABasicAnimation : CAKeyframeAnimation
{
    open weak var animatingLayer : CALayer?
    open var easingFunction : FAEasing = .linear
    open var isPrimary      : Bool = false

    open var toValue : AnyObject? {
        didSet {
            if let toValue = toValue as? NSValue {
                toAnimatableValue = toValue.typedValue() as? FAAnimatable
            } else if CFGetTypeID(toValue as AnyObject) == CGColor.typeID {
                toAnimatableValue = toValue as! CGColor
            }
        }
    }
    
    open var fromValue : AnyObject? {
        didSet {
            if let fromValue = fromValue as? NSValue {
                fromAnimatableValue = fromValue.typedValue() as? FAAnimatable
            } else if CFGetTypeID(fromValue as AnyObject) == CGColor.typeID {
                fromAnimatableValue = fromValue as! CGColor
            }
        }
    }
    
    open var previousValue : AnyObject? {
        didSet {
            if let previousValue = previousValue as? NSValue {
                previousAnimatableValue = previousValue.typedValue() as? FAAnimatable
            } else if CFGetTypeID(previousValue as AnyObject) == CGColor.typeID {
                previousAnimatableValue = previousValue as! CGColor
            }
        }
    }
    
    open override var timingFunction: CAMediaTimingFunction? {
        didSet {
            convertTimingFunction()
        }
    }
    
    internal var toAnimatableValue       : FAAnimatable?
    internal var fromAnimatableValue     : FAAnimatable?
    internal var previousAnimatableValue : FAAnimatable?
    
    internal var springs                 : [FASpring]?
    internal var startTime               : CFTimeInterval?
    
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
        guard let valueType = toAnimatableValue?.valueType,
            let animationToValue = toValue,
            let animationLayerValue = animatingLayer?.anyValueForKeyPath(keyPath!),
            let presentationValue = animatingLayer?.presentation()?.anyValueForKeyPath(keyPath!) else
        {
            return
        }
        
        switch valueType {
        case .cgFloat:
            
            if let presentationValue = presentationValue as? CGFloat
            {
                if (animationToValue as! NSNumber).floatValue == Float(presentationValue)
                {
                    fromValue = animationToValue
                }
                else
                {
                    fromValue = NSNumber(value: Float(presentationValue) as Float)
                }
            }
            
        case .cgPoint:
            
            if let presentationValue = presentationValue as? CGPoint
            {
                if animationToValue.cgPointValue.equalTo(presentationValue)
                {
                    fromValue = NSValue(cgPoint : animationLayerValue as! CGPoint)
                }
                else
                {
                    fromValue = NSValue(cgPoint : presentationValue)
                }
            }
            
        case .cgSize:
            
            if let presentationValue = presentationValue as? CGSize
            {
                if animationToValue.cgSizeValue.equalTo(presentationValue)
                {
                    fromValue = NSValue(cgSize : animationLayerValue as! CGSize)
                }
                else
                {
                    fromValue = NSValue(cgSize : presentationValue)
                }
            }
            
        case .cgRect:
            
            if let presentationValue = presentationValue as? CGRect
            {
                if animationToValue.cgRectValue.equalTo(presentationValue)
                {
                    fromValue = NSValue(cgRect : animationLayerValue as! CGRect)
                }
                else
                {
                    fromValue = NSValue(cgRect : presentationValue)
                }
            }
            
        case .cgColor:
            
            if CFGetTypeID(presentationValue as AnyObject) == CGColor.typeID
            {
                fromValue = presentationValue as! CGColor
            }
            
        case .caTransform3d:
            
            if presentationValue is CATransform3D
            {
                if let presentationValue = presentationValue as? CATransform3D
                {
                    fromValue = NSValue(caTransform3D : presentationValue)
                }
                else
                {
                    fromValue = NSValue(caTransform3D : animationLayerValue as! CATransform3D)
                }
            }
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
                                 angularFrequency: FAAnimationConfig.SpringDecayFrequency,
                                 dampingRatio: FAAnimationConfig.SpringDecayDamping)
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
    
    internal func convertTimingFunction()
    {
        print("timingFunction has no effect, converting to 'easingFunction' property\n")
        
        switch timingFunction?.value(forKey: "name") as! String {
        case kCAMediaTimingFunctionEaseIn:
            
            easingFunction = .inCubic
            
        case kCAMediaTimingFunctionEaseOut:
            
            easingFunction = .outCubic
            
        case kCAMediaTimingFunctionEaseInEaseOut:
            
            easingFunction = .inOutCubic
            
        default:
            
            easingFunction = .smoothStep
        }
    }
}


//MARK: - Animation Progress Calculations

internal extension FABasicAnimation {
   
    func valueProgress() -> CGFloat
    {
        guard let presentationValue = animatingLayer?.presentation()?.anyValueForKeyPath(keyPath!) as? NSValue,
            let value = presentationValue.typedValue() as? FAAnimatable,
            let toValue = toAnimatableValue,
            let fromValue = fromAnimatableValue else
        {
            return 0.0
        }
        
        return toValue.valueProgress(fromValue: fromValue, atValue: value)
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
        switch toValue.valueType {
        case .cgFloat:
            
            if let fromValue = fromValue as? CGFloat,
                let toValue  = toValue as? CGFloat {
                return  CGFloat(fromValue).progressValue(to: CGFloat(toValue), atProgress: progress)
            }
            
        case .cgPoint:
            
            if let fromValue  = fromValue as? CGPoint,
                let toValue  = toValue as? CGPoint
            {
                return  fromValue.progressValue(to: toValue, atProgress: progress)
            }
            
        case .cgSize:
            
            if let fromValue  = fromValue as? CGSize,
                let toValue  = toValue as? CGSize
            {
                return  fromValue.progressValue(to: toValue, atProgress: progress)
            }
            
        case .cgRect:
            
            if let fromValue  = fromValue as? CGRect,
                let toValue  = toValue as? CGRect
            {
                return  fromValue.progressValue(to: toValue, atProgress: progress)
            }
            
        case .cgColor:
            
            if CFGetTypeID(fromValue as AnyObject) == CGColor.typeID &&
               CFGetTypeID(toValue as AnyObject) == CGColor.typeID
            {
                return  fromValue.progressValue(to: toValue, atProgress: progress)
            }
            
            return  (fromValue as! CGColor).progressValue(to: (toValue as! CGColor), atProgress: progress)
            
        case .caTransform3d:
            
            if let fromValue  = fromValue as? CATransform3D,
                let toValue  = toValue as? CATransform3D
            {
                return fromValue.progressValue(to: toValue, atProgress: progress)
            }
        }
        
        return CGFloat(0.0)
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
        let frameRateTimeUnit = 1.0 / FAAnimationConfig.InterpolationFrameCount
    
        let firstValue = interpolatedParametricValue(fromValue: fromAnimatableValue,
                                                     toValue: toAnimatableValue,
                                                     atProgress: 0.0)
        
        newArray.append(firstValue.valueRepresentation)
        
        repeat
        {
            animationTime += frameRateTimeUnit
            let progress = easingFunction.parametricProgress(CGFloat(animationTime / duration))
           
            let newValue = interpolatedParametricValue(fromValue: fromAnimatableValue,
                                                       toValue: toAnimatableValue,
                                                       atProgress: progress)
           
            newArray.append(newValue.valueRepresentation)
        }
            while (animationTime <= duration)
        
        newArray.removeLast()
        
        let finalValue = interpolatedParametricValue(fromValue: fromAnimatableValue,
                                                   toValue: toAnimatableValue,
                                                   atProgress: 1.0)

        newArray.append(finalValue.valueRepresentation)
		
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

    internal func adjustedVelocityEasing(_ easingFunction : FAEasing, relativeTo animation : FABasicAnimation?) -> FAEasing
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
            let deltaTime = CGFloat(currentTime - animationStartTime) - FAAnimationConfig.AnimationTimeAdjustment
            
            
            var progressComponents = [CGFloat]()
            
            for index in 0..<toAnimatableValue.componentCount
            {
                progressComponents.append(springs![index].velocity(deltaTime))
            }
            
            adjustedVelocity = toAnimatableValue.valueFromComponents(progressComponents)//  self.adjustedVelocity(at : deltaTime)
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
        let frameRateTimeUnit = 1.0 / FAAnimationConfig.InterpolationFrameCount
        
        var animationComplete = false
        
        repeat {
            
            if  let newObjectValue = interpolatedSpringValue(animationTime) as? NSValue,
                let newValue = newObjectValue.typedValue() as? FAAnimatable,
                let toAnimatableValue = self.toAnimatableValue
            {
                animationComplete = newValue.magnitude(toValue: toAnimatableValue) < FAAnimationConfig.SpringDecayMagnitudeThreshold
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
        let frameRateTimeUnit = 1.0 / FAAnimationConfig.InterpolationFrameCount
        
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
            
            animationTime += frameRateTimeUnit
            
        } while (bounceCount < FAAnimationConfig.SpringCustomBounceCount)
        
        
        valueArray.append(toAnimatableValue.valueRepresentation as AnyObject)
        animationTime += frameRateTimeUnit
        
        return (duration : Double(animationTime), values : valueArray)
    }
}
