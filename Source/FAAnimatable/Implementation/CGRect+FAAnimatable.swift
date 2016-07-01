//
//  CGRect+FAAnimatable.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public func ==(lhs:CGRect, rhs:CGRect) -> Bool {
    return CGRectEqualToRect(lhs, rhs)
}

extension CGRect : FAAnimatable {
    
    public typealias T = CGRect
    
    public func magnitudeValue() -> CGFloat {
        return sqrt((width * width) + (height * height))
    }
    
    public func magnitudeToValue<T : FAAnimatable>(toValue:  T) -> CGFloat {
        return CGSizeMake((toValue as! CGRect).width - width, (toValue as! CGRect).height - height).magnitudeValue()
    }
    
    public func interpolatedValue<T : FAAnimatable>(toValue : T, progress : CGFloat) -> NSValue {
        let width : CGFloat = ceil(interpolateCGFloat(self.width, end: (toValue as! CGRect).width, progress: progress))
        let height : CGFloat = ceil(interpolateCGFloat(self.height, end: (toValue as! CGRect).height, progress: progress))
        return CGRectMake(0, 0, width, height).valueRepresentation()
    }
    
    public func interpolatedSpringValue<T : FAAnimatable>(toValue : T, springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> NSValue {
        let rect = CGRectMake(0,
                              0,
                              springs[SpringAnimationKey.CGSizeWidth]!.updatedValue(deltaTime),
                              springs[SpringAnimationKey.CGSizeHeight]!.updatedValue(deltaTime))
        
        return rect.valueRepresentation()
    }
    
    public func interpolationSprings<T : FAAnimatable>(toValue : T, initialVelocity : Any, angularFrequency : CGFloat, dampingRatio : CGFloat) -> Dictionary<String, FASpring> {
        var springs = Dictionary<String, FASpring>()
        
        if let startingVelocity = initialVelocity as? CGPoint {
            
            let sizeSprings = (toValue as! CGRect).size.interpolationSprings((toValue as! CGRect).size,
                                                                             initialVelocity : startingVelocity,
                                                                             angularFrequency : angularFrequency,
                                                                             dampingRatio : dampingRatio)
            
            let origin = (toValue as! CGRect).origin
            
            let positionSprings = origin.interpolationSprings(origin,
                                                              initialVelocity : startingVelocity,
                                                              angularFrequency : angularFrequency,
                                                              dampingRatio : dampingRatio)
            
            springs[SpringAnimationKey.CGSizeWidth]   = sizeSprings[SpringAnimationKey.CGSizeWidth]
            springs[SpringAnimationKey.CGSizeHeight]  = sizeSprings[SpringAnimationKey.CGSizeHeight]
            springs[SpringAnimationKey.CGPointX]      = positionSprings[SpringAnimationKey.CGPointX]
            springs[SpringAnimationKey.CGPointY]      = positionSprings[SpringAnimationKey.CGPointY]
        }
        return springs
    }
    
    public func valueRepresentation() -> NSValue {
        return NSValue(CGRect :  self)
    }
}