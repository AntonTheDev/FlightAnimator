//
//  CGPath+FAAnimatable.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 4/25/18.
//  Copyright © 2018 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit
/*
extension CGPath : FAAnimatable
{
    public var zeroVelocityValue : FAAnimatable {
        get {
            return UIBezierPath().cgPath
        }
    }
    
    public func progressValue<T>(to value : FAAnimatable, atProgress progress : CGFloat) -> T {
        /*
        if let value = value as? CGPoint {
            let xDifference : CGFloat  = x.progressValue(to: value.x, atProgress: progress)
            let yDifference : CGFloat  = y.progressValue(to: value.y, atProgress: progress)
            return CGPoint(x : xDifference, y : yDifference) as! T
        }
        */
        return UIBezierPath().cgPath as! T
    }
    
    public func valueFromComponents<T>(_ vector :  [CGFloat]) -> T {
        return CGPoint(x : vector[0], y : vector[1]) as! T
    }
    
    func progressValue(to toPoint : CGPoint, atProgress progress : CGFloat) -> CGPoint
    {
        let xDifference : CGFloat = x.progressValue(to: toPoint.x, atProgress: progress)
        let yDifference : CGFloat = y.progressValue(to: toPoint.y, atProgress: progress)
        return CGPoint(x : xDifference, y : yDifference)
    }
    
    public var magnitude : CGFloat {
        get {
            var totalValue : CGFloat = 0.0
            
            let points = self.getPathElementsPoints()
            var lastPoint : CGPoint?
            
            for point in points
            {
                if lastPoint == nil {
                    lastPoint = point
                    continue
                }
                
                totalValue = totalValue + lastPoint!.magnitude(toValue: point)
            }
        
            
            return totalValue
        }
    }
    
    public var valueRepresentation : AnyObject {
        get {
            return NSValue(cg
        }
    }
    
    public var vector : [CGFloat] {
        get {
            return  [x, y]
        }
    }
}
*/

extension CGPath {
    
    func forEach( body: @convention(block) (CGPathElement) -> Void)
    {
        typealias Body = @convention(block) (CGPathElement) -> Void
        
        let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        
        print(MemoryLayout.size(ofValue: body))
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
    }
    
    func getPathElementsPoints() -> [CGPoint]
    {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
            default: break
            }
        }
       
        return arrayPoints
    }
    
    func getPathElementsPointsAndTypes() -> ([CGPoint], [CGPathElementType])
    {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        var arrayTypes : [CGPathElementType]! = [CGPathElementType]()
        
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            default: break
            }
        }
        
        return (arrayPoints,arrayTypes)
    }
}
