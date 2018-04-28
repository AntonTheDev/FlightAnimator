//
//  CGRect+AnimatableProperty.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 4/23/18.
//  Copyright © 2018 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

extension CGRect : FAAnimatable
{
    
    public var valueType : FAValueType {
        get {
            return .cgRect
        }
    }
    
    public var zeroVelocityValue : FAAnimatable {
        get {
            return CGRect.zero
        }
    }
    
    public func progressValue<T>(to value : FAAnimatable, atProgress progress : CGFloat) -> T {
        
        if let value = value as? CGRect {
            
            var adjustedRect = CGRect.zero
            
            adjustedRect.size = size.progressValue(to: value.size, atProgress: progress)
            adjustedRect.origin = origin.progressValue(to: value.origin, atProgress: progress)
            
            return adjustedRect as! T
        }
        
        return CGRect.zero as! T
    }
    
    public func scaledValue(to scale : CGFloat) -> CGRect {
        return scaledValue(bounds : scale, origin : scale)
    }
    
    public func scaledValue(bounds sizeScale : CGFloat, origin originScale : CGFloat) -> CGRect {
        
        var adjustedRect    = CGRect.zero
        
        adjustedRect.size   = size.scaledValue(width : sizeScale, height : sizeScale)
        adjustedRect.origin = origin.scaledValue(x : originScale, y : originScale)
        
        return adjustedRect
    }
    
    public var magnitude : CGFloat {
        get {
            let totalValue = (width * width) + (height * height) + (origin.x * origin.x) + (origin.y * origin.y)
            return sqrt(totalValue)
        }
    }
    
    public var valueRepresentation : AnyObject {
        get {
            return NSValue(cgRect: self)
        }
    }
    
    public var vector : [CGFloat] {
        get {
            return  [origin.x, origin.y, width, height]
        }
    }
    
    public func valueFromComponents<T>(_ vector :  [CGFloat]) -> T {
        return CGRect(x : vector[0], y : vector[1], width : vector[2], height : vector[3]) as! T
    }
}
