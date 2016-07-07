//
//  CATransform3D+Animation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public func ==(lhs:CATransform3D, rhs:CATransform3D) -> Bool {
    return CATransform3DEqualToTransform(lhs, rhs)
}

extension CATransform3D : FAAnimatable {
    
    public typealias T = CATransform3D

    public func magnitudeValue() -> CGFloat {
        return sqrt((m11 * m11) + (m12 * m12) + (m13 * m13) + (m14 * m14) + (m21 * m21) + (m22 * m22) + (m23 * m23) + (m24 * m24) +
            (m31 * m31) + (m32 * m32) + (m33 * m33) + (m34 * m34) + (m41 * m41) + (m42 * m42) + (m43 * m43) + (m44 * m44))
    }
    
    public func magnitudeToValue<T : FAAnimatable>(toValue:  T) -> CGFloat {
        
        var transform = CATransform3D()
        transform.m11 = (toValue as! CATransform3D).m11 - m11
        transform.m12 = (toValue as! CATransform3D).m12 - m12
        transform.m13 = (toValue as! CATransform3D).m13 - m13
        transform.m14 = (toValue as! CATransform3D).m14 - m14
        
        transform.m21 = (toValue as! CATransform3D).m21 - m21
        transform.m22 = (toValue as! CATransform3D).m22 - m22
        transform.m23 = (toValue as! CATransform3D).m23 - m23
        transform.m24 = (toValue as! CATransform3D).m24 - m24
        
        transform.m31 = (toValue as! CATransform3D).m31 - m31
        transform.m32 = (toValue as! CATransform3D).m32 - m32
        transform.m33 = (toValue as! CATransform3D).m33 - m33
        transform.m34 = (toValue as! CATransform3D).m34 - m34
        
        transform.m41 = (toValue as! CATransform3D).m41 - m41
        transform.m42 = (toValue as! CATransform3D).m42 - m42
        transform.m43 = (toValue as! CATransform3D).m43 - m43
        transform.m44 = (toValue as! CATransform3D).m44 - m44
        
        return transform.magnitudeValue()
    }
    
    public func interpolatedValue<T : FAAnimatable>(toValue : T, progress : CGFloat) -> AnyObject {
        var transform = CATransform3D()
        let finalValue = toValue as! CATransform3D
        
        transform.m11 = interpolateCGFloat(m11, end: finalValue.m11, progress: progress)
        transform.m12 = interpolateCGFloat(m12, end: finalValue.m12, progress: progress)
        transform.m13 = interpolateCGFloat(m13, end: finalValue.m13, progress: progress)
        transform.m14 = interpolateCGFloat(m14, end: finalValue.m14, progress: progress)
        
        transform.m21 = interpolateCGFloat(m21, end: finalValue.m21, progress: progress)
        transform.m22 = interpolateCGFloat(m22, end: finalValue.m22, progress: progress)
        transform.m23 = interpolateCGFloat(m23, end: finalValue.m23, progress: progress)
        transform.m24 = interpolateCGFloat(m24, end: finalValue.m24, progress: progress)
        
        transform.m31 = interpolateCGFloat(m31, end: finalValue.m31, progress: progress)
        transform.m32 = interpolateCGFloat(m32, end: finalValue.m32, progress: progress)
        transform.m33 = interpolateCGFloat(m33, end: finalValue.m33, progress: progress)
        transform.m34 = interpolateCGFloat(m34, end: finalValue.m34, progress: progress)
        
        transform.m41 = interpolateCGFloat(m41, end: finalValue.m41, progress: progress)
        transform.m42 = interpolateCGFloat(m42, end: finalValue.m42, progress: progress)
        transform.m43 = interpolateCGFloat(m43, end: finalValue.m43, progress: progress)
        transform.m44 = interpolateCGFloat(m44, end: finalValue.m44, progress: progress)
        
        return transform.valueRepresentation()
    }
    
