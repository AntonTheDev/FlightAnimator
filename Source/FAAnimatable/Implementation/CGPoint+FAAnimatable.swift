//
//  CGPoint+FAAnimatable.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public func ==(lhs:CGPoint, rhs:CGPoint) -> Bool {
    return  CGPointEqualToPoint(lhs, rhs)
}

extension CGPoint : FAAnimatable {
    
    public typealias T = CGPoint
    
    public func magnitudeValue() -> CGFloat {
        return sqrt((x * x) + (y * y))
    }
    
    public func magnitudeToValue<T : FAAnimatable>(toValue:  T) -> CGFloat {
        
        if let toValue = toValue as? CGPoint {
            return CGPointMake(toValue.x - x, toValue.y - y).magnitudeValue()
        }
        
        return CGPointZero.magnitudeValue()
    }
    
    public func interpolatedValue<T : FAAnimatable>(toValue : T, progress : CGFloat) -> NSValue {
        if let toValue = toValue as? CGPoint {
            let adjustedx : CGFloat = interpolateCGFloat(self.x, end: toValue.x, progress: progress)
            let adjustedy : CGFloat = interpolateCGFloat(self.y, end: toValue.y, progress: progress)
            return  CGPointMake(adjustedx, adjustedy).valueRepresentation()
        }
        
        return CGPointZero.valueRepresentation()
    }

    public func interpolationSprings<T : FAAnimatable>(toValue : T, initialVelocity : Any, angularFrequency : CGFloat, dampingRatio : CGFloat) -> Dictionary<String, FASpring> {
        var springs = Dictionary<String, FASpring>()
        
        if let startingVelocity = initialVelocity as? CGPoint {
            let xSpring = self.x.interpolationSprings((toValue as! CGPoint).x, initialVelocity : startingVelocity.x, angularFrequency : angularFrequency, dampingRatio : dampingRatio)
            let ySpring = self.y.interpolationSprings((toValue as! CGPoint).y, initialVelocity : startingVelocity.y, angularFrequency : angularFrequency, dampingRatio : dampingRatio)
            
            springs[SpringAnimationKey.CGPointX] = xSpring[SpringAnimationKey.CGFloat]
            springs[SpringAnimationKey.CGPointY] = ySpring[SpringAnimationKey.CGFloat]
        }
        
        return springs
    }
    
    public func interpolatedSpringValue<T : FAAnimatable>(toValue : T, springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> NSValue {
        let adjustedx : CGFloat = springs[SpringAnimationKey.CGPointX]!.updatedValue(deltaTime)
        let adjustedy : CGFloat = springs[SpringAnimationKey.CGPointY]!.updatedValue(deltaTime)
        return CGPointMake(adjustedx, adjustedy).valueRepresentation()
    }
    
    public func springVelocity(springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> CGPoint {
        if let currentXVelocity = springs[SpringAnimationKey.CGPointX]?.velocity(deltaTime),
            let currentYVelocity = springs[SpringAnimationKey.CGPointY]?.velocity(deltaTime) {
                return  CGPointMake(currentXVelocity, currentYVelocity)
        }
        
        return CGPointZero
    }
    
    public func valueRepresentation() -> NSValue {
         return NSValue(CGPoint :  self)
    }
}