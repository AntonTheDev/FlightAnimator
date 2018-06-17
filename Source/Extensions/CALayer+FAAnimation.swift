//
//  CALayer+FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//


import Foundation
import UIKit

internal func swizzleSelector(_ classType: AnyClass!,
                              originalSelector : Selector,
                              swizzledSelector : Selector)
{
    let originalMethod = class_getInstanceMethod(classType, originalSelector)
    let swizzledMethod = class_getInstanceMethod(classType, swizzledSelector)
    
    let didAddMethod = class_addMethod(classType,
                                       originalSelector,
                                       method_getImplementation(swizzledMethod!),
                                       method_getTypeEncoding(swizzledMethod!))
    
    if didAddMethod
    {
        class_replaceMethod(classType,
                            swizzledSelector,
                            method_getImplementation(originalMethod!),
                            method_getTypeEncoding(originalMethod!))
    }
    else
    {
        method_exchangeImplementations(originalMethod!, swizzledMethod!);
    }
}

var executedLayer = false
var executedColor = false

extension CALayer
{
    
    final public var view : UIView?
    {
        if let owningView = self.delegate as? UIView
        {
            return owningView
        }
        
        return nil
    }
    
    final public class func swizzleAddAnimation()
    {
        struct Static {
            static var token: Int = 0
        }
        
        if self !== CALayer.self
        {
            return
        }
        
        if executedLayer == false
        {
            swizzleSelector(self,
                            originalSelector: #selector(CALayer.add(_:forKey:)),
                            swizzledSelector: #selector(CALayer.FA_addAnimation(_:forKey:)))
            
            swizzleSelector(self,
                            originalSelector: #selector(CALayer.removeAllAnimations),
                            swizzledSelector: #selector(CALayer.FA_removeAllAnimations))
            
            swizzleSelector(self,
                            originalSelector: #selector(CALayer.removeAnimation(forKey:)),
                            swizzledSelector: #selector(CALayer.FA_removeAnimationForKey))
            
            UIColor.swizzleGetRed()
            
            executedLayer = true
        }
    }
    
    
    @objc internal func FA_addAnimation(_ anim: CAAnimation, forKey key: String?)
    {
        guard let animation = anim as? FAAnimationGroup else
        {
            FA_addAnimation(anim, forKey: key)
            return
        }
        
        animation.synchronizeAnimationGroup(withLayer: self, animationKey : key)
        
        removeAllAnimations()
        
        FA_addAnimation(animation, forKey: key)
    }
    
    
    @objc internal func FA_removeAnimationForKey(_ key: String)
    {
        if let animation = self.animation(forKey: key) as? FAAnimationGroup
        {
            if DebugTriggerLogEnabled { print("STOPPED FORKEY ", animation.animationKey as Any) }
            
            animation.stopTriggerTimer()
        }
        
        FA_removeAnimationForKey(key)
    }
    
    
    @objc internal func FA_removeAllAnimations()
    {
        guard let keys = self.animationKeys() else
        {
            FA_removeAllAnimations()
            return
        }
        
        for key in keys
        {
            if let animation = self.animation(forKey: key) as? FAAnimationGroup
            {
                if DebugTriggerLogEnabled { print("STOPPED ALL ", animation.animationKey as Any) }
                
                animation.stopTriggerTimer()
            }
        }

        FA_removeAllAnimations()
    }
    
    
    final public func animatableValueForKeyPath(_ keyPath: String) -> FAAnimatable?
    {
        if let currentFromValue = self.value(forKeyPath: keyPath)
        {
            if CFGetTypeID(currentFromValue as AnyObject) == CGColor.typeID
            {
                return CGColorWrapper(withColor: currentFromValue as! CGColor)
            }
            
            if let currentFromValue = currentFromValue as? CGColorWrapper
            {
                return currentFromValue
            }

            if let currentFromValue = currentFromValue as? NSValue
            {
                return currentFromValue.typedValue() as? FAAnimatable
            }
        }
        
        return super.value(forKeyPath: keyPath) as? FAAnimatable
    }
}

extension UIColor
{
    // This is needed to fix the following radar
    // http://openradar.appspot.com/radar?id=3114410
    
    final internal class func swizzleGetRed()
    {
        struct Static
        {
            static var token: Int = 0
        }
        
        if self !== CALayer.self
        {
            return
        }
        
        if executedColor == false
        {
            swizzleSelector(self,
                            originalSelector: #selector(UIColor.getRed(_:green:blue:alpha:)),
                            swizzledSelector: #selector(UIColor.FA_getRed(_:green:blue:alpha:)))
            
            executedColor = true
        }
    }
    
    @objc internal func FA_getRed(_ red: UnsafeMutablePointer<CGFloat>,
                            green: UnsafeMutablePointer<CGFloat>,
                            blue: UnsafeMutablePointer<CGFloat>,
                            alpha: UnsafeMutablePointer<CGFloat>) -> Bool
    {
        if self.cgColor.numberOfComponents == 4
        {
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            return  self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        // Seriously? WTF Apple.... this should return 4 components
        else if self.cgColor.numberOfComponents == 2
        {
            var white: CGFloat = 0, whiteAlpha: CGFloat = 0
            
            if self.getWhite(&white, alpha: &whiteAlpha)
            {
                red.pointee = white * 1.0
                green.pointee = white * 1.0
                blue.pointee = white * 1.0
                alpha.pointee = whiteAlpha
                
                return true
            }
        }
        
        return false
    }
}
