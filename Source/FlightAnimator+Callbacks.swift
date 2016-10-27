//
//  CAAnimation+FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore


public typealias FAAnimationDidStart = ((_ anim: CAAnimation) -> Void)
public typealias FAAnimationDidStop  = ((_ anim: CAAnimation, _ complete: Bool) -> Void)

#if swift(>=2.3)
    
    public class FAAnimationDelegate : NSObject, CAAnimationDelegate {
        
        var animationDidStart : FAAnimationDidStart?
        var animationDidStop : FAAnimationDidStop?
        
        public func animationDidStart(_ anim: CAAnimation) {
            if let startCallback = animationDidStart {
                startCallback(anim)
            }
        }
        
        public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            if let stopCallback = animationDidStop {
                stopCallback(anim, flag)
            }
        }
        
        public func setDidStopCallback(stopCallback : @escaping FAAnimationDidStop) {
            animationDidStop = stopCallback
        }
        
        public func setDidStartCallback(startCallback : @escaping FAAnimationDidStart) {
            animationDidStart = startCallback
        }
    }
    
#else
    
    open class FAAnimationDelegate : NSObject {
    
    var animationDidStart : FAAnimationDidStart?
    var animationDidStop : FAAnimationDidStop?
    
    open override func animationDidStart(_ anim: CAAnimation) {
    if let startCallback = animationDidStart {
    startCallback(anim : anim)
    }
    }
    
    open override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if let stopCallback = animationDidStop {
    stopCallback(anim : anim, complete: flag)
    }
    }
    
    open func setDidStopCallback(_ stopCallback : FAAnimationDidStop) {
    animationDidStop = stopCallback
    }
    
    open func setDidStartCallback(_ startCallback : FAAnimationDidStart) {
    animationDidStart = startCallback
    }
    }
    
#endif

public extension CAAnimation {
    
    public func setDidStopCallback(_ stopCallback : @escaping FAAnimationDidStop) {
        
        if callbacksSupported() == false {
            print("DidStopCallbacks are not supported for \(self)")
        }
        
        var activeDelegate : FAAnimationDelegate?
        
        if let currentDelegate = delegate as? FAAnimationDelegate {
            activeDelegate = currentDelegate
        } else {
            activeDelegate = FAAnimationDelegate()
        }
        
        activeDelegate!.setDidStopCallback { (anim, complete) in
            if let _ = self.delegate as? FAAnimationDelegate {
                stopCallback(anim, complete)
            }
        }
        
        delegate = activeDelegate
    }
    
    public func setDidStartCallback(_ startCallback : @escaping FAAnimationDidStart) {
        
        if callbacksSupported() == false {
            print("DidStartCallback are not supported for \(self)")
        }
        
        var activeDelegate : FAAnimationDelegate?
        
        if let currentDelegate = delegate as? FAAnimationDelegate {
            activeDelegate = currentDelegate
        } else {
            activeDelegate = FAAnimationDelegate()
        }
        
        activeDelegate!.setDidStartCallback { (anim) in
            if let _ = self.delegate as? FAAnimationDelegate {
                startCallback(anim)
            }
        }
        
        delegate = activeDelegate
    }
    
    fileprivate func callbacksSupported() -> Bool {
        if let _ = self as? FAAnimationGroup {
        } else if let _ = self as? FABasicAnimation {
        } else{
            return false
        }
        return true
    }
}
