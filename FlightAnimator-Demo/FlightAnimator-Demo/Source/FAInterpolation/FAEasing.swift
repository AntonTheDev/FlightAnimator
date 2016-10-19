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
let CGM_PI_2 = CGFloat(M_PI_2)
let CGM_PI = CGFloat(M_PI)

public enum FAEasing : Equatable {
    case Linear
    case SmoothStep
    case SmootherStep
    case InAtan
    case OutAtan
    case InOutAtan
    case InSine
    case OutSine
    case InOutSine
    case OutInSine
    case InQuadratic
    case OutQuadratic
    case InOutQuadratic
    case OutInQuadratic
    case InCubic
    case OutCubic
    case InOutCubic
    case OutInCubic
    case InQuartic
    case OutQuartic
    case InOutQuartic
    case OutInQuartic
    case InQuintic
    case OutQuintic
    case InOutQuintic
    case OutInQuintic
    case InExponential
    case OutExponential
    case InOutExponential
    case OutInExponential
    case InCircular
    case OutCircular
    case InOutCircular
    case OutInCircular
    case InBack
    case OutBack
    case InOutBack
    case OutInBack
    case InElastic
    case OutElastic
    case InOutElastic
    case OutInElastic
    case InBounce
    case OutBounce
    case InOutBounce
    case OutInBounce
    case SpringDecay(velocity: Any?)
    case SpringCustom(velocity: Any?, frequency: CGFloat , ratio: CGFloat)
    
