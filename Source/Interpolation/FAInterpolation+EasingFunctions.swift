//
//  FAEasingFunction.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 4/22/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

let overshoot : CGFloat = 1.70158

public enum FAEasing : Equatable {
    case Linear
    case LinearSmooth
    case LinearSmoother
    case EaseInSine
    case EaseOutSine
    case EaseInOutSine
    case EaseOutInSine
    case EaseInQuadratic
    case EaseOutQuadratic
    case EaseInOutQuadratic
    case EaseOutInQuadratic
    case EaseInCubic
    case EaseOutCubic
    case EaseInOutCubic
    case EaseOutInCubic
    case EaseInQuartic
    case EaseOutQuartic
    case EaseInOutQuartic
    case EaseOutInQuartic
    case EaseInQuintic
    case EaseOutQuintic
    case EaseInOutQuintic
    case EaseOutInQuintic
    case EaseInExponential
    case EaseOutExponential
    case EaseInOutExponential
    case EaseOutInExponential
    case EaseInCircular
    case EaseOutCircular
    case EaseInOutCircular
    case EaseOutInCircular
    case EaseInBack
    case EaseOutBack
    case EaseInOutBack
    case EaseOutInBack
    case EaseInElastic
    case EaseOutElastic
    case EaseInOutElastic
    case EaseOutInElastic
    case EaseInBounce
    case EaseOutBounce
    case EaseInOutBounce
    case EaseOutInBounce
    case SpringDecay(velocity: Any?)
    case SpringCustom(velocity: Any?, frequency: CGFloat , ratio: CGFloat)
    
