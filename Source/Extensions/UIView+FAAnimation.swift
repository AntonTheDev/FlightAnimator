//
//  UIView+AnimationCache.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 6/22/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit
private struct FAAssociatedKey {
    static var layoutConfigurations = "layoutConfigurations"
}

internal extension UIView {
    
    var cachedAnimations: [NSString : FAAnimationGroup]? {
        get {
            return fa_getAssociatedObject(self, associativeKey: &FAAssociatedKey.layoutConfigurations)
        }
        set {
            if let value = newValue {
                fa_setAssociatedObject(self, value: value, associativeKey: &FAAssociatedKey.layoutConfigurations, policy: objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    func fa_setAssociatedObject<T>(_ object: AnyObject,
                                value: T,
                                associativeKey: UnsafeRawPointer,
                                policy: objc_AssociationPolicy) {
        
        if T.self is AnyObject.Type {
            objc_setAssociatedObject(object, associativeKey, value as AnyObject,  policy)
        } else {
            objc_setAssociatedObject(object, associativeKey, ValueWrapper(value),  policy)
        }
    }
    
    func fa_getAssociatedObject<T>(_ object: AnyObject, associativeKey: UnsafeRawPointer) -> T? {
        if let v = objc_getAssociatedObject(object, associativeKey) as? T {
            return v
        } else if let v = objc_getAssociatedObject(object, associativeKey) as? ValueWrapper<T> {
            return v.value
        } else {
            return nil
        }
    }
    
    func applyAnimationsToSubViews(_ inView : UIView, forKey key: String, animated : Bool = true) {
        for subView in inView.subviews {
            subView.applyAnimation(forKey: key, animated: animated)
        }
    }
    
    func appendAnimation(_ animation : AnyObject, forKey key: String) {
        
        if cachedAnimations == nil {
            cachedAnimations = [NSString : FAAnimationGroup]()
        }
        
        if let newAnimation = animation as? FABasicAnimation {
            
            if let oldAnimation = cachedAnimations![NSString(string: key)] {
                oldAnimation.stopTriggerTimer()
            }
            
            let newAnimationGroup = FAAnimationGroup()
            newAnimationGroup.animations = [newAnimation]
            newAnimationGroup.animatingLayer = layer
            cachedAnimations![NSString(string: key)] = newAnimationGroup
        }
        else if let newAnimationGroup = animation as? FAAnimationGroup {
            
            if let oldAnimation = cachedAnimations![key as NSString] {
                oldAnimation.stopTriggerTimer()
            }
            
            newAnimationGroup.animatingLayer = layer
            cachedAnimations![NSString(string: key)] = newAnimationGroup
        }
    }
}

internal extension UIView {
    
    internal func formattedNumericValue(forValue value : Any, forKey key : String) -> Any {
        
        var formalValue : Any = value
        
        if let coreValue = layer.value(forKey: key) as? NSValue,
            let typedValue = coreValue.typeValue() as? NSNumber {
            
            let numberType = CFNumberGetType(typedValue)
            
            switch numberType {
            case .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type, .shortType, .intType, .longType, .longLongType, .cfIndexType, .nsIntegerType:
                
                if let castValue = value as? Double {
                    formalValue = Int(castValue)
                } else if let castValue = value as? Float {
                    formalValue = Int(castValue)
                }
            case .float32Type, .float64Type, .floatType, .cgFloatType:
                
                if let castValue = value as? Double {
                    formalValue = CGFloat(castValue)
                } else if let castValue = value as? Int {
                    formalValue = CGFloat(castValue)
                }
                
                break
            case .doubleType:
                if let castValue = value as? Float {
                    formalValue = Double(castValue)
                } else if let castValue = value as? Int {
                    formalValue = Double(castValue)
                }
            case .charType:
                print("WARNING Unknown Animatable Value Configured")
            }
        }
        
        
        return formalValue
    }
}

extension Array where Element : Equatable {
    
    mutating func fa_removeObject(_ object : Iterator.Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
    
    func fa_contains<T>(_ obj: T) -> Bool where T : Equatable {
        return filter({$0 as? T == obj}).count > 0
    }
}

final class ValueWrapper<T> {
    let value: T
    init(_ x: T) {
        value = x
    }
}
