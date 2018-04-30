//
//  FAAnimationGroup.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

/**
 Equatable FAAnimationGroup Implementation
 */
func ==(lhs:FAAnimationGroup, rhs:FAAnimationGroup) -> Bool {
    return lhs.animatingLayer == rhs.animatingLayer &&
        lhs.animationKey == rhs.animationKey
}

//MARK: - FASynchronizedGroup

open class FAAnimationGroup : CAAnimationGroup {
    
    internal var animationKey : String?
	
	internal weak var animatingLayer : CALayer? {
		didSet {
			startTime = animatingLayer?.convertTime(CACurrentMediaTime(), from: nil)
			updateAnimatingStartTime()
		}
	}

    // The start time of the animation, set by the current time of
    // the layer when it is added. Used by the springs to find the
    // current velocity in motion
    internal var startTime : CFTimeInterval?
	
    internal weak var primaryAnimation : FABasicAnimation?
	internal var primaryTimingPriority : FAPrimaryTimingPriority = .maxTime
	
    internal var displayLink 		   : CADisplayLink?
	
	internal var _animationTriggerArray = [AnimationTrigger]()
    internal var animationTriggerArray  = [AnimationTrigger]()
	
	/**
	Enable Autoreverse of the animation.
	
	By default it will only auto revese once.
	Adjust the autoreverseCount to change that
	
	*/
	internal var autoreverse 			: Bool = false
	
	/**
	Count of times to repeat the reverse animation
	
	Default is 1, set to 0 repeats the animation
	indefinitely until is removed manually from the layer.
	*/
	internal var autoreverseCount		: Int = 1
	
	/**
	Delay in seconds to perfrom reverse animation.
	
	Once the animation completes this delay adjusts the
	pause prior to triggering the reverse animation
	
	Default is 0.0
	*/
	internal var autoreverseDelay		: TimeInterval = 1.0
	
	/**
	This is a state flag that tells the animation
	that the reverse values have been configured
	so that it does not just happen for no reason.
	
	If the reverse animation is enabled, this will
	be set to true, once the reverse value array
	has been created
	
	Default is false
	*/
	internal var autoreverseConfigured	: Bool = false
	
	/**
	Enables the reverse easing when animating in reverse.
	
	Once the animation completes this will flip the
	easing curve on the animation prior to triggering
	the reverse animation
	
	Default is false
	*/
	internal var reverseEasingCurve		: Bool = false
	
	/**
	Tracks the active cound of the reverse animation
	*/
	internal var autoreverseActiveCount	: Int = 1

    override public init()
	{
        super.init()
        animations = [CAAnimation]()
        fillMode = kCAFillModeForwards
        isRemovedOnCompletion = true
    }
    
