//
//  FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit


//MARK: - FASynchronizedAnimation

public class FABasicAnimation : FASynchronizedAnimation {

    override public init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Final animation value to interpolate to
    public var toValue: AnyObject? {
        get { return _toValue }
        set { _toValue = newValue }
    }
    
    // Final animation value to interpolate to
    public var fromValue: AnyObject? {
        get { return _fromValue }
        set { _fromValue = newValue }
    }

    // The easing funtion applied to the duration of the animation
    public var easingFunction : FAEasing  {
        get { return _easingFunction }
        set { _easingFunction = newValue }
    }
    
    // Flag used to track the animation as a primary influencer 
    // for the overall timing within an animation group.
    public var isPrimary : Bool {
        get { return (easingFunction.isSpring() || _isPrimary) }
        set { _isPrimary = newValue }
    }
    
    /**
     Enable Autoreverse of the animation.
     
     By default it will only auto revese once.
     Adjust the autoreverseCount to change that
     
     */
    public var autoreverse: Bool {
        get { return _autoreverse }
        set { _autoreverse = newValue }
    }
    
    
    /**
     Count of times to repeat the reverse animation
     
     Default is 1, set to 0 repeats the animation
     indefinitely until is removed manually from the layer.
     */
    public var autoreverseCount: Int {
        get { return _autoreverseCount }
        set { _autoreverseCount = newValue }
    }
    
    
    /**
     Delay in seconds to perfrom reverse animation.
     
     Once the animation completes this delay adjusts the
     pause prior to triggering the reverse animation
     
     Default is 0.0
     */
    public var autoreverseDelay: NSTimeInterval {
        get { return _autoreverseDelay }
        set { _autoreverseDelay = newValue }
    }
    
    
    /**
     Delay in seconds to perfrom reverse animation.
     
     Once the animation completes this delay adjusts the
     pause prior to triggering the reverse animation
     
     Default is 0.0
     */
    public var reverseEasingCurve: Bool {
        get { return _reverseEasingCurve }
        set { _reverseEasingCurve = newValue }
    }
    
    
    /**
     Not Ready for Prime Time, being declared as private
     
     Adjusts animation based on the progress form 0 - 1
     
     - parameter progress: scrub "to progress" value
     */
    private func scrubToProgress(progress : CGFloat) {
        weakLayer?.speed = 0.0
        weakLayer?.timeOffset = CFTimeInterval(duration * Double(progress))
    }
}


//MARK: - FASynchronizedAnimation

public class FASynchronizedAnimation : CAKeyframeAnimation {

    //Auto synchronizes with current presentation layer values if left blank
    internal var _fromValue: AnyObject?
    internal var _toValue: AnyObject?
    internal var _easingFunction : FAEasing = FAEasing.Linear
    internal var _isPrimary : Bool = false
    
    internal weak var weakLayer : CALayer?
    internal var interpolator : Interpolator?
    internal var startTime : CFTimeInterval?
    
    internal var _autoreverse : Bool = false
    internal var _autoreverseCount: Int = 1
    internal var _autoreverseActiveCount: Int = 1
    internal var _autoreverseDelay: NSTimeInterval = 1.0
    internal var _autoreverseConfigured: Bool = false
    internal var _reverseEasingCurve: Bool = false
    
    override public var timingFunction: CAMediaTimingFunction? {
        didSet {
            print("WARMING: FlightAnimator\n Setting timingFunction on an FABasicAnimation has no effect, use the 'easingFunction' property instead\n")
        }
    }
    
    override public init() {
        super.init()
        initializeInitialValues()
    }

    public convenience init(keyPath path: String?) {
        self.init()
        keyPath = path
        initializeInitialValues()
    }
    
    internal func initializeInitialValues() {
        CALayer.swizzleAddAnimation()
        
        calculationMode = kCAAnimationLinear
        fillMode = kCAFillModeForwards
        removedOnCompletion = true
        values = [AnyObject]()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        let animation = super.copyWithZone(zone) as! FABasicAnimation
        animation.weakLayer             = weakLayer
        animation.startTime             = startTime
        animation.interpolator          = interpolator
        animation._easingFunction       = _easingFunction
        animation._toValue              = _toValue
        animation._fromValue            = _fromValue
        animation._isPrimary            = _isPrimary
        
        animation._autoreverse             = _autoreverse
        animation._autoreverseCount        = _autoreverseCount
        animation._autoreverseActiveCount  = _autoreverseActiveCount
        animation._autoreverseConfigured   = _autoreverseConfigured
        animation._autoreverseDelay        = _autoreverseDelay
        animation._reverseEasingCurve      = _reverseEasingCurve
        
        return animation
    }
    
