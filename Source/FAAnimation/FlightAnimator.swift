//
//  FlightAnimate+Private.swift
//  
//
//  Created by Anton on 6/29/16.
//
//

import Foundation
import UIKit

internal let DebugTriggerLogEnabled = false

open class FlightAnimator {
    
    internal weak var associatedView : UIView?
    internal var animationKey : String?
    
    var animationConfigurations = [String : PropertyAnimator]()
    var primaryTimingPriority : FAPrimaryTimingPriority = .maxTime
    
    init(withView view : UIView, forKey key: String, priority : FAPrimaryTimingPriority = .maxTime) {
        animationKey = key
        associatedView = view
        primaryTimingPriority = priority
        configureNewGroup()
    }
    
    fileprivate func configureNewGroup() {
        
        if associatedView!.cachedAnimations == nil {
            associatedView!.cachedAnimations = [NSString : FAAnimationGroup]()
        }
       
        if associatedView!.cachedAnimations!.keys.contains(NSString(string: animationKey!)) {
            associatedView!.cachedAnimations![NSString(string: animationKey!)]?.stopTriggerTimer()
            associatedView!.cachedAnimations![NSString(string: animationKey!)] = nil
        }
        
        let newGroup = FAAnimationGroup()
        newGroup.configureAnimationGroup(withLayer: associatedView?.layer, animationKey: animationKey)
        newGroup.primaryTimingPriority = primaryTimingPriority
        
        associatedView!.cachedAnimations![NSString(string: animationKey!)] = newGroup
    }
    
    internal func triggerAnimation(_ timingPriority : FAPrimaryTimingPriority = .maxTime,
                                   timeBased : Bool,
                                   view: UIView,
                                   progress: CGFloat = 0.0,
                                   animator: (_ animator : FlightAnimator) -> Void) {

        let triggerKey = UUID().uuidString
        
        if let animationGroup = associatedView!.cachedAnimations![NSString(string: animationKey!)] {
            
            let animationTrigger = AnimationTrigger()
            animationTrigger.isTimedBased = timeBased
            animationTrigger.triggerProgessValue = progress
            animationTrigger.animationKey = triggerKey as NSString?
            animationTrigger.animatedView = view
            
            animationGroup._segmentArray.append(animationTrigger)

            associatedView!.appendAnimation(animationGroup, forKey: animationKey!)
        }
        
        let newAnimator = FlightAnimator(withView: view, forKey : triggerKey,  priority : timingPriority)
        animator(newAnimator)
    }
}

open class PropertyAnimator  {
    
    fileprivate weak var associatedView : UIView?
    fileprivate var animationKey : String?
    fileprivate var keyPath : String?
    
    var toValue : Any
    var easingCurve : FAEasing = .linear
    var duration : CGFloat
    var primary : Bool
    
    init(value: Any, forKeyPath key : String, view : UIView, animationKey : String) {
        self.animationKey = animationKey
        associatedView = view
        keyPath = key
        toValue = value
        easingCurve = .linear
        duration = 0.0
        primary = false
    }
    
    deinit {
        associatedView = nil
        //print ("DEINIT PropertyAnimationConfig")
    }
    
    @discardableResult open func duration(_ duration : CGFloat) -> PropertyAnimator {
        self.duration = duration
        updateAnimation()
        return self
    }
    
    @discardableResult open func easing(_ easing : FAEasing) -> PropertyAnimator {
        self.easingCurve = easing
        updateAnimation()
        return self
    }
    
    @discardableResult open func primary(_ primary : Bool) -> PropertyAnimator {
        self.primary = primary
        updateAnimation()
        return self
    }
    
    fileprivate func updateAnimation() {
        guard let animationGroup = associatedView!.cachedAnimations![NSString(string: animationKey!)] else {
            return
        }
        
        if let animations = animationGroup.animations {
            let animation = (animations as! [FABasicAnimation]).filter ({ $0.keyPath == self.keyPath }).first
            
            if let animation = animation {
                animation.easingFunction = easingCurve
                
                if let currentValue = toValue as? CGPoint {
                    animation.toValue =  NSValue(cgPoint :currentValue)
                } else  if let currentValue = toValue as? CGSize {
                    animation.toValue = NSValue( cgSize :currentValue)
                } else  if let currentValue = toValue as? CGRect {
                    animation.toValue = NSValue( cgRect : currentValue)
                } else  if let currentValue = toValue as? CGFloat {
                    animation.toValue = currentValue as AnyObject?
                } else  if let currentValue = toValue as? CATransform3D {
                    animation.toValue =  NSValue( caTransform3D : currentValue)
                } else if let currentValue = typeCastCGColor(toValue) {
                    animation.toValue = currentValue
                }
                
                animation.duration = Double(duration)
                animation.isPrimary = primary
                
                animationGroup.configureAnimationGroup(withLayer: associatedView?.layer, animationKey: animationKey)
                animationGroup.animations!.append(animation)
                
                associatedView!.cachedAnimations![NSString(string: animationKey!)] = animationGroup
                return
            }
        }
        
        let animation = FABasicAnimation(keyPath: keyPath)
        animation.easingFunction = easingCurve
       
        if let currentValue = toValue as? CGPoint {
            animation.toValue =  NSValue(cgPoint :currentValue)
        } else  if let currentValue = toValue as? CGSize {
            animation.toValue = NSValue( cgSize :currentValue)
        } else  if let currentValue = toValue as? CGRect {
            animation.toValue = NSValue( cgRect : currentValue)
        } else  if let currentValue = toValue as? CGFloat {
            animation.toValue = currentValue as AnyObject?
        } else  if let currentValue = toValue as? CATransform3D {
            animation.toValue =  NSValue( caTransform3D : currentValue)
        } else if let currentValue = typeCastCGColor(toValue) {
            animation.toValue = currentValue
        }
        
        animation.duration = Double(duration)
        animation.isPrimary = primary
        animationGroup.configureAnimationGroup(withLayer: associatedView?.layer, animationKey: animationKey)
        animationGroup.animations!.append(animation)
        
        associatedView!.cachedAnimations![NSString(string: animationKey!)] = animationGroup
    }
}