    required public init?(coder aDecoder: NSCoder)
	{
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
	{
        displayLink?.invalidate()
    }
    
    override open func copy(with zone: NSZone?) -> Any
	{
        let animationGroup = super.copy(with: zone) as! FAAnimationGroup
		
		animationGroup.animatingLayer           = animatingLayer
        animationGroup.startTime                = startTime
        animationGroup.animationKey             = animationKey
        animationGroup.animationTriggerArray    = animationTriggerArray
        animationGroup.primaryAnimation         = primaryAnimation
        animationGroup.displayLink              = displayLink
        animationGroup._animationTriggerArray   = _animationTriggerArray
        animationGroup.primaryTimingPriority    = primaryTimingPriority
        animationGroup.autoreverse              = autoreverse
        animationGroup.autoreverseCount         = autoreverseCount
        animationGroup.autoreverseActiveCount   = autoreverseActiveCount
        animationGroup.autoreverseConfigured    = autoreverseConfigured
        animationGroup.autoreverseDelay         = autoreverseDelay
        animationGroup.reverseEasingCurve       = reverseEasingCurve
		
		return animationGroup
    }
    
    final public func configureAnimationGroup(withLayer layer: CALayer?, animationKey key: String?) {
        animationKey = key
        animatingLayer = layer
    }
	
	fileprivate func updateAnimatingStartTime()
	{
		if let currentAnimations = animations
		{
			for animation in currentAnimations
			{
				if let customAnimation = animation as? FABasicAnimation
				{
					customAnimation.startTime = startTime
					customAnimation.animatingLayer = animatingLayer
				}
			}
		}
	}
	
	/**
	Attaches the specified animation, on the specified view, and relative
	the progress value type defined in the method call
	
	Ommit both timeProgress and valueProgress, to trigger the animation specified
	at the start of the calling animation group
	
	Ommit timeProgress, to trigger the animation specified
	at the relative time progress of the calling animation group
	
	Ommit valueProgress, to trigger the animation specified
	at the relative value progress of the calling animation group
	
	If both valueProgres, and timeProgress values are defined,
	it will trigger the animation specified at the relative time
	progress of the calling animation group
	
	- parameter animation:     the animation or animation group to attach
	- parameter view:          the view to attach it to
	- parameter timeProgress:  the relative time progress to trigger animation on the view
	- parameter valueProgress: the relative value progress to trigger animation on the view
	*/
	open func triggerAnimation(_ animation : AnyObject,
							   onView view : UIView,
							   atTimeProgress timeProgress: CGFloat? = nil,
							   atValueProgress valueProgress: CGFloat? = nil) {
		
		configureAnimationTrigger(animation,
								  onView : view,
								  atTimeProgress : timeProgress,
								  atValueProgress : valueProgress)
	}
	
	
	/**
	Apply the animation's final state, animated by default but can ve disabled if needed
	
	This method runs through the animations within the current group and applies
	the final values to the underlying layer.
	
	- parameter animated: disables animation, defauls to true
	*/
	open func applyFinalState(_ animated : Bool = false)
	{
		if let animationLayer = animatingLayer
		{
			if animated
			{
				animationLayer.speed = 1.0
				animationLayer.timeOffset = 0.0
				
				if let animationKey = animationKey
				{
					startTime = animationLayer.convertTime(CACurrentMediaTime(), from: nil)
					animationLayer.add(self, forKey: animationKey)
				}
			}
			
			if let subAnimations = animations
			{
				for animation in subAnimations
				{
					if let subAnimation = animation as? FABasicAnimation,
						let toValue = subAnimation.toValue
					{
						//TODO: Figure out why the opacity is not reflected on the UIView
						//All properties work correctly, but to ensure that the opacity is reflected
						//I am setting the alpha on the UIView itsel ?? WTF
						if subAnimation.keyPath! == "opacity"
						{
							animationLayer.owningView()!.setValue(toValue, forKeyPath: "alpha")
						}
						else
						{
							animationLayer.setValue(toValue, forKeyPath: subAnimation.keyPath!)
						}
					}
				}
			}
		}
	}
	
	/**
	Not Ready for Prime Time, being declared as private
	
	Adjusts animation based on the progress form 0 - 1
	
	- parameter progress: scrub "to progress" value
	*/
	fileprivate func scrubToProgress(_ progress : CGFloat)
	{
		animatingLayer?.speed = 0.0
		animatingLayer?.timeOffset = CFTimeInterval(duration * Double(progress))
	}
}


//MARK: - Synchronization Logic

internal extension FAAnimationGroup
{
	
	final internal func synchronizeAnimationGroup(withLayer layer: CALayer, animationKey key: String?) {
		
		configureAnimationGroup(withLayer: layer, animationKey: key)
		
		if let keys = animatingLayer?.animationKeys()
		{
			for key in Array(Set(keys))
			{
				if let oldAnimation = animatingLayer?.animation(forKey: key) as? FAAnimationGroup
				{
					oldAnimation.stopTriggerTimer()
					
					autoreverseActiveCount = oldAnimation.autoreverseActiveCount
					
					synchronizeAnimations(oldAnimation)
					
					startTriggerTimer()
				}
			}
		}
		else
		{
			synchronizeAnimations(nil)
			startTriggerTimer()
		}
	}
	
    /**
     Synchronizes the calling animation group with the passed animation group
     
     - parameter oldAnimationGroup: old animation in flight
     */

