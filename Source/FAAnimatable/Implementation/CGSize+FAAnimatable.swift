//
//  CGSize+FAAnimatable.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public func ==(lhs:CGSize, rhs:CGSize) -> Bool {
    return  CGSizeEqualToSize(lhs, rhs)
}

extension CGSize : FAAnimatable {
    
    public func magnitudeValue() -> CGFloat {
        return sqrt((width * width) + (height * height))
    }
    
    public func magnitudeToValue<T : FAAnimatable>(toValue:  T) -> CGFloat {
        return CGSizeMake((toValue as! CGSize).width - width, (toValue as! CGSize).height - height).magnitudeValue()
    }
    
    public func interpolatedValue<T : FAAnimatable>(toValue : T, progress : CGFloat) -> NSValue {
        let width : CGFloat = ceil(interpolateCGFloat(self.width, end: (toValue as! CGSize).width, progress: progress))
        let height : CGFloat = ceil(interpolateCGFloat(self.height, end: (toValue as! CGSize).height, progress: progress))
        return  CGSizeMake(width, height).valueRepresentation()
    }
    
    public func interpolatedValues(toValue : Any, duration : CGFloat, easingFunction : FAEasing) -> [AnyObject] {
        return interpolatedParametricValues(self, finalValue : (toValue as! CGSize), duration : duration, easingFunction : easingFunction)
    }
    
    public func interpolatedSpringValue<T : FAAnimatable>(toValue : T, springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> NSValue {
        let size = CGSizeMake(springs[SpringAnimationKey.CGSizeWidth]!.updatedValue(deltaTime),
                              springs[SpringAnimationKey.CGSizeHeight]!.updatedValue(deltaTime))
        return size.valueRepresentation()
    }
    
    public func interpolationSprings<T : FAAnimatable>(toValue : T, initialVelocity : Any, angularFrequency : CGFloat, dampingRatio : CGFloat) -> Dictionary<String, FASpring> {
        
        var springs = Dictionary<String, FASpring>()
    
        if let startingVelocity = initialVelocity as? CGPoint {
            let widthSpring = self.width.interpolationSprings((toValue as! CGSize).width, initialVelocity : startingVelocity.x, angularFrequency : angularFrequency, dampingRatio : dampingRatio)
            let heightSpring = self.height.interpolationSprings((toValue as! CGSize).height, initialVelocity : startingVelocity.y, angularFrequency : angularFrequency, dampingRatio : dampingRatio)
            
            springs[SpringAnimationKey.CGSizeWidth]  = widthSpring[SpringAnimationKey.CGFloat]
            springs[SpringAnimationKey.CGSizeHeight] = heightSpring[SpringAnimationKey.CGFloat]
        }
        
        return springs
    }
    
    public func valueRepresentation() -> NSValue {
        return NSValue(CGSize :  self)
    }
    
    public func getValue() -> CGSize {
        return self
    }
}