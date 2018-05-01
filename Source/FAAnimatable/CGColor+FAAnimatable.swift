//
//  CGColor+FAAnimatable.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 4/23/18.
//  Copyright © 2018 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

extension CGColor : FAAnimatable
{
    public var valueType : FAValueType {
        get {
            return .cgColor
        }
    }
    
    public var zeroVelocityValue : FAAnimatable {
        get {
            return UIColor().cgColor
        }
    }
    
    public var magnitude : CGFloat {
        get {
            let components = componentsConfig
            let totalValue = (components.r * components.r) + (components.g * components.g) + (components.b * components.b) + (components.a * components.a)
            return sqrt(totalValue)
        }
    }
    
    public var valueRepresentation : AnyObject {
        get {
            return UIColor(cgColor: self)
        }
    }
    
    public var vector : [CGFloat] {
        get {
            let components = componentsConfig
            return  [components.r, components.g, components.b, components.a]
        }
    }
    
    public func valueFromComponents<T>(_ components :  [CGFloat]) -> T
    {
        return CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(),
                       components: [components[0], components[1], components[2], components[3]]) as! T
    }
    
    public func progressValue<T>(to value : T, atProgress progress : CGFloat) -> T
    {
        let fromComponents = self.componentsConfig
        let toComponents = (value as! CGColor).componentsConfig
        
        let r = (1 - progress) * fromComponents.r + progress * toComponents.r
        let g = (1 - progress) * fromComponents.g + progress * toComponents.g
        let b = (1 - progress) * fromComponents.b + progress * toComponents.b
        let a = (1 - progress) * fromComponents.a + progress * toComponents.a
        
        return UIColor(red: r, green: g, blue: b, alpha: a).cgColor as! T
    }
}

extension CGColor
{
    var componentsConfig: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
    {
        let comps = self.components
        
        switch comps!.count == 2 {
        case true : return (r: comps![0], g: comps![0], b: comps![0], a: comps![1])
        case false: return (r: comps![0], g: comps![1], b: comps![2], a: comps![3])
        }
    }
}