    final public func groupRepresentation() -> FAAnimationGroup {
        let newAnimationGroup = FAAnimationGroup()
        
        newAnimationGroup.weakLayer             = weakLayer
        newAnimationGroup.startTime             = startTime
      
        newAnimationGroup._autoreverse             = _autoreverse
        newAnimationGroup._autoreverseCount        = _autoreverseCount
        newAnimationGroup._autoreverseActiveCount  = _autoreverseActiveCount
        newAnimationGroup._autoreverseConfigured   = _autoreverseConfigured
        newAnimationGroup._autoreverseDelay        = _autoreverseDelay
        newAnimationGroup._reverseEasingCurve      = _reverseEasingCurve
        
        newAnimationGroup.animations = [self]
        
        return newAnimationGroup
    }
    
    final public func configureAnimation(withLayer layer: CALayer?) {
        weakLayer = layer
    }
}

//MARK: - Synchronization Logic

internal extension FASynchronizedAnimation {
    
    func synchronize(runningAnimation animation : FABasicAnimation? = nil) {
        configureValues(animation)
    }
    
    func synchronizeAnimationVelocity(fromValue : Any, runningAnimation : FABasicAnimation?) {
        
        if  let presentationLayer = runningAnimation?.weakLayer?.presentationLayer(),
            let animationStartTime = runningAnimation?.startTime,
            let oldInterpolator = runningAnimation?.interpolator {
            
            let currentTime = presentationLayer.convertTime(CACurrentMediaTime(), toLayer: runningAnimation!.weakLayer)
            let deltaTime = CGFloat(currentTime - animationStartTime) - FAAnimationConfig.AnimationTimeAdjustment
            
            if _easingFunction.isSpring() {
                _easingFunction = oldInterpolator.adjustedEasingVelocity(deltaTime, easingFunction: _easingFunction)
            }
            
        } else {
            switch _easingFunction {
            case .SpringDecay(_):
                _easingFunction =  FAEasing.SpringDecay(velocity: interpolator?.zeroVelocityValue())
                
            case let .SpringCustom(_,frequency,damping):
                _easingFunction = FAEasing.SpringCustom(velocity: interpolator?.zeroVelocityValue() ,
                                                        frequency: frequency,
                                                        ratio: damping)
            default:
                break
            }
        }
    }
    
    func configureValues(runningAnimation : FABasicAnimation? = nil) {
        
        configureFromValueIfNeeded()
        
        synchronizeAnimationVelocity(_fromValue, runningAnimation: runningAnimation)
        
        if let _toValue = _toValue,
            let _fromValue = _fromValue {
            
            interpolator  = Interpolator(toValue: _toValue,
                                         fromValue: _fromValue,
                                         previousValue : runningAnimation?.fromValue)
            
            let config = interpolator?.interpolatedConfiguration(CGFloat(duration), easingFunction: _easingFunction)
            
            duration = config!.duration
            values = config!.values
        }
    }
    
    func configureFromValueIfNeeded() {        
        if let presentationLayer = (weakLayer?.presentationLayer()),
            let presentationValue = presentationLayer.anyValueForKeyPath(keyPath!) {
            
            if let currentValue = presentationValue as? CGPoint {
                _fromValue = NSValue(CGPoint : currentValue)
            } else  if let currentValue = presentationValue as? CGSize {
                _fromValue = NSValue(CGSize : currentValue)
            } else  if let currentValue = presentationValue as? CGRect {
                _fromValue = NSValue(CGRect : currentValue)
            } else  if let currentValue = presentationValue as? CGFloat {
                _fromValue = NSNumber(float : Float(currentValue))
            } else  if let currentValue = presentationValue as? CATransform3D {
                _fromValue = NSValue(CATransform3D : currentValue)
            } else if let currentValue = typeCastCGColor(presentationValue) {
                _fromValue = currentValue
            }
        }
    }
}


//MARK: - Animation Progress Values

internal extension FASynchronizedAnimation {
    
    func valueProgress() -> CGFloat {
        if let presentationValue = (weakLayer?.presentationLayer())?.anyValueForKeyPath(keyPath!) {
            return interpolator!.valueProgress(presentationValue)
        }
        
        return 0.0
    }
    
    func timeProgress() -> CGFloat {
        let currentTime = weakLayer?.presentationLayer()!.convertTime(CACurrentMediaTime(), toLayer: nil)
        let difference = currentTime! - startTime!
        
        return CGFloat(round(100 * (difference / duration))/100)
    }
}
