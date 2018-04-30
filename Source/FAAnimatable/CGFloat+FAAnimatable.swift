//
//  CGFloat+FAAnimatable.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 4/23/18.
//  Copyright © 2018 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
	switch (lhs, rhs) {
	case let (l?, r?):
		return l < r
	case (nil, _?):
		return true
	default:
		return false
	}
}

func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
	switch (lhs, rhs) {
	case let (l?, r?):
		return l > r
	default:
		return rhs < lhs
	}
}

func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
	switch (lhs, rhs) {
	case let (l?, r?):
		return l >= r
	default:
		return !(lhs < rhs)
	}
}

extension CGFloat : FAAnimatable
{
    public var valueType : FAValueType {
        get {
            return .cgFloat
        }
    }
    
    public var zeroVelocityValue : FAAnimatable {
        get {
            return CGFloat(0.0)
        }
    }
    
    public func valueFromComponents<T>(_ vector :  [CGFloat]) -> T {
        return CGFloat(vector[0]) as! T
    }
    
    public func progressValue<T>(to value : FAAnimatable, atProgress progress : CGFloat) -> T {
        
        if let value = value as? CGFloat {
            return self + ((value - self) * progress) as! T
        }
        
        if let valueRepresentation = value as? NSNumber {
            return self + ((CGFloat(valueRepresentation.floatValue) - self) * progress) as! T
        }
        
        return 0.0 as! T
    }
    
    public var magnitude : CGFloat {
        get {
            return self * self
        }
    }
    
    public var valueRepresentation : AnyObject {
        get {
            return NSNumber(value: Float(self))
        }
    }
    
    public var vector : [CGFloat] {
        get {
            return  [self]
        }
    }
}
