//
//  CGColor+FAAnimatable.swift
//
//
//  Created by Anton on 7/6/16.
//
//

import Foundation
import Foundation
import UIKit

public func ==(lhs:CGColor, rhs:CGColor) -> Bool {
    return CGColorEqualToColor(lhs, rhs)
}

extension CGColor : FAAnimatable {
    
    public typealias T = CGColor
    
    public func magnitudeValue() -> CGFloat {
        
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alphaRGB: CGFloat = 0
       
        if  UIColor(CGColor: self).getRed(&red, green: &green, blue: &blue, alpha: &alphaRGB) {
            return sqrt((red * red) + (green * green) +
                ((blue * blue) + (alphaRGB * alphaRGB)))
        }
        
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alphaHSB: CGFloat = 0

        if UIColor(CGColor:self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alphaHSB) {
            return sqrt((hue * hue) + (saturation * saturation) +
                ((brightness * brightness) + (alphaHSB * alphaHSB)))
        }
        
        var white: CGFloat = 0, alphaWhite: CGFloat = 0
      
        UIColor(CGColor:self).getWhite(&white, alpha: &alphaWhite)
        
        return sqrt((white * white) + (alphaWhite * alphaWhite))
    }
    
    public func magnitudeToValue<T : FAAnimatable>(toValue:  T) -> CGFloat {
        
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alphaRGB: CGFloat = 0
        var toRed: CGFloat = 0, toGreen: CGFloat = 0, toBlue: CGFloat = 0, toAlphaRGB: CGFloat = 0
        
        if  UIColor(CGColor: self).getRed(&red, green: &green, blue: &blue, alpha: &alphaRGB) &&
            UIColor(CGColor:(toValue as! CGColor)).getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlphaRGB) {
            
            return UIColor(red : red - toRed,
                           green : green - toGreen,
                           blue : blue - toBlue,
                           alpha : alphaRGB - toAlphaRGB).CGColor.magnitudeValue()
        }
        
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alphaHSB: CGFloat = 0
        var toHue: CGFloat = 0, toSaturation: CGFloat = 0, toBrightness: CGFloat = 0, toAlphaHSB: CGFloat = 0
        
        if UIColor(CGColor:self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alphaHSB) &&
           UIColor(CGColor:(toValue as! CGColor)).getHue(&toHue, saturation: &toSaturation, brightness: &toBrightness, alpha: &toAlphaHSB) {
            
            return UIColor(hue : hue - toHue,
                           saturation : saturation - toSaturation,
                           brightness : brightness - toBrightness,
                           alpha : alphaHSB - toAlphaHSB).CGColor.magnitudeValue()
        }
        
        var white: CGFloat = 0, alphaWhite: CGFloat = 0
        var toWhite: CGFloat = 0, toAlphaWhite: CGFloat = 0
        
        UIColor(CGColor:self).getWhite(&white, alpha: &alphaWhite)
        UIColor(CGColor:(toValue as! CGColor)).getWhite(&toWhite, alpha: &toAlphaWhite)
        
