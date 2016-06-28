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
    
    public func magnitudeValue() -> CGFloat {
        return sqrt((x * x) + (y * y))
    }
    
    public func magnitudeToValue<T : FAAnimatable>(toValue:  T) -> CGFloat {
        return CGPointMake((toValue as! CGPoint).x - x, (toValue as! CGPoint).y - y).magnitudeValue()
    }
    
    public func interpolatedValue<T : FAAnimatable>(toValue : T, progress : CGFloat) -> NSValue {
        let adjustedx : CGFloat = interpolateCGFloat(self.x, end: (toValue as! CGPoint).x, progress: progress)
        let adjustedy : CGFloat = interpolateCGFloat(self.y, end: (toValue as! CGPoint).y, progress: progress)
        return  CGPointMake(adjustedx, adjustedy).valueRepresentation()
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
        let adjustedx : CGFloat = CGFloat(springs[SpringAnimationKey.CGPointX]!.updatedValue(deltaTime))
        let adjustedy : CGFloat = CGFloat(springs[SpringAnimationKey.CGPointY]!.updatedValue(deltaTime))
        return CGPointMake(adjustedx, adjustedy).valueRepresentation()
    }
    
    public func valueRepresentation() -> NSValue {
         return NSValue(CGPoint :  self)
    }
    
    public func getValue() -> CGPoint {
        return self
    }
}