    func parametricProgress(p : CGFloat) -> CGFloat {
        switch self {
        case .Linear:
            return p
        case .LinearSmooth:
            return p * p * (3.0 - 2.0 * p)
        case .LinearSmoother:
            return  p * p * p * (p * (p * 6.0 - 15.0) + 10.0)
        case .EaseInSine:
            return sin((p - 1.0) * CGFloat(M_PI_2)) + 1.0
        case .EaseOutSine:
            return sin(p * CGFloat(M_PI_2))
        case .EaseInOutSine:
            return 0.5 * (1.0 - cos(p * CGFloat(M_PI)))
        case .EaseOutInSine:
            if (p < 0.5) {
                return 0.5 * sin(p * 2 * (CGFloat(M_PI) / 2.0))
            } else {
                return -0.5 * cos(((p * 2) - 1.0) * (CGFloat(M_PI) / 2.0)) + 1.0
            }
        case .EaseInQuadratic:
            return p * p
        case .EaseOutQuadratic:
            return -(p * (p - 2))
        case .EaseInOutQuadratic:
            if p < 0.5 {
                return 2.0 * p * p
            } else {
                return (-2.0 * p * p) + (4.0 * p) - 1.0
            }
        case .EaseOutInQuadratic:
            if (p * 2.0) < 1.0 {
                return -(0.5) * (p * 2.0) * ((p * 2.0) - 2.0);
            } else {
                let t = (p * 2.0) - 1.0
                return 0.5 * t * t + 0.5
            }
        case .EaseInCubic:
            return p * p * p
        case .EaseOutCubic:
            let f : CGFloat = (p - 1)
            return f * f * f + 1
        case .EaseInOutCubic:
            if p < 0.5 {
                return 4.0 * p * p * p
            } else {
                let f : CGFloat = ((2.0 * p) - 2.0)
                return 0.5 * f * f * f + 1.0
            }
        case .EaseOutInCubic:
            let f : CGFloat = (p * 2 - 1.0)
            return 0.5 * f * f * f + 0.5
        case .EaseInQuartic:
            return p * p * p * p
        case .EaseOutQuartic:
            let f : CGFloat = (p - 1.0)
            return f * f * f * (1.0 - p) + 1.0
        case .EaseInOutQuartic:
            if (p < 0.5) {
                return 8.0 * p * p * p * p
            } else {
                let f : CGFloat = (p - 1)
                return -8.0 * f * f * f * f + 1.0
            }
        case .EaseOutInQuartic:
            if ((p * 2.0 - 1.0) < 0.0) {
                let t = p * 2 - 1
                return -0.5 * (t * t * t * t - 1.0)
            } else {
                let t = p * 2 - 1
                return 0.5 * t * t * t * t + 0.5
            }
        case .EaseInQuintic:
            return p * p * p * p * p
        case .EaseOutQuintic:
            let f : CGFloat = (p - 1.0)
            return f * f * f * f * f + 1.0
        case .EaseInOutQuintic:
            if p < 0.5 {
                return 16.0 * p * p * p * p * p
            } else {
                let f : CGFloat = ((2.0 * p) - 2.0)
                return  0.5 * f * f * f * f * f + 1
            }
        case .EaseOutInQuintic:
            let f = p * 2.0 - 1.0
            return 0.5 * f * f * f * f * f + 0.5
        case .EaseInExponential:
            return p == 0.0 ? p : pow(2, 10.0 * (p - 1.0))
        case .EaseOutExponential:
            return (p == 1.0) ? p : 1.0 - pow(2, -10.0 * p)
        case .EaseInOutExponential:
            if p == 0.0 || p == 1.0 { return p }
            
            if p < 0.5 {
                return 0.5 * pow(2, (20.0 * p) - 10.0)
            } else  {
                return -0.5 * pow(2, (-20.0 * p) + 10.0) + 1.0
            }
        case .EaseOutInExponential:
            if p == 1.0 {
                return 0.5
            }
            
            if (p < 0.5) {
                return 0.5 * (1 - pow(2, -10.0 * p * 2.0))
            } else {
                return 0.5 * pow(2, 10.0 * (((p * 2.0) - 1.0) - 1.0)) + 0.5
            }
        case .EaseInCircular:
            return 1 - sqrt(1 - (p * p))
        case .EaseOutCircular:
            return sqrt((2 - p) * p)
        case .EaseInOutCircular:
            if p < 0.5 {
                return 0.5 * (1 - sqrt(1 - 4 * (p * p)))
            } else {
                return 0.5 * (sqrt(-((2 * p) - 3) * ((2 * p) - 1)) + 1)
            }
        case .EaseOutInCircular:
            let f = p * 2.0 - 1.0
            if (f < 0.0) {
                return 0.5 * sqrt(1 - f * f)
            } else {
                return -(0.5) * (sqrt(1.0 - f * f) - 1.0) + 0.5;
            }
        case .EaseInBack:
            return p * p * ((overshoot + 1.0) * p - overshoot)
        case .EaseOutBack:
            let f : CGFloat = p - 1.0
            return f * f * ((overshoot + 1.0) * f + overshoot) + 1.0
        case .EaseInOutBack:
            if p < 0.5  {
                let f : CGFloat = 2 * p
                return 0.5 * (f * f * f - f * sin(f * CGFloat(M_PI)))
            } else {
                let f : CGFloat = (1.0 - (2.0 * p - 1.0))
                let calculated = (f * f * f - f * sin(f * CGFloat(M_PI)))
                return 0.5 * (1.0 - calculated) + 0.5
            }
        case .EaseOutInBack:
            if p < 0.5  {
                let f : CGFloat =  p / 2.0
                return 0.5 * (f * f * f - f * sin(f * CGFloat(M_PI)))
            } else {
                let f : CGFloat = (1.0 - (2.0 * p - 1.0))
                let calculated = (f * f * f - f * sin(f * CGFloat(M_PI)))
                return 0.5 * (1.0 - calculated) + 0.5
            }
        case .EaseInElastic:
            return sin(13 * CGFloat(M_PI_2) * p) * pow(2, 10 * (p - 1))
        case .EaseOutElastic:
            return sin(-13 * CGFloat(M_PI_2) * (p + 1)) * pow(2, -10 * p) + 1
        case .EaseInOutElastic:
            if p < 0.5  {
                return 0.5 * sin(13.0 * CGFloat(M_PI_2) * (2.0 * p)) * pow(2, 10.0 * ((2.0 * p) - 1.0))
            } else {
                return 0.5 * (sin(-13.0 * CGFloat(M_PI_2) * ((2.0 * p - 1.0) + 1.0)) * pow(2, -10.0 * (2.0 * p - 1.0)) + 2.0)
            }
        case .EaseOutInElastic:
            if p < 0.5  {
                return 0.5 * (sin(-13.0 * CGFloat(M_PI_2) * ((2.0 * p - 1.0) + 1.0)) * pow(2, -10.0 * (2.0 * p - 1.0)) + 2.0)
            } else {
                return 0.5 * sin(13.0 * CGFloat(M_PI_2) * (2.0 * p)) * pow(2, 10.0 * ((2.0 * p) - 1.0))
            }
        case .EaseInBounce:
            return 1.0 - FAEasing.EaseOutBounce.parametricProgress(1.0 - p)
        case .EaseOutBounce:
            if(p < 4.0/11.0) {
                return (121.0 * p * p)/16.0;
            } else if(p < 8.0/11.0) {
                return (363.0/40.0 * p * p) - (99.0/10.0 * p) + 17.0/5.0;
            } else if(p < 9.0/10.0) {
                return (4356.0/361.0 * p * p) - (35442.0/1805.0 * p) + 16061.0/1805.0;
            }else {
                return (54.0/5.0 * p * p) - (513.0/25.0 * p) + 268.0/25.0;
            }
        case .EaseInOutBounce:
            if(p < 0.5) {
                return 0.5 * FAEasing.EaseInBounce.parametricProgress(p * 2.0);
            } else{
                return 0.5 * FAEasing.EaseOutBounce.parametricProgress(p * 2.0 - 1.0) + 0.5;
            }
        case .EaseOutInBounce:
            if(p < 0.5) {
                return 0.5 * FAEasing.EaseOutBounce.parametricProgress(p / 2.0);
            } else{
                return 0.5 * FAEasing.EaseInBounce.parametricProgress(p * 2.0 - 1.0) + 0.5;
            }
        case SpringCustom(_, _ , _):
            print("Assigned SpringCustom")
            return p
        case .SpringDecay(_):
            print("SpringDecay")
            return p
        }
    }
}

