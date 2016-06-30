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

}

public protocol FAAnimatable : Equatable {
   // associatedtype T
    
    // Magnitude Calculations
    func magnitudeValue() -> CGFloat
    
    func magnitudeToValue<T : FAAnimatable>(toValue:  T) -> CGFloat

    // Parametric Interpolation
    func interpolatedValue<T : FAAnimatable>(toValue : T, progress : CGFloat) ->  NSValue

    // Generate a dictionary of FASpringEngine per dimention of the animatable object
    func interpolationSprings<T : FAAnimatable>(toValue : T,
                              initialVelocity : Any,
                              angularFrequency : CGFloat,
                              dampingRatio : CGFloat) -> Dictionary<String, FASpring>
    
    // Calculates the value at delta time
    func interpolatedSpringValue<T : FAAnimatable>(toValue : T, springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> NSValue
    
    // Returns a core animation value representation
    func valueRepresentation() -> NSValue

    func remainingProgress <T : FAAnimatable>(toValue : T, oldFromValue: T?) -> CGFloat
    
    func getValue() -> Self
}

extension FAAnimatable {
    
    /**
     This method returns the remaining progress for the new animation, is added for the same key.
     for a parametric animation it returns the value progress, which is then used to calculate
     adjust the initial time for the new animation from the current animatable value. interpolate over
     
     To find the progress, first it calculates the magnitude from the old animation's toValue to
     the currrent value of the presentation layer. Then it calculates the magnitude of currentValue
     of the presentation layer, to the final value of the new animation.
     
     The remaining progress is then applied to the duration, and all the values are calculated
     accordingly to the parametric timing function.
     
     ||remaining|| / ||remaining|| + ||fromOldToValue||
     
     - parameter lastToValue:  the last toValue from the previous animation applied to the layer for the same key
     - parameter toValue:      the final animatable property value the new animation is to be interpolated to
     
     - returns: the progress values remaining for the new animation, relative to it's current state
     */
    public func remainingProgress <T : FAAnimatable>(toValue : T, oldFromValue: T?) -> CGFloat {
        
        if oldFromValue == toValue || oldFromValue == nil {
            return CGFloat(1.0)
        }
        
        var progress : CGFloat  = CGFloat(FLT_EPSILON)
        
        let progressedDiff = oldFromValue!.magnitudeToValue(self)
        let remainingDiff  = self.magnitudeToValue(toValue)
        
        progress  = remainingDiff / (remainingDiff + progressedDiff)
        
        if progress.isNaN {
            progress = CGFloat(1.0)
        }
        
        return  progress
    }
}