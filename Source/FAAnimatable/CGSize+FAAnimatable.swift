//
//  CGSize+AnimatableProperty.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 4/23/18.
//  Copyright © 2018 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

extension CGSize : FAAnimatable
{
    public var valueType : FAValueType {
        get {
            return .cgSize
        }
    }
    
    public var zeroVelocityValue : FAAnimatable {
        get {
            return CGSize.zero
        }
    }
    
    public var magnitude : CGFloat {
        get {
            let totalValue = (width * width) + (height * height)
            return sqrt(totalValue)
        }
    }
    
    public var valueRepresentation : AnyObject {
        get {
            return NSValue(cgSize: self)
        }
    }
    
    public var vector : [CGFloat] {
        get {
            return  [width, height]
        }
    }
    
    public func valueFromComponents<T>(_ vector :  [CGFloat]) -> T
    {
        return CGSize(width : vector[0], height : vector[1]) as! T
    }
    
    public func progressValue<T>(to value : T, atProgress progress : CGFloat) -> T
    {
        if let value = value as? CGSize
        {
            let widthDifference  : CGFloat = width.progressValue(to: value.width, atProgress: progress)
            let heightDifference : CGFloat = height.progressValue(to: value.height, atProgress: progress)
            return CGSize(width : widthDifference, height : heightDifference) as! T
        }
        
        return CGSize.zero as! T
    }
}

extension CGSize
{
    public func scaledValue(to scale : CGFloat) -> CGSize
    {
        return scaledValue(width : scale, height : scale)
    }
    
    public func scaledValue(width widthScale : CGFloat, height heightScale : CGFloat) -> CGSize
    {
        return CGSize(width :  width * widthScale, height :  height * heightScale)
    }
}
