//
//  CALayer+FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//


import Foundation
import UIKit

extension CALayer {
    
    final public class func swizzleAddAnimation() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        if self !== CALayer.self {
            return
        }
        
        dispatch_once(&Static.token) {
            let originalSelector = #selector(CALayer.addAnimation(_:forKey:))
            let swizzledSelector = #selector(CALayer.FA_addAnimation(_:forKey:))
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    }
    
    internal func FA_addAnimation(anim: CAAnimation, forKey key: String?) {
        if let animation = anim as? FAAnimationGroup {
            animation.weakLayer = self
            animation.animationKey = key
            animation.startTime = self.convertTime(CACurrentMediaTime(), fromLayer: nil)
            animation.synchronizeAnimationGroup((self.animationForKey(key!) as? FAAnimationGroup))
        }

        removeAllAnimations()
        FA_addAnimation(anim, forKey: key)
    }

    final public func anyValueForKeyPath(keyPath: String) -> Any? {
        if let currentFromValue = self.valueForKeyPath(keyPath) {
            
            let type = String.fromCString(currentFromValue.objCType) ?? ""
            
            if type.hasPrefix("{CGPoint") {
                return currentFromValue.CGPointValue!
            } else if type.hasPrefix("{CGSize") {
                return currentFromValue.CGSizeValue!
            } else if type.hasPrefix("{CGRect") {
                return currentFromValue.CGRectValue!
            } else if type.hasPrefix("{CATransform3D") {
                return currentFromValue.CATransform3DValue!
            }
            else {
                return currentFromValue
            }
        }
        
        return super.valueForKeyPath(keyPath)
    }
    
    final public func owningView() -> UIView? {
        if let owningView = self.delegate as? UIView {
            return owningView
        }
        
        return nil
    }
}


