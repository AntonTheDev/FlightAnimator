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
        
        if let cachedAnimationsArray = cachedAnimations,
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
    
    
    public func value(value : Any, forKeyPath key : String) -> PropertyAnimationConfig {
        
        if let value = value as? UIColor {
            animationConfigurations[key] = ConfigurationValue(value: value.CGColor, forKeyPath: key, view : associatedView!, animationKey: animationKey!)
        } else {
            animationConfigurations[key] = ConfigurationValue(value: value, forKeyPath: key, view : associatedView!, animationKey: animationKey!)
        }
    
        return animationConfigurations[key]!
    }
    
    public func alpha(value : CGFloat) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "opacity")
    }
    
    public func anchorPoint(value : CGPoint) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "anchorPoint")
    }
    
    public func backgroundColor(value : CGColor) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "backgroundColor")
    }
    
    public func bounds(value : CGRect) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "bounds")
    }
    
    public func borderColor(value : CGColor) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "borderColor")
    }
    
    public func borderWidth(value : CGFloat) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "borderWidth")
    }

    public func contentsRect(value : CGRect) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "contentsRect")
    }
    
    public func cornerRadius(value : CGPoint) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "cornerRadius")
    }
    
    public func opacity(value : CGFloat) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "opacity")
    }
    
    public func position(value : CGPoint) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "position")
    }
    
    public func shadowColor(value : CGColor) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "shadowColor")
    }
    
    public func shadowOffset(value : CGSize) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "shadowOffset")
    }
    
    public func shadowOpacity(value : CGFloat) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "shadowOpacity")
    }
    
    public func shadowRadius(value : CGFloat) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "shadowRadius")
    }
    
    public func size(value : CGSize) -> PropertyAnimationConfig {
        return bounds(CGRectMake(0, 0, value.width, value.height))
    }
    
    public func sublayerTransform(value : CATransform3D) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "sublayerTransform")
    }
    
    public func transform(value : CATransform3D) -> PropertyAnimationConfig{
        return self.value(value, forKeyPath : "transform")
    }
    
    public func animateZPosition(value : CGFloat) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "animateZPosition")
    }
}

