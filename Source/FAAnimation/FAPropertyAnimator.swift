//
//  FAPropertyAnimator.swift
//  
//
//  Created by Anton on 10/28/16.
//
//

import Foundation
import UIKit

open class FAPropertyAnimator  {
    
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
    }
    
    @discardableResult open func duration(_ duration : CGFloat) -> FAPropertyAnimator {
        self.duration = duration
        updateAnimation()
        return self
    }
    
    @discardableResult open func easing(_ easing : FAEasing) -> FAPropertyAnimator {
        self.easingCurve = easing
        updateAnimation()
        return self
    }
    
    @discardableResult open func primary(_ primary : Bool) -> FAPropertyAnimator {
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
                } else if CFGetTypeID(toValue as AnyObject) == CGColor.typeID {
                    animation.toValue = toValue as! CGColor
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
        } else if CFGetTypeID(toValue as AnyObject) == CGColor.typeID {
            animation.toValue = toValue as! CGColor
        }
        
        animation.duration = Double(duration)
        animation.isPrimary = primary
        animationGroup.configureAnimationGroup(withLayer: associatedView?.layer, animationKey: animationKey)
        animationGroup.animations!.append(animation)
        
        associatedView!.cachedAnimations![NSString(string: animationKey!)] = animationGroup
    }
}
