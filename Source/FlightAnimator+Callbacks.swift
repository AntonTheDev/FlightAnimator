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

public typealias FAAnimationDelegateCallBack = ((_ anim: CAAnimation) -> Void)

public class FAAnimationDelegate : NSObject, CAAnimationDelegate {
    
    var animationDidStart  : FAAnimationDelegateCallBack?
    var animationDidStop   : FAAnimationDelegateCallBack?
    var animationDidCancel : FAAnimationDelegateCallBack?
    
    public func animationDidStart(_ anim: CAAnimation) {
        if let startCallback = animationDidStart {
            startCallback(anim)
        }
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let stopCallback = animationDidStop {
            
            if flag { stopCallback(anim) }
        }
    }
    
    public func setDidStopCallback(stopCallback : @escaping FAAnimationDelegateCallBack) {
        animationDidStop = stopCallback
    }
    
    public func setDidCanceCallback(cancelCallback : @escaping FAAnimationDelegateCallBack) {
        animationDidCancel = cancelCallback
    }
    
    public func setDidStartCallback(startCallback : @escaping FAAnimationDelegateCallBack) {
        animationDidStart = startCallback
    }
}

public extension CAAnimation {
    
    public func setDidStopCallback(_ stopCallback : @escaping FAAnimationDelegateCallBack) {
        
        if callbacksSupported() == false {
            print("DidStopCallbacks are not supported for \(self)")
        }
        
        var activeDelegate : FAAnimationDelegate?
        
        if let currentDelegate = delegate as? FAAnimationDelegate {
            activeDelegate = currentDelegate
        } else {
            activeDelegate = FAAnimationDelegate()
        }
        
        activeDelegate?.setDidStopCallback { [weak self] (anim) in
            if let _ = self?.delegate as? FAAnimationDelegate {
                stopCallback(anim)
            }
        }
        
        delegate = activeDelegate
    }
    
    public func setDidCancelCallback(_ stopCallback : @escaping FAAnimationDelegateCallBack) {
        
        if callbacksSupported() == false {
            print("DidStopCallbacks are not supported for \(self)")
        }
        
        var activeDelegate : FAAnimationDelegate?
        
        if let currentDelegate = delegate as? FAAnimationDelegate {
            activeDelegate = currentDelegate
        } else {
            activeDelegate = FAAnimationDelegate()
        }
        
        activeDelegate?.setDidCanceCallback { [weak self] (anim) in
            if let _ = self?.delegate as? FAAnimationDelegate {
                stopCallback(anim)
            }
        }
        
        delegate = activeDelegate
    }
    
    public func setDidStartCallback(_ startCallback : @escaping FAAnimationDelegateCallBack) {
        
        if callbacksSupported() == false {
            print("DidStartCallback are not supported for \(self)")
        }
        
        var activeDelegate : FAAnimationDelegate?
        
        if let currentDelegate = delegate as? FAAnimationDelegate {
            activeDelegate = currentDelegate
        } else {
            activeDelegate = FAAnimationDelegate()
        }
        
        activeDelegate?.setDidStartCallback { [weak self] (anim) in
            if let _ = self?.delegate as? FAAnimationDelegate {
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