    func parametricProgress(p : CGFloat) -> CGFloat {
        switch self {
        case .Linear:
            return p
        case .SmoothStep:
            return p * p * (3.0 - 2.0 * p)
        case .SmootherStep:
            return  p * p * p * (p * (p * 6.0 - 15.0) + 10.0)
        case .InAtan:
            let m: CGFloat = atan(15.0)
            return atan((p - 1.0) * 15.0) / m + 1.0
        case .OutAtan:
            let m: CGFloat = atan(15.0)
            return atan(p * 15.0) / m
        case .InOutAtan:
            let m: CGFloat = atan(0.5 * 15.0)
            return atan((p - 0.5) * 15.0) / (2.0 * m) + 0.5
        case .InSine:
            return sin((p - 1.0) * CGM_PI_2) + 1.0
        case .OutSine:
            return sin(p * CGM_PI_2)
        case .InOutSine:
            return 0.5 * (1.0 - cos(p * CGM_PI))
        case .OutInSine:
            if (p < 0.5) {
                return 0.5 * sin(p * 2 * (CGM_PI / 2.0))
            } else {
                return -0.5 * cos(((p * 2) - 1.0) * (CGM_PI / 2.0)) + 1.0
            }
        case .InQuadratic:
            return p * p
        case .OutQuadratic:
            return -(p * (p - 2))
        case .InOutQuadratic:
            if p < 0.5 {
                return 2.0 * p * p
            } else {
                return (-2.0 * p * p) + (4.0 * p) - 1.0
            }
        case .OutInQuadratic:
            if (p * 2.0) < 1.0 {
                return -(0.5) * (p * 2.0) * ((p * 2.0) - 2.0);
            } else {
                let t = (p * 2.0) - 1.0
                return 0.5 * t * t + 0.5
            }
        case .InCubic:
            return p * p * p
        case .OutCubic:
            let f : CGFloat = (p - 1)
            return f * f * f + 1
        case .InOutCubic:
            if p < 0.5 {
                return 4.0 * p * p * p
            } else {
                let f : CGFloat = ((2.0 * p) - 2.0)
                return 0.5 * f * f * f + 1.0
            }
        case .OutInCubic:
            let f : CGFloat = (p * 2 - 1.0)
            return 0.5 * f * f * f + 0.5
        case .InQuartic:
            return p * p * p * p
        case .OutQuartic:
            let f : CGFloat = (p - 1.0)
            return f * f * f * (1.0 - p) + 1.0
        case .InOutQuartic:
            if (p < 0.5) {
                return 8.0 * p * p * p * p
            } else {
                let f : CGFloat = (p - 1)
                return -8.0 * f * f * f * f + 1.0
            }
        case .OutInQuartic:
            if ((p * 2.0 - 1.0) < 0.0) {
                let t = p * 2 - 1
                return -0.5 * (t * t * t * t - 1.0)
            } else {
                let t = p * 2 - 1
                return 0.5 * t * t * t * t + 0.5
            }
        case .InQuintic:
            return p * p * p * p * p
        case .OutQuintic:
            let f : CGFloat = (p - 1.0)
            return f * f * f * f * f + 1.0
        case .InOutQuintic:
            if p < 0.5 {
                return 16.0 * p * p * p * p * p
            } else {
                let f : CGFloat = ((2.0 * p) - 2.0)
                return  0.5 * f * f * f * f * f + 1
            }
        case .OutInQuintic:
            let f = p * 2.0 - 1.0
            return 0.5 * f * f * f * f * f + 0.5
        case .InExponential:
            return p == 0.0 ? p : pow(2, 10.0 * (p - 1.0))
        case .OutExponential:
            return (p == 1.0) ? p : 1.0 - pow(2, -10.0 * p)
        case .InOutExponential:
            if p == 0.0 || p == 1.0 { return p }
            
            if p < 0.5 {
                return 0.5 * pow(2, (20.0 * p) - 10.0)
            } else  {
                return -0.5 * pow(2, (-20.0 * p) + 10.0) + 1.0
            }
        case .OutInExponential:
            if p == 1.0 {
                return 0.5
            }
            
            if (p < 0.5) {
                return 0.5 * (1 - pow(2, -10.0 * p * 2.0))
            } else {
                return 0.5 * pow(2, 10.0 * (((p * 2.0) - 1.0) - 1.0)) + 0.5
            }
        case .InCircular:
            return 1 - sqrt(1 - (p * p))
        case .OutCircular:
            return sqrt((2 - p) * p)
        case .InOutCircular:
            if p < 0.5 {
                return 0.5 * (1 - sqrt(1 - 4 * (p * p)))
            } else {
                return 0.5 * (sqrt(-((2 * p) - 3) * ((2 * p) - 1)) + 1)
            }
        case .OutInCircular:
            let f = p * 2.0 - 1.0
            if (f < 0.0) {
                return 0.5 * sqrt(1 - f * f)
            } else {
                return -(0.5) * (sqrt(1.0 - f * f) - 1.0) + 0.5;
            }
        case .InBack:
            return p * p * ((overshoot + 1.0) * p - overshoot)
        case .OutBack:
            let f : CGFloat = p - 1.0
            return f * f * ((overshoot + 1.0) * f + overshoot) + 1.0
        case .InOutBack:
            if p < 0.5  {
                let f : CGFloat = 2 * p
                return 0.5 * (f * f * f - f * sin(f * CGM_PI))
            } else {
                let f : CGFloat = (1.0 - (2.0 * p - 1.0))
                let calculated = (f * f * f - f * sin(f * CGM_PI))
                return 0.5 * (1.0 - calculated) + 0.5
            }
        case .OutInBack:
            if p < 0.5  {
                let f : CGFloat =  p / 2.0
                return 0.5 * (f * f * f - f * sin(f * CGM_PI))
            } else {
                let f : CGFloat = (1.0 - (2.0 * p - 1.0))
                let calculated = (f * f * f - f * sin(f * CGM_PI))
                return 0.5 * (1.0 - calculated) + 0.5
            }
        case .InElastic:
            return sin(13 * CGM_PI_2 * p) * pow(2, 10 * (p - 1))
        case .OutElastic:
            return sin(-13 * CGM_PI_2 * (p + 1)) * pow(2, -10 * p) + 1
        case .InOutElastic:
            if p < 0.5  {
                return 0.5 * sin(13.0 * CGM_PI_2 * (2.0 * p)) * pow(2, 10.0 * ((2.0 * p) - 1.0))
            } else {
                return 0.5 * (sin(-13.0 * CGM_PI_2 * ((2.0 * p - 1.0) + 1.0)) * pow(2, -10.0 * (2.0 * p - 1.0)) + 2.0)
            }
        case .OutInElastic:
            if p < 0.5  {
                return 0.5 * (sin(-13.0 * CGM_PI_2 * ((2.0 * p - 1.0) + 1.0)) * pow(2, -10.0 * (2.0 * p - 1.0)) + 2.0)
            } else {
                return 0.5 * sin(13.0 * CGM_PI_2 * (2.0 * p)) * pow(2, 10.0 * ((2.0 * p) - 1.0))
            }
        case .InBounce:
            return 1.0 - FAEasing.OutBounce.parametricProgress(1.0 - p)
        case .OutBounce:
            if(p < 4.0/11.0) {
                return (121.0 * p * p)/16.0;
            } else if(p < 8.0/11.0) {
                return (363.0/40.0 * p * p) - (99.0/10.0 * p) + 17.0/5.0;
            } else if(p < 9.0/10.0) {
                return (4356.0/361.0 * p * p) - (35442.0/1805.0 * p) + 16061.0/1805.0;
            }else {
                return (54.0/5.0 * p * p) - (513.0/25.0 * p) + 268.0/25.0;
            }
        case .InOutBounce:
            if(p < 0.5) {
                return 0.5 * FAEasing.InBounce.parametricProgress(p * 2.0);
            } else{
                return 0.5 * FAEasing.OutBounce.parametricProgress(p * 2.0 - 1.0) + 0.5;
            }
        case .OutInBounce:
            if(p < 0.5) {
                return 0.5 * FAEasing.OutBounce.parametricProgress(p / 2.0);
            } else{
                return 0.5 * FAEasing.InBounce.parametricProgress(p * 2.0 - 1.0) + 0.5;
            }
        case SpringCustom(_, _ , _):
            print("Assigned SpringCustom")
            return p
        case .SpringDecay(_):
            print("SpringDecay")
            return p
        }
    }
    
