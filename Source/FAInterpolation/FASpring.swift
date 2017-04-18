//
//  FAInterpolation+SpringEngine.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 4/23/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

let CGFLT_EPSILON = CGFloat(Float.ulpOfOne)

public struct FASpring {

    fileprivate var equilibriumPosition : CGFloat
    fileprivate var angularFrequency    : CGFloat  = 10.0
    fileprivate var dampingRatio        : CGFloat  = 1.0
    fileprivate var positionVelocity    : CGFloat  = 1.0
    
    fileprivate var positionValue       : CGFloat  = 1.0
    fileprivate var positionValues      : Array<CGFloat>  = Array<CGFloat>()
    
    // Shared Constants
    fileprivate var c1 : CGFloat = 0.0
    fileprivate var c2 : CGFloat = 0.0
    
    // Over Damped Constants
    fileprivate var za : CGFloat = 0.0
    fileprivate var zb : CGFloat = 0.0
    fileprivate var z1 : CGFloat = 0.0
    fileprivate var z2 : CGFloat = 0.0
    
    // Under Damped Constants
    fileprivate var omegaZeta : CGFloat = 0.0
    fileprivate var alpha : CGFloat     = 0.0
    fileprivate var c3 : CGFloat        = 0.0
    
    /**
     Designated initializer. Initializes a Spring object stored by the Spring animation to
     calulate value in time based on the preconfigured spring at the start of the animation
     
     - parameter finalValue:   The final resting value
     - parameter initialValue: The intial v``alue in time for the animation
     - parameter velocity:     The intial velociy for the value
     - parameter frequency:    The angular frequency of the spring
     - parameter ratio:        the damping ratio of the spring
     
     - returns: Preconfigured Spring
     */
    init(finalValue: CGFloat, initialValue : CGFloat, positionVelocity velocity: CGFloat,  angularFrequency frequency: CGFloat, dampingRatio ratio: CGFloat) {
        self.dampingRatio = ratio
        self.angularFrequency = frequency
        self.equilibriumPosition = finalValue
        self.positionValue = initialValue
        self.positionVelocity = velocity
        
        if self.angularFrequency < CGFLT_EPSILON {
            print("No motion")
        }
        
        if self.dampingRatio < 0.0 {
            self.dampingRatio = 0.0
        }
        
        // Over Damped
        if self.dampingRatio > 1.0 + CGFLT_EPSILON {
            za = -angularFrequency * dampingRatio
            zb = angularFrequency * sqrt(dampingRatio * dampingRatio - 1.0)
            z1 = za - zb
            z2 = za + zb
            c1 = (positionVelocity - (positionValue - equilibriumPosition) * z2) / (-2.0 * zb)
            c2 = (positionValue - equilibriumPosition) - c1
        }
            // Critically Damped
        else if (self.dampingRatio > 1.0 - CGFLT_EPSILON) {
            c1 = positionVelocity + angularFrequency * (positionValue - equilibriumPosition)
            c2 = (positionValue - equilibriumPosition)
        }
            // Under Damped
        else {
            omegaZeta  = angularFrequency * dampingRatio
            alpha  = angularFrequency * sqrt(1.0 - dampingRatio * dampingRatio)
            c1 = (positionValue - equilibriumPosition)
            c2 = (positionVelocity + omegaZeta * (positionValue - equilibriumPosition)) / alpha
        }
    }
    
    /**
     This method calculates the current CGFLoat value in time based on the configuration of the
     spring at initialization
     
     - parameter deltaTime: The current time interval for the animation
     
     - returns: The current value in time, based on the velocity, angular frequency and damping
     */
    func updatedValue(_ deltaTime: CGFloat) -> CGFloat {
        
        // Over Damped
        if dampingRatio > 1.0 + CGFLT_EPSILON {
            let expTerm1 = exp(z1 * deltaTime)
            let expTerm2 = exp(z2 * deltaTime)
            let position = equilibriumPosition + c1 * expTerm1 + c2 * expTerm2
            
            return position
        }
            // Critically Damped
        else if (dampingRatio > 1.0 - CGFLT_EPSILON) {
            let expTerm = exp( -angularFrequency * deltaTime )
            let c3 = (c1 * deltaTime + c2) * expTerm
            let p = equilibriumPosition + c3
            return ceil(p)
        }
            // Under Damped
        else {
            let change  = alpha * deltaTime
            let expTerm  = exp( -omegaZeta * deltaTime)
            let cosTerm  = cos(change)
            let sinTerm  = sin(change)
            let exp2 =  expTerm * (c1 * cosTerm + c2 * sinTerm)
            return equilibriumPosition + exp2
        }
    }
    
    /**
     When a spring animation A is in motion, and is replaced by animation B in motion,
     we candetermine the current velocity of the animating CGFloat value in time.
     
     The time difference is derived by subtacting the start time of the layer in animation A
     from the current layer time
     
     - parameter deltaTime: The time difference from the start time of the animation
     
     - returns: The current velocity of the single CGFoloat value animating
     */
    func velocity(_ deltaTime : CGFloat) -> CGFloat {
        // Over Damped
        if dampingRatio > 1.0 + CGFLT_EPSILON {
            let expTerm1 = exp(z1 * deltaTime)
            let expTerm2 = exp(z2 * deltaTime)
            return c1 * z1 *  expTerm1 + c2 * z2 * expTerm2
        }
            // Critically Damped
        else if (dampingRatio > 1.0 - CGFLT_EPSILON) {
            let expTerm = exp( -angularFrequency * deltaTime )
            let c3 = (c1 * deltaTime + c2) * expTerm
            return (c1 * expTerm) - (c3 * self.angularFrequency)
        }
            // Under Damped
        else {
            let change  = alpha * deltaTime
            let expTerm  = exp( -omegaZeta * deltaTime)
            let cosTerm  = cos(change)
            let sinTerm  = sin(change)
            return -expTerm * ((c1 * omegaZeta - c2 * alpha) * cosTerm + (c1 * alpha + c2 * omegaZeta) * sinTerm)
        }
    }
}
