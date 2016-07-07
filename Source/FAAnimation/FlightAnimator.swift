//
//  UIView+FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

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

public func registerAnimation(onView view : UIView,
                              forKey key: String,
                              timingPriority : FAPrimaryTimingPriority = .MaxTime,
                              @noescape animator : (animator : FlightAnimator) -> Void ) {
    
    let newAnimator = FlightAnimator(withView: view, forKey : key, priority : timingPriority)
    animator(animator : newAnimator)
}

public extension UIView {
    
    func animate(timingPriority : FAPrimaryTimingPriority = .MaxTime, @noescape animator : (animator : FlightAnimator) -> Void ) {
        let newAnimator = FlightAnimator(withView: self, forKey : "AppliedAnimation",  priority : timingPriority)
        animator(animator : newAnimator)
        applyAnimation(forKey: "AppliedAnimation")
    }

    func applyAnimation(forKey key: String,
                        animated : Bool = true) {
        
        if let cachedAnimationsArray = self.cachedAnimations,
            let animation = cachedAnimationsArray[key] {
            animation.applyFinalState(animated)
        }
    }
    
    func applyAnimationTree(forKey key: String,
                            animated : Bool = true) {
        
        applyAnimation(forKey : key, animated:  animated)
        applyAnimationsToSubViews(self, forKey: key, animated: animated)
    }
}

public class FlightAnimator : FAAnimationMaker {
    
    public func setDidStopCallback(stopCallback : FAAnimationDidStop) {
        if ((associatedView?.cachedAnimations?.keys.contains(animationKey!)) != nil) {
             associatedView!.cachedAnimations![animationKey!]!.setDidStopCallback(stopCallback)
        }
    }
    
    public func setDidStartCallback(startCallback : FAAnimationDidStart) {
        if ((associatedView?.cachedAnimations?.keys.contains(animationKey!)) != nil) {
            associatedView!.cachedAnimations![animationKey!]!.setDidStartCallback(startCallback)
        }
    }
    
    public func triggerOnStart(timingPriority : FAPrimaryTimingPriority = .MaxTime,
                               onView view: UIView,
                               @noescape animator: (animator : FlightAnimator) -> Void) {
        triggerAnimation(timingPriority, timeBased : true, key: animationKey!, view: view, progress: 0.0, animator: animator)
    }
    
    public func triggerAtTimeProgress(timingPriority : FAPrimaryTimingPriority = .MaxTime,
                                      atProgress progress: CGFloat,
                                      onView view: UIView,
                                      @noescape animator: (animator : FlightAnimator) -> Void) {
        triggerAnimation(timingPriority, timeBased : true, key: animationKey!, view: view, progress: progress, animator: animator)
    }
    
    public func triggerAtValueProgress(timingPriority : FAPrimaryTimingPriority = .MaxTime,
                                       atProgress progress: CGFloat,
                                       onView view: UIView,
                                       @noescape animator: (animator : FlightAnimator) -> Void) {
        triggerAnimation(timingPriority, timeBased : false, key: animationKey!, view: view, progress: progress, animator: animator)
    }
    
    
    public func value<T : FAAnimatable>(value : T, forKeyPath key : String) -> PropertyConfiguration {
        animationConfigurations[key] = ConfigurationValue(value: value, forKeyPath: key, view : associatedView!, animationKey: animationKey!)
        return animationConfigurations[key]!
    }
    
    public func alpha(value : CGFloat) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "opacity")
    }
    
    public func anchorPoint<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "anchorPoint")
    }
    
    public func bounds<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "bounds")
    }
    
    public func borderWidth<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "borderWidth")
    }
    
    public func contentsRect<T : FAAnimatable>(value : T) -> PropertyConfiguration{
        return self.value(value, forKeyPath : "contentsRect")
    }
    
    public func cornerRadius<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "cornerRadius")
    }
    
    public func opacity<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "opacity")
    }
    
    public func position<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "position")
    }
    
    public func shadowOffset<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "shadowOffset")
    }
    
    public func shadowOpacity<T : FAAnimatable>(value : T) -> PropertyConfiguration{
        return self.value(value, forKeyPath : "shadowOpacity")
    }
    
    public func shadowRadius<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "shadowRadius")
    }
    
    public func size<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return bounds(CGRectMake(0, 0, (value as? CGSize)!.width, (value as? CGSize)!.height))
    }
    
    public func sublayerTransform<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "sublayerTransform")
    }
    
    public func transform<T : FAAnimatable>(value : T) -> PropertyConfiguration{
        return self.value(value, forKeyPath : "transform")
    }
    
    public func animateZPosition<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "animateZPosition")
    }
}

