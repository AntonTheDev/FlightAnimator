//
//  CGFloat+FAAnimatable.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat : FAAnimatable {
    
    public typealias T = CGFloat
    
    public func magnitudeValue() -> CGFloat {
        return sqrt((self * self))
    }
    
    public func magnitudeToValue<T : FAAnimatable>(toValue:  T) -> CGFloat {
        return self - toValue.magnitudeValue()
    }
    
    public func interpolatedValue<T : FAAnimatable>(toValue : T, progress : CGFloat) -> NSValue {
        return interpolateCGFloat(self, end: (toValue as! CGFloat), progress: progress).valueRepresentation()
    }
    
    public func springVelocity(springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> CGPoint {
        if let currentFloatVelocity = springs[SpringAnimationKey.CGFloat]?.velocity(deltaTime) {
           return  CGPointMake(currentFloatVelocity, currentFloatVelocity)
        }
        
        return CGPointZero
    }
    public func interpolationSprings<T : FAAnimatable>(toValue : T, initialVelocity : Any, angularFrequency : CGFloat, dampingRatio : CGFloat) -> Dictionary<String, FASpring> {
        var springs = Dictionary<String, FASpring>()
        
        if let startingVelocity = initialVelocity as? CGFloat {
            let floatSpring = FASpring(finalValue: (toValue as! CGFloat),
                                       initialValue:  self,
                                       positionVelocity: startingVelocity,
                                       angularFrequency:angularFrequency,
                                       dampingRatio: dampingRatio)
            
            springs[SpringAnimationKey.CGFloat] = floatSpring
        }
        
        return springs
    }
    
    public func interpolatedSpringValue<T : FAAnimatable>(toValue : T, springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> NSValue {
        return springs[SpringAnimationKey.CGFloat]!.updatedValue(deltaTime).valueRepresentation()
    }
    
    public func valueRepresentation() -> NSValue {
        return NSNumber(float: Float(self))
    }
}