    internal func synchronizeAnimations(_ oldAnimationGroup : FAAnimationGroup? = nil) {
        
        var oldAnimations = animationDictionaryForGroup(oldAnimationGroup)
        var newAnimations = animationDictionaryForGroup(self)
        
        for key in newAnimations.keys {
            
            newAnimations[key]!.animatingLayer = animatingLayer
            
            if let oldAnimation = oldAnimations[key]
			{
                newAnimations[key]!.synchronize(relativeTo: oldAnimation)
            }
			else
			{
                newAnimations[key]!.synchronize(relativeTo: nil)
            }
        }
        
        var primaryAnimations = newAnimations.filter({ $0.1.isPrimary == true })
        let hasPrimaryAnimations : Bool = (primaryAnimations.count > 0)
        
        if primaryAnimations.count == 0
		{
             primaryAnimations = newAnimations //newAnimations.filter({ $0.1 != nil })
        }
        
        let durationsArray = primaryAnimations.map({ $0.1.duration})
        
        switch primaryTimingPriority {
        case .maxTime:
            duration = durationsArray.max()!
        case .minTime:
            duration = durationsArray.min()!
        case .median:
            duration = durationsArray.sorted(by: <)[durationsArray.count / 2]
        case .average:
            duration = durationsArray.reduce(0, +) / Double(durationsArray.count)
        }
        
        let nonSynchronizedAnimations = newAnimations.filter({ $0.1.duration != duration })
        
        if hasPrimaryAnimations {
            primaryAnimation = (primaryAnimations.filter({ $0.1.duration == duration})).first?.1
        } else {
            primaryAnimation = (newAnimations.filter({ $0.1.duration == duration})).first?.1
        }
        
        for animation in nonSynchronizedAnimations {
            if animation.1.keyPath != primaryAnimation?.keyPath &&
                animation.1.duration > primaryAnimation?.duration {
                
                
                newAnimations[animation.1.keyPath!]!.duration = duration
                newAnimations[animation.1.keyPath!]!.synchronize()
            }
        }
        
        animations = newAnimations.map {$1}
    }

    func animationDictionaryForGroup(_ animationGroup : FAAnimationGroup?) -> [String : FABasicAnimation] {
        var animationDictionary = [String: FABasicAnimation]()
        
        if let group = animationGroup {
            if let currentAnimations = group.animations {
                for animation in currentAnimations {
                    if let customAnimation = animation as? FABasicAnimation {
                        animationDictionary[customAnimation.keyPath!] = customAnimation
                    }
                }
            }
        }
        
        return animationDictionary
    }
}

//MARK: - Auto Reverse Logic

internal extension FAAnimationGroup {
	
	func configureAutoreverseIfNeeded() {
		
		if autoreverse {
			
			if autoreverseConfigured == false {
				configuredAutoreverseGroup()
			}
			
			if autoreverseCount == 0 {
				return
			}
			
			if autoreverseActiveCount >= (autoreverseCount * 2) {
				clearAutoreverseGroup()
				return
			}
			
			autoreverseActiveCount = autoreverseActiveCount + 1
		}
	}
	
	func configuredAutoreverseGroup() {
		
		let animationGroup = FAAnimationGroup()
		animationGroup.animationKey             = animationKey! + "REVERSE"
		animationGroup.animatingLayer                = animatingLayer
		animationGroup.animations               = reverseAnimationArray()
		animationGroup.duration                 = duration
		animationGroup.primaryTimingPriority    = primaryTimingPriority
		animationGroup.autoreverse             = autoreverse
		animationGroup.autoreverseCount        = autoreverseCount
		animationGroup.autoreverseActiveCount  = autoreverseActiveCount
		animationGroup.reverseEasingCurve      = reverseEasingCurve
		
		if let view =  animatingLayer?.owningView() {
			let progressDelay = max(0.0 , autoreverseDelay/duration)
			configureAnimationTrigger(animationGroup, onView: view, atTimeProgress : 1.0 + CGFloat(progressDelay))
		}
		
		isRemovedOnCompletion = false
	}
	
	func clearAutoreverseGroup() {
		_animationTriggerArray = [AnimationTrigger]()
		isRemovedOnCompletion = true
		stopTriggerTimer()
	}
	
	func reverseAnimationArray() ->[FABasicAnimation] {
		
		var reverseAnimationArray = [FABasicAnimation]()
		
		if let animations = self.animations {
			for animation in animations {
				if let customAnimation = animation as? FABasicAnimation {
					
					let newAnimation = FABasicAnimation(keyPath: customAnimation.keyPath)
					newAnimation.easingFunction = reverseEasingCurve ? customAnimation.easingFunction.reverseEasing() : customAnimation.easingFunction
					
					newAnimation.isPrimary = customAnimation.isPrimary
					newAnimation.values = customAnimation.values!.reversed()
					newAnimation.toValue = customAnimation.fromValue
					newAnimation.fromValue = customAnimation.toValue
					
					reverseAnimationArray.append(newAnimation)
				}
			}
		}
		
		return reverseAnimationArray
	}
}


//MARK: - AnimationTrigger

public func ==(lhs:AnimationTrigger, rhs:AnimationTrigger) -> Bool {
    return lhs.animatedView == rhs.animatedView &&
        lhs.isTimedBased == rhs.isTimedBased &&
        lhs.triggerProgessValue == rhs.triggerProgessValue &&
        lhs.animationKey == rhs.animationKey
}


open class AnimationTrigger : Equatable {
    open  var isTimedBased = true
    open var triggerProgessValue : CGFloat?
    open var animationKey : NSString?
    open weak var animatedView : UIView?
    open weak var animation : FAAnimationGroup?
    