public func ==(lhs : FAEasing, rhs : FAEasing) -> Bool {
    switch lhs {
    case .Linear:
        switch rhs { case .Linear: return true default: return false }
    case .LinearSmooth:
        switch rhs { case .LinearSmooth: return true default: return false }
    case .LinearSmoother:
        switch rhs { case .LinearSmoother: return true default: return false }
    case .EaseInSine:
        switch rhs { case .EaseInSine: return true default: return false }
    case .EaseOutSine:
        switch rhs { case .EaseOutSine: return true default: return false }
    case .EaseInOutSine:
        switch rhs { case .EaseInOutSine: return true default: return false }
    case .EaseOutInSine:
        switch rhs { case .EaseOutInSine: return true default: return false }
    case .EaseInQuadratic:
        switch rhs { case .EaseInQuadratic: return true default: return false }
    case .EaseOutQuadratic:
        switch rhs { case .EaseOutQuadratic: return true default: return false }
    case .EaseInOutQuadratic:
        switch rhs { case .EaseInOutQuadratic: return true default: return false }
    case .EaseOutInQuadratic:
        switch rhs { case .EaseOutInQuadratic: return true default: return false }
    case .EaseInCubic:
        switch rhs { case .EaseInCubic: return true default: return false }
    case .EaseOutCubic:
        switch rhs { case .EaseOutCubic: return true default: return false }
    case .EaseInOutCubic:
        switch rhs { case .EaseInOutCubic: return true default: return false }
    case .EaseOutInCubic:
        switch rhs { case .EaseOutInCubic: return true default: return false }
    case .EaseInQuartic:
        switch rhs { case .EaseInQuartic: return true default: return false }
    case .EaseOutQuartic:
        switch rhs { case .EaseOutQuartic: return true default: return false }
    case .EaseInOutQuartic:
        switch rhs { case .EaseInOutQuartic: return true default: return false }
    case .EaseOutInQuartic:
        switch rhs { case .EaseOutInQuartic: return true default: return false }
    case .EaseInQuintic:
        switch rhs { case .EaseInQuintic: return true default: return false }
    case .EaseOutQuintic:
        switch rhs { case .EaseOutQuintic: return true default: return false }
    case .EaseInOutQuintic:
        switch rhs { case .EaseInOutQuintic: return true default: return false }
    case .EaseOutInQuintic:
        switch rhs { case .EaseOutInQuintic: return true default: return false }
    case .EaseInExponential:
        switch rhs { case .EaseInExponential: return true default: return false }
    case .EaseOutExponential:
        switch rhs { case .EaseOutExponential: return true default: return false }
    case .EaseInOutExponential:
        switch rhs { case .EaseInOutExponential: return true default: return false }
    case .EaseOutInExponential:
        switch rhs { case .EaseOutInExponential: return true default: return false }
    case .EaseInCircular:
        switch rhs { case .EaseInCircular: return true default: return false }
    case .EaseOutCircular:
        switch rhs { case .EaseOutCircular: return true default: return false }
    case .EaseInOutCircular:
        switch rhs { case .EaseInOutCircular: return true default: return false }
    case .EaseOutInCircular:
        switch rhs { case .EaseOutInCircular: return true default: return false }
    case .EaseInBack:
        switch rhs { case .EaseInBack: return true default: return false }
    case .EaseOutBack:
        switch rhs { case .EaseOutBack: return true default: return false }
    case .EaseInOutBack:
        switch rhs { case .EaseInOutBack: return true default: return false }
    case .EaseOutInBack:
        switch rhs { case .EaseOutInBack: return true default: return false }
    case .EaseInElastic:
        switch rhs { case .EaseInElastic: return true default: return false }
    case .EaseOutElastic:
        switch rhs { case .EaseOutElastic: return true default: return false }
    case .EaseInOutElastic:
        switch rhs { case .EaseInOutElastic: return true default: return false }
    case .EaseOutInElastic:
        switch rhs { case .EaseOutInElastic: return true default: return false }
    case .EaseInBounce:
        switch rhs { case .EaseInBounce: return true default: return false }
    case .EaseOutBounce:
        switch rhs { case .EaseOutBounce: return true default: return false }
    case .EaseInOutBounce:
        switch rhs { case .EaseInOutBounce: return true default: return false }
    case .EaseOutInBounce:
        switch rhs { case .EaseOutInBounce: return true default: return false }
    case .SpringCustom(_, _ , _):
        switch rhs { case .SpringCustom(_, _ , _): return true default: return false }
    case .SpringDecay(_):
        switch rhs { case .SpringDecay(_): return true default: return false }
    }
}

