//
//  FAAnimatable.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import QuartzCore

public struct SpringAnimationKey {
    static var CGFloat          = "CGFloatKey"
    static var CGPointX         = "CGPointX"
    static var CGPointY         = "CGPointY"
    static var CGSizeWidth      = "CGSizeWidth"
    static var CGSizeHeight     = "CGSizeHeight"
    
    static var M11     = "M11"
    static var M12     = "M12"
    static var M13     = "M13"
    static var M14     = "M14"
    
    static var M21     = "M21"
    static var M22     = "M22"
    static var M23     = "M23"
    static var M24     = "M24"
    
    static var M31     = "M31"
    static var M32     = "M32"
    static var M33     = "M33"
    static var M34     = "M34"
    
    static var M41     = "M41"
    static var M42     = "M42"
    static var M43     = "M43"
    static var M44     = "M44"
    
    static var CGColorHue          = "CGColorHue"
    static var CGColorSaturation   = "CGColorSaturation"
    
    static var CGColorBrightness   = "CGColorBrightness"
    static var CGColorHSBAlpha     = "CGColorHSBAlpha"
    static var CGColorRed          = "CGColorRed"
    static var CGColorGreen        = "CGColorGreen"
    
    static var CGColorBlue         = "CGColorBlue"
    static var CGColorRGBAlpha     = "CGColorRGBAlpha"
    static var CGColorWhite        = "CGColorWhite"
    static var CGColorWhiteAlpha   = "CGColorWhiteAlpha"
}

public protocol FAAnimatable : Equatable {
    associatedtype T
    
    // Magnitude Calculations
    func magnitudeValue() -> CGFloat
    
    func magnitudeToValue<T : FAAnimatable>(toValue:  T) -> CGFloat
    
    // Parametric Interpolation
    func interpolatedValue<T : FAAnimatable>(toValue : T, progress : CGFloat) ->  AnyObject
    
    // Calculates the value at delta time
    func interpolatedSpringValue<T : FAAnimatable>(toValue : T, springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> AnyObject
    
    // Calculates the value at delta time
    func springVelocity(springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> CGPoint
    
    // Generate a dictionary of FASpring instances per dimension of the animatable value
    func interpolationSprings<T : FAAnimatable>(toValue : T,
                              initialVelocity : Any,
                              angularFrequency : CGFloat,
                              dampingRatio : CGFloat) -> Dictionary<String, FASpring>
    
    // Returns a core animation value representation
    func valueRepresentation() -> AnyObject
}