    required public init() {
        
    }

    open func copyWithZone(_ zone: NSZone?) -> AnyObject {
        let animationGroup = AnimationTrigger()
        animationGroup.isTimedBased         = isTimedBased
        animationGroup.triggerProgessValue  = triggerProgessValue
        animationGroup.animationKey         = animationKey
        animationGroup.animatedView         = animatedView
        animationGroup.animation            = animation
        return animationGroup
    }
}

//MARK: - AnimationTrigger Logic

public extension FAAnimationGroup {
    
    /**
     This is the internal definition for creating a trigger
     
     - parameter animation:     the animation or animation group to attach
     - parameter view:          the view to attach it to
     - parameter timeProgress:  the relative time progress to trigger animation on the view
     - parameter valueProgress: the relative value progress to trigger animation on the view
     */
    internal func configureAnimationTrigger(_ animation : AnyObject,
                                            onView view : UIView,
                                            atTimeProgress timeProgress: CGFloat? = 0.0,
                                            atValueProgress valueProgress: CGFloat? = nil)
    {
        var progress : CGFloat = timeProgress ?? 0.0
        var timeBased : Bool = true
        
        if valueProgress != nil {
            progress = valueProgress!
            timeBased = false
        }
        
        var animationGroup : FAAnimationGroup?
        
        if let group = animation as? FAAnimationGroup {
            animationGroup = group
        } else if let animation = animation as? FABasicAnimation {
            animationGroup = FAAnimationGroup()
            animationGroup!.animations = [animation]
        }
        
        guard animationGroup != nil else {
            return
        }
        
        animationGroup?.animationKey = String(UUID().uuidString)
        animationGroup?.animatingLayer = view.layer
        
        let animationTrigger = AnimationTrigger()
        animationTrigger.isTimedBased = timeBased
        animationTrigger.triggerProgessValue = progress
        animationTrigger.animationKey = animationGroup?.animationKey as NSString?
        animationTrigger.animatedView = view
        
        _animationTriggerArray.append(animationTrigger)
        view.appendAnimation(animationGroup!, forKey: animationGroup!.animationKey!)
    }
    
    
    /**
     Starts a timer
     */
    func startTriggerTimer() {
        
        guard displayLink == nil && _animationTriggerArray.count > 0 else {
            return
        }
        
        animationTriggerArray = _animationTriggerArray
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(FAAnimationGroup.updateTrigger))
        if DebugTriggerLogEnabled {  print("START ++++++++ KEY \(String(describing: animationKey))  -  CALINK  \(String(describing: displayLink))\n") }
        
        self.displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        updateTrigger()
    }
    
    
    /**
     Stops the timer
     */
    func stopTriggerTimer() {
        
        guard let displayLink = displayLink else {
            return
        }

        animationTriggerArray = [AnimationTrigger]()
        displayLink.invalidate()
        if DebugTriggerLogEnabled { print("STOP ++++++++ KEY \(String(describing: animationKey))  -  CALINK  \(displayLink)\n") }

        self.displayLink = nil
    }
    
    
    /**
     Triggers an animation if the value or time progress is met
     */
    @objc func updateTrigger() {
        
        for segment in animationTriggerArray
        {
            if let triggerSegment = self.activeTriggerSegment(segment)
            {
                if DebugTriggerLogEnabled {  print("TRIGGER ++++++++ KEY \(segment.animationKey!)  -  CALINK  \(String(describing: displayLink))\n") }
            
                triggerSegment.animatedView?.applyAnimation(forKey: triggerSegment.animationKey! as String)
                animationTriggerArray.fa_removeObject(triggerSegment)
            }
            
            if animationTriggerArray.count <= 0 && autoreverse == false {
                stopTriggerTimer()
                return
            }
        }
    }
    
    func activeTriggerSegment(_ segment : AnimationTrigger) -> AnimationTrigger?
	{
        let fireTimeBasedTrigger  = segment.isTimedBased && primaryAnimation?.timeProgress() >= segment.triggerProgessValue!
		
		let fireValueBasedTrigger = segment.isTimedBased == false && primaryAnimation?.valueProgress() >= segment.triggerProgessValue!
        
        if fireTimeBasedTrigger || fireValueBasedTrigger {
            return segment
        }
        
        return nil
    }
}