    public func interpolatedSpringValue<T : FAAnimatable>(toValue : T, springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> AnyObject {
        var transform = CATransform3D()
        
        transform.m11 = springs[SpringAnimationKey.M11]!.updatedValue(deltaTime)
        transform.m12 = springs[SpringAnimationKey.M12]!.updatedValue(deltaTime)
        transform.m13 = springs[SpringAnimationKey.M13]!.updatedValue(deltaTime)
        transform.m14 = springs[SpringAnimationKey.M14]!.updatedValue(deltaTime)
        
        transform.m21 = springs[SpringAnimationKey.M21]!.updatedValue(deltaTime)
        transform.m22 = springs[SpringAnimationKey.M22]!.updatedValue(deltaTime)
        transform.m23 = springs[SpringAnimationKey.M23]!.updatedValue(deltaTime)
        transform.m24 = springs[SpringAnimationKey.M24]!.updatedValue(deltaTime)
        
        transform.m31 = springs[SpringAnimationKey.M31]!.updatedValue(deltaTime)
        transform.m32 = springs[SpringAnimationKey.M32]!.updatedValue(deltaTime)
        transform.m33 = springs[SpringAnimationKey.M33]!.updatedValue(deltaTime)
        transform.m34 = springs[SpringAnimationKey.M34]!.updatedValue(deltaTime)
        
        transform.m41 = springs[SpringAnimationKey.M41]!.updatedValue(deltaTime)
        transform.m42 = springs[SpringAnimationKey.M42]!.updatedValue(deltaTime)
        transform.m43 = springs[SpringAnimationKey.M43]!.updatedValue(deltaTime)
        transform.m44 = springs[SpringAnimationKey.M44]!.updatedValue(deltaTime)
        
        return transform.valueRepresentation()
    }
    
    public func springVelocity(springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> CGPoint {
        return CGPointZero
    }
    
    public func interpolationSprings<T : FAAnimatable>(toValue : T, initialVelocity : Any, angularFrequency : CGFloat, dampingRatio : CGFloat) -> Dictionary<String, FASpring> {
        
        var springs = Dictionary<String, FASpring>()
        
        if let startingVelocity = initialVelocity as? CGPoint {
            
            springs[SpringAnimationKey.M11] = self.m11.interpolationSprings((toValue as! CATransform3D).m11,
                                                                            initialVelocity : startingVelocity.x,
                                                                            angularFrequency : angularFrequency,
                                                                            dampingRatio : dampingRatio)[SpringAnimationKey.CGFloat]
            springs[SpringAnimationKey.M12] = self.m12.interpolationSprings((toValue as! CATransform3D).m12,
                                                                            initialVelocity : startingVelocity.x,
                                                                            angularFrequency : angularFrequency,
                                                                            dampingRatio : dampingRatio)[SpringAnimationKey.CGFloat]
            
            springs[SpringAnimationKey.M13] = self.m13.interpolationSprings((toValue as! CATransform3D).m13,
                                                                            initialVelocity : startingVelocity.x,
                                                                            angularFrequency : angularFrequency,
                                                                            dampingRatio : dampingRatio)[SpringAnimationKey.CGFloat]
            
            springs[SpringAnimationKey.M14] = self.m14.interpolationSprings((toValue as! CATransform3D).m14,
                                                                            initialVelocity : startingVelocity.x,
                                                                            angularFrequency : angularFrequency,
                                                                            dampingRatio : dampingRatio)[SpringAnimationKey.CGFloat]
            
            springs[SpringAnimationKey.M21] = self.m21.interpolationSprings((toValue as! CATransform3D).m21,
                                                                            initialVelocity : startingVelocity.x,
                                                                            angularFrequency : angularFrequency,
                                                                            dampingRatio : dampingRatio)[SpringAnimationKey.CGFloat]
            springs[SpringAnimationKey.M22] = self.m22.interpolationSprings((toValue as! CATransform3D).m22,
                                                                            initialVelocity : startingVelocity.x,
                                                                            angularFrequency : angularFrequency,
                                                                            dampingRatio : dampingRatio)[SpringAnimationKey.CGFloat]
            
            springs[SpringAnimationKey.M23] = self.m23.interpolationSprings((toValue as! CATransform3D).m23,
                                                                            initialVelocity : startingVelocity.x,
                                                                            angularFrequency : angularFrequency,
                                                                            dampingRatio : dampingRatio)[SpringAnimationKey.CGFloat]
            
            springs[SpringAnimationKey.M24] = self.m24.interpolationSprings((toValue as! CATransform3D).m24,
                                                                            initialVelocity : startingVelocity.x,
                                                                            angularFrequency : angularFrequency,
                                                                            dampingRatio : dampingRatio)[SpringAnimationKey.CGFloat]
            
            springs[SpringAnimationKey.M31] = self.m31.interpolationSprings((toValue as! CATransform3D).m31,
                                                                            initialVelocity : startingVelocity.x,
                                                                            angularFrequency : angularFrequency,
                                                                            dampingRatio : dampingRatio)[SpringAnimationKey.CGFloat]
            springs[SpringAnimationKey.M32] = self.m32.interpolationSprings((toValue as! CATransform3D).m32,
                                                                            initialVelocity : startingVelocity.x,
                                                                            angularFrequency : angularFrequency,
                                                                            dampingRatio : dampingRatio)[SpringAnimationKey.CGFloat]
            
            springs[SpringAnimationKey.M33] = self.m33.interpolationSprings((toValue as! CATransform3D).m34,
                                                                            initialVelocity : startingVelocity.x,
                                                                            angularFrequency : angularFrequency,
                                                                            dampingRatio : dampingRatio)[SpringAnimationKey.CGFloat]
            
            springs[SpringAnimationKey.M34] = self.m34.interpolationSprings((toValue as! CATransform3D).m34,
                                                                            initialVelocity : startingVelocity.x,
                                                                            angularFrequency : angularFrequency,
                                                                            dampingRatio : dampingRatio)[SpringAnimationKey.CGFloat]
            
            springs[SpringAnimationKey.M41] = self.m41.interpolationSprings((toValue as! CATransform3D).m41,
                                                                            initialVelocity : startingVelocity.x,
                                                                            angularFrequency : angularFrequency,
                                                                            dampingRatio : dampingRatio)[SpringAnimationKey.CGFloat]
            springs[SpringAnimationKey.M42] = self.m42.interpolationSprings((toValue as! CATransform3D).m42,
                                                                            initialVelocity : startingVelocity.x,
                                                                            angularFrequency : angularFrequency,
                                                                            dampingRatio : dampingRatio)[SpringAnimationKey.CGFloat]
            
            springs[SpringAnimationKey.M43] = self.m43.interpolationSprings((toValue as! CATransform3D).m43,
                                                                            initialVelocity : startingVelocity.x,
                                                                            angularFrequency : angularFrequency,
                                                                            dampingRatio : dampingRatio)[SpringAnimationKey.CGFloat]
            
            springs[SpringAnimationKey.M44] = self.m44.interpolationSprings((toValue as! CATransform3D).m44,
                                                                            initialVelocity : startingVelocity.x,
                                                                            angularFrequency : angularFrequency,
                                                                            dampingRatio : dampingRatio)[SpringAnimationKey.CGFloat]
        }
        
        return springs
    }

    public func valueRepresentation() -> AnyObject {
        return NSValue(CATransform3D :  self)
    }
}