    func isSpring() -> Bool {
        switch self {
        case SpringCustom(_, _ , _):
            return true
        case .SpringDecay(_):
            return true
        default:
            return false
        }
    }
    
    
    func reverseEasingCurve() -> FAEasing {
        switch self {
        case .Linear:
            return .Linear
        case .SmoothStep:
            return .SmoothStep
        case .SmootherStep:
            return .SmootherStep
        case .InAtan:
            return .OutAtan
        case .OutAtan:
            return .InAtan
        case .InOutAtan:
            return .InOutAtan
        case .InSine:
            return .OutSine
        case .OutSine:
            return .InSine
        case .InOutSine:
            return .OutInSine
        case .OutInSine:
            return .InOutSine
        case .InQuadratic:
            return .OutQuadratic
        case .OutQuadratic:
            return .InQuadratic
        case .InOutQuadratic:
            return .OutInQuadratic
        case .OutInQuadratic:
            return .InOutQuadratic
        case .InCubic:
            return .OutCubic
        case .OutCubic:
            return .InCubic
        case .InOutCubic:
            return .OutInCubic
        case .OutInCubic:
            return .InOutCubic
        case .InQuartic:
            return .OutQuartic
        case .OutQuartic:
            return .InQuartic
        case .InOutQuartic:
            return .OutInQuartic
        case .OutInQuartic:
            return .InOutQuartic
        case .InQuintic:
            return .OutQuintic
        case .OutQuintic:
            return .InQuintic
        case .InOutQuintic:
            return .OutInQuintic
        case .OutInQuintic:
            return .InOutQuintic
        case .InExponential:
            return .OutExponential
        case .OutExponential:
            return .InExponential
        case .InOutExponential:
            return .OutInExponential
        case .OutInExponential:
            return .InOutExponential
        case .InCircular:
            return .OutCircular
        case .OutCircular:
            return .InCircular
        case .InOutCircular:
            return .OutInCircular
        case .OutInCircular:
            return .InOutCircular
        case .InBack:
            return .OutBack
        case .OutBack:
            return .InBack
        case .InOutBack:
            return .OutInBack
        case .OutInBack:
            return .InOutBack
        case .InElastic:
            return .OutElastic
        case .OutElastic:
            return .InElastic
        case .InOutElastic:
            return .OutInElastic
        case .OutInElastic:
            return .InOutElastic
        case .InBounce:
            return .OutBounce
        case .OutBounce:
            return .InBounce
        case .InOutBounce:
            return .OutInBounce
        case .OutInBounce:
            return .InOutBounce
        case SpringCustom(_, _ , _):
            return self
        case .SpringDecay(_):
            return self
        }
    }
}


