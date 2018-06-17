//
//  FAAnimationGroup+Triggers.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 4/30/18.
//  Copyright © 2018 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public func ==(lhs:FAAnimationTrigger, rhs:FAAnimationTrigger) -> Bool
{
    return lhs.animatedView == rhs.animatedView &&
           lhs.isTimedBased == rhs.isTimedBased &&
           lhs.triggerProgessValue == rhs.triggerProgessValue &&
           lhs.animationKey == rhs.animationKey
}

open class FAAnimationTrigger : Equatable
{
    open var animationKey : NSString?                   // Copied
    
    open weak var animatedView : UIView?                // Copied
    
    open weak var animation : FAAnimationGroup?         // Copied
    
    open var isTimedBased = true                        // Copied
    
    open var triggerProgessValue : CGFloat?             // Copied
    
    required public init() { }
    
    open func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let animationGroup = FAAnimationTrigger()

        animationGroup.animationKey         = animationKey
        animationGroup.animatedView         = animatedView
        animationGroup.animation            = animation
        animationGroup.isTimedBased         = isTimedBased
        animationGroup.triggerProgessValue  = triggerProgessValue
       
        return animationGroup
    }
    
    func applyAnimation()
    {
        if let animationKey = animationKey
        {
            animatedView?.applyAnimation(forKey: animationKey as String)
        }
    }
    
    func didTriggerAnimation(relativeTo primaryAnimation : FABasicAnimation?) -> Bool
    {
            if isTimedBased
            {
                if primaryAnimation?.timeProgress() >= triggerProgessValue!
                {
                    applyAnimation()
                    
                    return true
                }
            }
            else if primaryAnimation?.valueProgress() >= triggerProgessValue!
            {
                applyAnimation()
                
                return true
            }
            
            return false
    }
}


//MARK: - FAAnimationTrigger Logic
public extension FAAnimationGroup
{
    /**
     *
     * This is the internal definition for creating a trigger
     *
     * - parameter animation:     the animation or animation group to attach
     * - parameter view:          the view to attach it to
     * - parameter timeProgress:  the relative time progress to trigger animation
     * - parameter valueProgress: the relative value progress to trigger animation
     *
     */
    internal func configureFAAnimationTrigger(_ animation : AnyObject,
                                              onView view : UIView,
                                              atTimeProgress timeProgress: CGFloat? = 0.0,
                                              atValueProgress valueProgress: CGFloat? = nil)
    {
        var progress : CGFloat = timeProgress ?? 0.0
        var timeBased : Bool = true
        
        if valueProgress != nil
        {
            progress = valueProgress!
            timeBased = false
        }
        
        var animationGroup : FAAnimationGroup?
        
        if let group = animation as? FAAnimationGroup
        {
            animationGroup = group
        }
        else if let animation = animation as? FABasicAnimation
        {
            animationGroup = FAAnimationGroup()
            animationGroup!.animations = [animation]
        }
        
        guard animationGroup != nil else
        {
            return
        }
        
        animationGroup?.animationKey = String(UUID().uuidString)
        animationGroup?.animatingLayer = view.layer
        
        let animationTrigger = FAAnimationTrigger()
        
        animationTrigger.isTimedBased = timeBased
        animationTrigger.triggerProgessValue = progress
        animationTrigger.animationKey = animationGroup?.animationKey as NSString?
        animationTrigger.animatedView = view
        
        _animationTriggerArray.append(animationTrigger)
        
        view.appendAnimation(animationGroup!, forKey: animationGroup!.animationKey!)
    }
    
    
    /**
     *
     * Starts a trigger timer associated with the animation
     *
     */
    func startTriggerTimer()
    {
        guard displayLink == nil && _animationTriggerArray.count > 0 else
        {
            return
        }
        
        animationTriggerArray = _animationTriggerArray
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(FAAnimationGroup.updateTrigger))
        
        if DebugTriggerLogEnabled {  print("START ++++++++ KEY \(String(describing: animationKey))  -  CALINK  \(String(describing: displayLink))\n") }
        
        self.displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        
        updateTrigger()
    }
    
    
    /**
     *
     * Stops a trigger timer associated with the animation
     *
     */
    func stopTriggerTimer() {
        
        guard let displayLink = displayLink else
        {
            return
        }
        
        animationTriggerArray = [FAAnimationTrigger]()
        
        displayLink.invalidate()
        
        if DebugTriggerLogEnabled { print("STOP ++ KEY \(String(describing: animationKey))  -  CALINK  \(displayLink)\n") }
        
        self.displayLink = nil
    }
    
    
    /**
     *
     * Triggers an animation if the value or time progress is met
     *
     */
    @objc func updateTrigger()
    {
        for trigger in animationTriggerArray
        {
            if trigger.didTriggerAnimation(relativeTo: primaryAnimation)
            {
                if DebugTriggerLogEnabled {  print("TRIGGER ++ KEY \(trigger.animationKey!)  -  CALINK  \(String(describing: displayLink))\n") }
                
                animationTriggerArray.fa_removeObject(trigger)
            }
            
            if animationTriggerArray.count <= 0 && autoreverse == false
            {
                stopTriggerTimer()
                return
            }
        }
    }
}
