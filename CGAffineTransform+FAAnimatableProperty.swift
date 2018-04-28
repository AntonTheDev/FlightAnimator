//
//  CGAffineTransform+AnimatableProperty.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 4/23/18.
//  Copyright © 2018 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

extension CGAffineTransform : FAAnimatableProperty
{
    public var zeroVelocityValue : FAAnimatableProperty {
        get {
            return CGAffineTransform.identity
        }
    }
    
    public func progressValue<T>(to value : FAAnimatableProperty, atProgress progress : CGFloat) -> T
    {
        if let toTransform = value as? CGAffineTransform
        {
            let aDifference  = a.progressValue(to: toTransform.a, atProgress: progress)
            let bDifference  = b.progressValue(to: toTransform.b, atProgress: progress)
            let cDifference  = c.progressValue(to: toTransform.c, atProgress: progress)
            let dDifference  = d.progressValue(to: toTransform.d, atProgress: progress)
            let txDifference = tx.progressValue(to: toTransform.tx, atProgress: progress)
            let tyDifference = ty.progressValue(to: toTransform.ty, atProgress: progress)
            
            return CGAffineTransform(a: aDifference, b: bDifference, c: cDifference, d: dDifference, tx: txDifference, ty: tyDifference) as! T
        }
        
        return CGAffineTransform.identity as! T
    }
    
    public var magnitude : CGFloat {
        get {
            let totalValue = (a * a) + (b * b) + (c * c) + (d * d) + (tx * tx) + (ty * ty)
            return sqrt(totalValue)
        }
    }
    
    public var valueRepresentation : AnyObject {
        get {
            return NSValue(cgAffineTransform: self)
        }
    }
    
    public var vector : [CGFloat] {
        get {
            return  [a, b, c, d, tx, ty]
        }
    }
    
    public func valueFromComponents<T>(_ vector :  [CGFloat]) -> T {
        return self as! T
    }
}
