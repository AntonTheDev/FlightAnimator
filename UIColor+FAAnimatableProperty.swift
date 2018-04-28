//
//  UIColor+FAAnimatableProperty.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 4/23/18.
//  Copyright © 2018 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

extension UIColor : FAAnimatableProperty
{
    public var zeroVelocityValue : FAAnimatableProperty {
        get {
            return UIColor()
        }
    }
    
    public func progressValue<T>(to value : FAAnimatableProperty, atProgress progress : CGFloat) -> T {
        
        if let toColor = value as? UIColor
        {
            return UIColor(cgColor: cgColor.progressValue(to: toColor.cgColor, atProgress: progress)) as! T
        }
        
        return self as! T
    }
    
    public var magnitude : CGFloat {
        get {
            return self.cgColor.magnitude
        }
    }
    
    public var valueRepresentation : AnyObject {
        get {
            return self
        }
    }
    
    public var vector : [CGFloat] {
        get {
            return self.cgColor.vector
        }
    }
    
    public func valueFromComponents<T>(_ vector :  [CGFloat]) -> T {
        return self as! T
    }
}