        return UIColor(white: white - toWhite,
                       alpha: alphaWhite - toAlphaWhite).CGColor.magnitudeValue()
    }
    
    public func interpolatedValue<T : FAAnimatable>(toValue : T, progress : CGFloat) -> AnyObject {
        
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alphaRGB: CGFloat = 0
        var toRed: CGFloat = 0, toGreen: CGFloat = 0, toBlue: CGFloat = 0, toAlphaRGB: CGFloat = 0
        
        if  UIColor(CGColor: self).getRed(&red, green: &green, blue: &blue, alpha: &alphaRGB) &&
            UIColor(CGColor:(toValue as! CGColor)).getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlphaRGB) {
            
            let interpolatedRed = interpolateCGFloat(red, end: toRed, progress: progress);
            let interpolatedGreen = interpolateCGFloat(green, end: toGreen, progress: progress);
            let interpolatedBlue = interpolateCGFloat(blue, end: toBlue, progress: progress);
            let interpolatedAlpha = interpolateCGFloat(alphaRGB, end: toAlphaRGB, progress: progress);
            
            return UIColor(red : interpolatedRed,
                           green : interpolatedGreen,
                           blue : interpolatedBlue,
                           alpha : interpolatedAlpha).CGColor
        }
        
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alphaHSB: CGFloat = 0
        var toHue: CGFloat = 0, toSaturation: CGFloat = 0, finalbrightness: CGFloat = 0, toAlphaHSB: CGFloat = 0
        
        if UIColor(CGColor:self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alphaHSB) &&
            UIColor(CGColor:(toValue as! CGColor)).getHue(&toHue, saturation: &toSaturation, brightness: &finalbrightness, alpha: &toAlphaHSB) {
            
            let interpolatedHue         = interpolateCGFloat(hue, end: toHue, progress: progress)
            let interpolatedSaturation  = interpolateCGFloat(saturation, end: toSaturation, progress: progress)
            let interpolatedBrightness  = interpolateCGFloat(brightness, end: finalbrightness, progress: progress)
            let interpolatedHSBAlpha    = interpolateCGFloat(alphaHSB, end: toAlphaHSB, progress: progress)
            
            return UIColor(hue : interpolatedHue,
                           saturation : interpolatedSaturation,
                           brightness : interpolatedBrightness,
                           alpha : interpolatedHSBAlpha).CGColor
        }
        
        var white: CGFloat = 0, alphaWhite: CGFloat = 0
        var toWhite: CGFloat = 0, toAlphaWhite: CGFloat = 0
        
        UIColor(CGColor:self).getWhite(&white, alpha: &alphaWhite)
        UIColor(CGColor:(toValue as! CGColor)).getWhite(&toWhite, alpha: &toAlphaWhite)
        
        let interpolatedWhite  = interpolateCGFloat(white, end: toWhite, progress: progress)
        let interpolatedAlpha  = interpolateCGFloat(alphaWhite, end: toAlphaWhite, progress: progress)
        
        return UIColor(white: interpolatedWhite, alpha: interpolatedAlpha)
    }
    
    public func interpolatedSpringValue<T : FAAnimatable>(toValue : T, springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> AnyObject {
        let size = CGSizeMake(springs[SpringAnimationKey.CGSizeWidth]!.updatedValue(deltaTime),
                              springs[SpringAnimationKey.CGSizeHeight]!.updatedValue(deltaTime))
        return size.valueRepresentation()
    }
    
    public func springVelocity(springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> CGPoint {
        
        if let currentWidthVelocity = springs[SpringAnimationKey.CGSizeWidth]?.velocity(deltaTime),
            let currentHeightVelocity = springs[SpringAnimationKey.CGSizeHeight]?.velocity(deltaTime) {
            return  CGPointMake(currentWidthVelocity, currentHeightVelocity)
        }
        
        return CGPointZero
    }
    
    public func interpolationSprings<T : FAAnimatable>(toValue : T, initialVelocity : Any, angularFrequency : CGFloat, dampingRatio : CGFloat) -> Dictionary<String, FASpring> {
        
        var springs = Dictionary<String, FASpring>()
        /*
         if let startingVelocity = initialVelocity as? CGPoint {
         let widthSpring = self.width.interpolationSprings((toValue as! CGSize).width, initialVelocity : startingVelocity.x, angularFrequency : angularFrequency, dampingRatio : dampingRatio)
         let heightSpring = self.height.interpolationSprings((toValue as! CGSize).height, initialVelocity : startingVelocity.y, angularFrequency : angularFrequency, dampingRatio : dampingRatio)
         
         springs[SpringAnimationKey.CGSizeWidth]  = widthSpring[SpringAnimationKey.CGFloat]
         springs[SpringAnimationKey.CGSizeHeight] = heightSpring[SpringAnimationKey.CGFloat]
         }
         */
        return springs
    }
    
    public func valueRepresentation() -> AnyObject {
        return self
    }
}



