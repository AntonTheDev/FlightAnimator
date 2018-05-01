//
//  CGPoint+AnimatableProperty.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 4/23/18.
//  Copyright © 2018 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint : FAAnimatable
{
    public var valueType : FAValueType {
        get {
            return .cgPoint
        }
    }
    
    public var zeroVelocityValue : FAAnimatable {
        get {
            return CGPoint.zero
        }
    }
    
    public var magnitude : CGFloat {
        get {
            let totalValue = (x * x) + (y * y)
            return sqrt(totalValue)
        }
    }
    
    public var valueRepresentation : AnyObject {
        get {
            return NSValue(cgPoint: self)
        }
    }
    
    public var vector : [CGFloat] {
        get {
            return  [x, y]
        }
    }
    
    public func valueFromComponents<T>(_ vector :  [CGFloat]) -> T
    {
        return CGPoint(x : vector[0], y : vector[1]) as! T
    }
    
    public func progressValue<T>(to value : T, atProgress progress : CGFloat) -> T
    {
        
        if let value = value as? CGPoint {
            let xDifference : CGFloat  = x.progressValue(to: value.x, atProgress: progress)
            let yDifference : CGFloat  = y.progressValue(to: value.y, atProgress: progress)
            return CGPoint(x : xDifference, y : yDifference) as! T
        }
        
        return CGPoint.zero as! T
    }
}

extension CGPoint
{
    public func scaledValue(to scale : CGFloat) -> CGPoint
    {
        return scaledValue(x : scale, y : scale)
    }
    
    public func scaledValue(x xScale : CGFloat, y yScale : CGFloat) -> CGPoint
    {
        return CGPoint(x :  x * xScale, y :  y * yScale)
    }
}
