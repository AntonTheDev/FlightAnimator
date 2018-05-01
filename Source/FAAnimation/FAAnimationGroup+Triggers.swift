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
    open  var isTimedBased = true
    open var triggerProgessValue : CGFloat?
    open var animationKey : NSString?
    open weak var animatedView : UIView?
    open weak var animation : FAAnimationGroup?
    
    required public init() { }
    
    open func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let animationGroup = FAAnimationTrigger()
        animationGroup.isTimedBased         = isTimedBased
        animationGroup.triggerProgessValue  = triggerProgessValue
        animationGroup.animationKey         = animationKey
        animationGroup.animatedView         = animatedView
        animationGroup.animation            = animation
        return animationGroup
    }
}

//MARK: - FAAnimationTrigger Logic

public extension FAAnimationGroup {
    
    /**
     This is the internal definition for creating a trigger
     
     - parameter animation:     the animation or animation group to attach
     - parameter view:          the view to attach it to
     - parameter timeProgress:  the relative time progress to trigger animation on the view
     - parameter valueProgress: the relative value progress to trigger animation on the view
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
     Starts a timer
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
     Stops the timer
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
     Triggers an animation if the value or time progress is met
     */
    @objc func updateTrigger() {
        
        for segment in animationTriggerArray
        {
            if let triggerSegment = self.activeTriggerSegment(segment)
            {
                if DebugTriggerLogEnabled {  print("TRIGGER ++ KEY \(segment.animationKey!)  -  CALINK  \(String(describing: displayLink))\n") }
                
                triggerSegment.animatedView?.applyAnimation(forKey: triggerSegment.animationKey! as String)
                
                animationTriggerArray.fa_removeObject(triggerSegment)
            }
            
            if animationTriggerArray.count <= 0 && autoreverse == false
            {
                stopTriggerTimer()
                return
            }
        }
    }
    
    func activeTriggerSegment(_ segment : FAAnimationTrigger) -> FAAnimationTrigger?
    {
        if segment.isTimedBased
        {
            if primaryAnimation?.timeProgress() >= segment.triggerProgessValue!
            {
                return segment
            }
        }
        else if primaryAnimation?.valueProgress() >= segment.triggerProgessValue!
        {
            return segment
        }

        return nil
    }
}
