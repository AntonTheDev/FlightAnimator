//
//  CATransform3d+FAAnimatable.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 4/23/18.
//  Copyright © 2018 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

extension CATransform3D : FAAnimatable
{
    public var valueType : FAValueType {
        get {
            return .caTransform3d
        }
    }
    
    public var zeroVelocityValue : FAAnimatable {
        get {
            return CATransform3DIdentity
        }
    }
    
    public var magnitude : CGFloat {
        get {
            var totalValue = m11.magnitude + m12.magnitude + m13.magnitude + m14.magnitude
           
            totalValue = totalValue + m21.magnitude + m22.magnitude + m23.magnitude + m24.magnitude
            totalValue = totalValue + m31.magnitude + m32.magnitude + m33.magnitude + m34.magnitude
            totalValue = totalValue + m41.magnitude + m42.magnitude + m43.magnitude + m44.magnitude
            
            return sqrt(totalValue)
        }
    }
    
    public var valueRepresentation : AnyObject {
        get {
            return NSValue(caTransform3D:self)
        }
    }
    
    public var vector : [CGFloat] {
        get {
            return  [m11, m12, m13, m14,
                     m21, m22, m23, m24,
                     m31, m32, m33, m34,
                     m41, m42, m43, m44]
        }
    }
    
    public func valueFromComponents<T>(_ vector :  [CGFloat]) -> T
    {
        return CATransform3D(m11: vector[0], m12: vector[1], m13: vector[2], m14: vector[3],
                             m21: vector[4], m22: vector[5], m23: vector[6], m24: vector[7],
                             m31: vector[8], m32: vector[9], m33: vector[10], m34: vector[11],
                             m41: vector[12], m42: vector[13], m43: vector[14], m44: vector[15]) as! T
    }
    
    public func progressValue<T>(to value : T, atProgress progress : CGFloat) -> T
    {
        if let toTransform = value as? CATransform3D
        {
            let m11Difference : CGFloat = m11.progressValue(to: toTransform.m11, atProgress: progress)
            let m12Difference : CGFloat = m12.progressValue(to: toTransform.m12, atProgress: progress)
            let m13Difference : CGFloat = m13.progressValue(to: toTransform.m13, atProgress: progress)
            let m14Difference : CGFloat = m14.progressValue(to: toTransform.m14, atProgress: progress)
            
            let m21Difference : CGFloat = m21.progressValue(to: toTransform.m21, atProgress: progress)
            let m22Difference : CGFloat = m22.progressValue(to: toTransform.m22, atProgress: progress)
            let m23Difference : CGFloat = m23.progressValue(to: toTransform.m23, atProgress: progress)
            let m24Difference : CGFloat = m24.progressValue(to: toTransform.m24, atProgress: progress)
            
            let m31Difference : CGFloat = m31.progressValue(to: toTransform.m31, atProgress: progress)
            let m32Difference : CGFloat = m32.progressValue(to: toTransform.m32, atProgress: progress)
            let m33Difference : CGFloat = m33.progressValue(to: toTransform.m33, atProgress: progress)
            let m34Difference : CGFloat = m34.progressValue(to: toTransform.m34, atProgress: progress)
            
            let m41Difference : CGFloat = m41.progressValue(to: toTransform.m41, atProgress: progress)
            let m42Difference : CGFloat = m42.progressValue(to: toTransform.m42, atProgress: progress)
            let m43Difference : CGFloat = m43.progressValue(to: toTransform.m43, atProgress: progress)
            let m44Difference : CGFloat = m44.progressValue(to: toTransform.m44, atProgress: progress)
            
            return CATransform3D(m11: m11Difference, m12: m12Difference, m13: m13Difference, m14: m14Difference,
                                 m21: m21Difference, m22: m22Difference, m23: m23Difference, m24: m24Difference,
                                 m31: m31Difference, m32: m32Difference, m33: m33Difference, m34: m34Difference,
                                 m41: m41Difference, m42: m42Difference, m43: m43Difference, m44: m44Difference) as! T
        }
        
        return CGAffineTransform.identity as! T
    }
}
