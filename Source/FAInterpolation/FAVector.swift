//
//  FAVector.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 7/8/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public func -(lhs:FAVector, rhs:FAVector) -> FAVector {
    var calculatedComponents = [CGFloat]()
    
    for index in 0..<lhs.components.count {
        let vectorDiff = lhs.components[index] - rhs.components[index]
        calculatedComponents.append(vectorDiff)
    }
    
    return FAVector(comps: calculatedComponents)
}

public func ==(lhs:FAVector, rhs:FAVector) -> Bool {
    for index in 0..<lhs.components.count {
        if lhs.components[index] != rhs.components[index] {
            return false
        }
    }
    
    return true
}

/// FAValue class. Contains a vectorized version of an Interpolatable type.
open class FAVector : Equatable {
    
    var components: [CGFloat] = [CGFloat]()
    var value : Any?
    init() { }
    
    convenience public init(comps : [CGFloat]) {
        self.init()
        self.components = comps
    }
    
    public init(value : Any) {
        
        self.value = value
        
        if let currentValue = value as? CGPoint {
            components = [currentValue.x, currentValue.y]
            return
        }
        else  if let currentValue = value as? CGSize {
            components = [currentValue.width, currentValue.height]
            return
        }
        else  if let currentValue = value as? CGRect {
            components = [currentValue.origin.x, currentValue.origin.y, currentValue.width, currentValue.height]
            return
        }
        else  if let currentValue = value as? CGFloat {
            components = [currentValue]
            return
        }
        else  if let currentValue = value as? CATransform3D {
            components = [currentValue.m11, currentValue.m12, currentValue.m13, currentValue.m14,
                          currentValue.m21, currentValue.m22, currentValue.m23, currentValue.m24,
                          currentValue.m31, currentValue.m32, currentValue.m33, currentValue.m34,
                          currentValue.m41, currentValue.m42, currentValue.m43, currentValue.m44]
            return
        }
        else if CFGetTypeID(value as AnyObject) == CGColor.typeID {
            let color = UIColor(cgColor : value as! CGColor)
          
            if let colorspace = color.cgColor.colorSpace?.model, colorspace == .monochrome {
                var white: CGFloat = 0, alpha: CGFloat = 0
                
                if color.getWhite(&white, alpha: &alpha) {
                    components = [white, alpha]
                    return
                }
            } else if let colorspace = color.cgColor.colorSpace?.model, colorspace == .rgb {
                var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
               
                if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
                    components = [red, green, blue, alpha]
                    return
                }
            } else {
                var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, HSBAlpha: CGFloat = 0
                
                if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &HSBAlpha) {
                    components = [hue, saturation, brightness, HSBAlpha]
                    return
                }
            }
        }
    
        components = [CGFloat]()
    }
    
    open func magnitudeValue() -> CGFloat {
        var totalValue : CGFloat = 0.0
        for index in 0..<components.count {
            totalValue = totalValue + (components[index] * components[index])
        }
        return sqrt(totalValue)
    }
    
    open func magnitudeToVector(_ vector : FAVector) -> CGFloat {
        return (vector - self).magnitudeValue()
    }
    
    open func valueRepresentation(_ value : Any) -> AnyObject? {
        
        if  value is CGPoint {
            let valueRepresentation = NSValue(cgPoint : CGPoint(x: components[0], y: components[1]))
            return valueRepresentation
        }
        else  if value is CGSize {
            let valueRepresentation = NSValue(cgSize : CGSize(width: components[0], height: components[1]))
            return valueRepresentation
        }
        else  if value is CGRect {
            let valueRepresentation = NSValue(cgRect : CGRect(x: components[0], y: components[1], width: components[2], height: components[3]))
            return valueRepresentation
        }
        else  if value is CGFloat {
            return components[0] as AnyObject?
        }
        else  if value is CATransform3D {
            let valueRepresentation = NSValue(caTransform3D : CATransform3D(m11: components[0],  m12: components[1],  m13: components[2],  m14: components[3],
                m21: components[4],  m22: components[5],  m23: components[6],  m24: components[7],
                m31: components[8],  m32: components[9],  m33: components[10], m34: components[11],
                m41: components[12], m42: components[13], m43: components[14], m44: components[15]))
            return valueRepresentation
        }
        else if CFGetTypeID(value as AnyObject) == CGColor.typeID {
            let color = UIColor(cgColor : value as! CGColor)
         
            if let colorspace = color.cgColor.colorSpace?.model, colorspace == .monochrome {
                 return UIColor(white: components[0], alpha: components[1]).cgColor
            }
            
            if let colorspace = color.cgColor.colorSpace?.model, colorspace == .rgb {
                return UIColor(red: components[0],  green: components[1],  blue: components[2],  alpha: components[3]).cgColor
            }
            
            var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, HSBAlpha: CGFloat = 0
            
            if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &HSBAlpha) {
                return UIColor(hue: components[0],  saturation: components[1],  brightness: components[2],  alpha: components[3]).cgColor
            }
        }
        
        return nil
    }
    
    open func typeRepresentation(_ value : Any) -> Any? {
        
        if let _ = value as? CGPoint {
            return CGPoint(x: components[0], y: components[1])
        }
        else  if let _ = value as? CGSize {
            return CGSize(width: components[0], height: components[1])
        }
        else  if let _ = value as? CGRect {
            return CGRect(x: components[0], y: components[1], width: components[2], height: components[3])
        }
        else  if let _ = value as? CGFloat {
            return components[0]
        }
        else  if let _ = value as? CATransform3D {
            return CATransform3D(m11: components[0],  m12: components[1],  m13: components[2],  m14: components[3],
                                 m21: components[4],  m22: components[5],  m23: components[6],  m24: components[7],
                                 m31: components[8],  m32: components[9],  m33: components[10], m34: components[11],
                                 m41: components[12], m42: components[13], m43: components[14], m44: components[15])
        }
        else if CFGetTypeID(value as AnyObject) == CGColor.typeID {
            let color = UIColor(cgColor : value as! CGColor)
            
            if let colorspace = color.cgColor.colorSpace?.model, colorspace == .monochrome {
                return UIColor(white: components[0], alpha: components[1]).cgColor
            }
            
            if let colorspace = color.cgColor.colorSpace?.model, colorspace == .rgb {
                return UIColor(red: components[0],  green: components[1],  blue: components[2],  alpha: components[3]).cgColor
            }
            
            var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, HSBAlpha: CGFloat = 0
            
            if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &HSBAlpha) {
                return UIColor(hue: components[0],  saturation: components[1],  brightness: components[2],  alpha: components[3]).cgColor
            }
        }
        
        return nil
    }
}
