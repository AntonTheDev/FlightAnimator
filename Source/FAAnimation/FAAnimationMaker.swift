//
//  FlightAnimate+Private.swift
//  
//
//  Created by Anton on 6/29/16.
//
//

import Foundation
import UIKit

internal class AnimationTrigger : Equatable {
    var isTimedBased = true
    var triggerProgessValue : CGFloat?
    var animationKey : NSString?
    weak var animatedView : UIView?
}


public class FAAnimationMaker {
    
    internal weak var associatedView : UIView?
    internal var animationKey : String?
    
    var animationConfigurations = [String : PropertyAnimationConfig]()
    var primaryTimingPriority : FAPrimaryTimingPriority = .MaxTime
    
    init(withView view : UIView, forKey key: String, priority : FAPrimaryTimingPriority = .MaxTime) {
        animationKey = key
        associatedView = view
        primaryTimingPriority = priority
        configureNewGroup()
    }
    
    private func configureNewGroup() {
        
        if associatedView!.cachedAnimations == nil {
            associatedView!.cachedAnimations = [NSString : FAAnimationGroup]()
        }
       
        if associatedView!.cachedAnimations!.keys.contains(NSString(string: animationKey!)) {
            associatedView!.cachedAnimations![NSString(string: animationKey!)]?.stopTriggerTimer()
            associatedView!.cachedAnimations![NSString(string: animationKey!)] = nil
        }
        
       
        let newGroup = FAAnimationGroup()
        newGroup.animationKey = animationKey
        newGroup.weakLayer = associatedView?.layer
        newGroup.primaryTimingPriority = primaryTimingPriority
        
        associatedView!.cachedAnimations![NSString(string: animationKey!)] = newGroup
    }
    
    internal func triggerAnimation(timingPriority : FAPrimaryTimingPriority = .MaxTime,
                                   timeBased : Bool,
                                   key: String,
                                   view: UIView,
                                   progress: CGFloat = 0.0,
                                   @noescape animator: (animator : FlightAnimator) -> Void) {

        if let animationGroup = associatedView!.cachedAnimations![NSString(string: animationKey!)] {
            
            let animationTrigger = AnimationTrigger()
            animationTrigger.isTimedBased = timeBased
            animationTrigger.triggerProgessValue = progress
            animationTrigger.animationKey = animationKey!
            animationTrigger.animatedView = view
            
            animationGroup._segmentArray.append(animationTrigger)

            associatedView!.appendAnimation(animationGroup, forKey: animationKey!)
        }
        
        let newAnimator = FlightAnimator(withView: view, forKey : animationKey!, priority : timingPriority)
        animator(animator : newAnimator)
    }
}

public class PropertyAnimationConfig  {
    
    private weak var associatedView : UIView?
    private var animationKey : String?
    private var keyPath : String?
    
    var toValue : Any
    var easingCurve : FAEasing = .Linear
    var duration : CGFloat
    var primary : Bool
    
    init(value: Any, forKeyPath key : String, view : UIView, animationKey : String) {
        self.animationKey = animationKey
        associatedView = view
        keyPath = key
        toValue = value
        easingCurve = .Linear
        duration = 0.0
        primary = false
    }
    
    deinit {
        associatedView = nil
        //print ("DEINIT PropertyAnimationConfig")
    }
    
    public func duration(duration : CGFloat) -> PropertyAnimationConfig {
        self.duration = duration
        updateAnimation()
        return self
    }
    
    public func easing(easing : FAEasing) -> PropertyAnimationConfig {
        self.easingCurve = easing
        updateAnimation()
        return self
    }
    
    public func primary(primary : Bool) -> PropertyAnimationConfig {
        self.primary = primary
        updateAnimation()
        return self
    }
    
    private func updateAnimation() {
        guard let animationGroup = associatedView!.cachedAnimations![NSString(string: animationKey!)] else {
            return
        }
        
        if let animations = animationGroup.animations {
            var animation = (animations as! [FAAnimation]).filter ({ $0.keyPath == self.keyPath }).first
            
            if let animation = animation {
                animation.easingFunction = easingCurve
                
                if let currentValue = toValue as? CGPoint {
                    animation.toValue =  NSValue(CGPoint :currentValue)
                } else  if let currentValue = toValue as? CGSize {
                    animation.toValue = NSValue( CGSize :currentValue)
                } else  if let currentValue = toValue as? CGRect {
                    animation.toValue = NSValue( CGRect : currentValue)
                } else  if let currentValue = toValue as? CGFloat {
                    animation.toValue = currentValue
                } else  if let currentValue = toValue as? CATransform3D {
                    animation.toValue =  NSValue( CATransform3D : currentValue)
                } else if let currentValue = typeCastCGColor(toValue) {
                    animation.toValue = currentValue
                }
                
                animation.duration = Double(duration)
                animation.setAnimationAsPrimary(primary)
                animationGroup.weakLayer = associatedView?.layer
                animationGroup.animations!.append(animation)
                
                associatedView!.cachedAnimations![NSString(string: animationKey!)] = animationGroup
                return
            }
        }
        
        
        let animation = FAAnimation(keyPath: keyPath)
        animation.easingFunction = easingCurve
       
        if let currentValue = toValue as? CGPoint {
            animation.toValue =  NSValue(CGPoint :currentValue)
        } else  if let currentValue = toValue as? CGSize {
            animation.toValue = NSValue( CGSize :currentValue)
        } else  if let currentValue = toValue as? CGRect {
            animation.toValue = NSValue( CGRect : currentValue)
        } else  if let currentValue = toValue as? CGFloat {
            animation.toValue = currentValue
        } else  if let currentValue = toValue as? CATransform3D {
            animation.toValue =  NSValue( CATransform3D : currentValue)
        } else if let currentValue = typeCastCGColor(toValue) {
            animation.toValue = currentValue
        }
        
        animation.duration = Double(duration)
        animation.setAnimationAsPrimary(primary)
        animationGroup.weakLayer = associatedView?.layer
        animationGroup.animations!.append(animation)
        
        associatedView!.cachedAnimations![NSString(string: animationKey!)] = animationGroup
    }
}