public func ==(lhs : FAEasing, rhs : FAEasing) -> Bool {
    switch lhs {
    case .Linear:
        switch rhs { case .Linear: return true default: return false }
    case .SmoothStep:
        switch rhs { case .SmoothStep: return true default: return false }
    case .SmootherStep:
        switch rhs { case .SmootherStep: return true default: return false }
    case .InSine:
        switch rhs { case .InSine: return true default: return false }
    case .OutSine:
        switch rhs { case .OutSine: return true default: return false }
    case .InOutSine:
        switch rhs { case .InOutSine: return true default: return false }
    case .OutInSine:
        switch rhs { case .OutInSine: return true default: return false }
    case .InAtan:
        switch rhs { case .InAtan: return true default: return false }
    case .OutAtan:
        switch rhs { case .OutAtan: return true default: return false }
    case .InOutAtan:
        switch rhs { case .InOutAtan: return true default: return false }
    case .InQuadratic:
        switch rhs { case .InQuadratic: return true default: return false }
    case .OutQuadratic:
        switch rhs { case .OutQuadratic: return true default: return false }
    case .InOutQuadratic:
        switch rhs { case .InOutQuadratic: return true default: return false }
    case .OutInQuadratic:
        switch rhs { case .OutInQuadratic: return true default: return false }
    case .InCubic:
        switch rhs { case .InCubic: return true default: return false }
    case .OutCubic:
        switch rhs { case .OutCubic: return true default: return false }
    case .InOutCubic:
        switch rhs { case .InOutCubic: return true default: return false }
    case .OutInCubic:
        switch rhs { case .OutInCubic: return true default: return false }
    case .InQuartic:
        switch rhs { case .InQuartic: return true default: return false }
    case .OutQuartic:
        switch rhs { case .OutQuartic: return true default: return false }
    case .InOutQuartic:
        switch rhs { case .InOutQuartic: return true default: return false }
    case .OutInQuartic:
        switch rhs { case .OutInQuartic: return true default: return false }
    case .InQuintic:
        switch rhs { case .InQuintic: return true default: return false }
    case .OutQuintic:
        switch rhs { case .OutQuintic: return true default: return false }
    case .InOutQuintic:
        switch rhs { case .InOutQuintic: return true default: return false }
    case .OutInQuintic:
        switch rhs { case .OutInQuintic: return true default: return false }
    case .InExponential:
        switch rhs { case .InExponential: return true default: return false }
    case .OutExponential:
        switch rhs { case .OutExponential: return true default: return false }
    case .InOutExponential:
        switch rhs { case .InOutExponential: return true default: return false }
    case .OutInExponential:
        switch rhs { case .OutInExponential: return true default: return false }
    case .InCircular:
        switch rhs { case .InCircular: return true default: return false }
    case .OutCircular:
        switch rhs { case .OutCircular: return true default: return false }
    case .InOutCircular:
        switch rhs { case .InOutCircular: return true default: return false }
    case .OutInCircular:
        switch rhs { case .OutInCircular: return true default: return false }
    case .InBack:
        switch rhs { case .InBack: return true default: return false }
    case .OutBack:
        switch rhs { case .OutBack: return true default: return false }
    case .InOutBack:
        switch rhs { case .InOutBack: return true default: return false }
    case .OutInBack:
        switch rhs { case .OutInBack: return true default: return false }
    case .InElastic:
        switch rhs { case .InElastic: return true default: return false }
    case .OutElastic:
        switch rhs { case .OutElastic: return true default: return false }
    case .InOutElastic:
        switch rhs { case .InOutElastic: return true default: return false }
    case .OutInElastic:
        switch rhs { case .OutInElastic: return true default: return false }
    case .InBounce:
        switch rhs { case .InBounce: return true default: return false }
    case .OutBounce:
        switch rhs { case .OutBounce: return true default: return false }
    case .InOutBounce:
        switch rhs { case .InOutBounce: return true default: return false }
    case .OutInBounce:
        switch rhs { case .OutInBounce: return true default: return false }
    case .SpringCustom(_, _ , _):
        switch rhs { case .SpringCustom(_, _ , _): return true default: return false }
    case .SpringDecay(_):
        switch rhs { case .SpringDecay(_): return true default: return false }
    }
}

