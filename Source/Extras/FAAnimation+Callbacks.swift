//
//  CAAnimation+Callbacks.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 4/22/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

public typealias FAAnimationDidStart = () -> Void
public typealias FAAnimationDidStop  = (complete : Bool) -> Void

class FAAnimationDelegate : NSObject {

    var animationDidStart : FAAnimationDidStart?
    var animationDidStop : FAAnimationDidStop?
    
    override func animationDidStart(anim: CAAnimation) {
        if let startCallback = animationDidStart {
           startCallback()
        }
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if let stopCallback = animationDidStop {
            stopCallback(complete: flag)
          
        }
        
        if let animation = anim as? FAAnimationGroup {
           // animation.weakLayer?.removeAnimationForKey(animation.animationKey!)
        }
    }
    
    func setDidStopCallback(stopCallback : FAAnimationDidStop) {
        animationDidStop = stopCallback
    }
    
    func setDidStartCallback(startCallback : FAAnimationDidStart) {
        animationDidStart = startCallback
    }
}

public extension CAAnimation {
    
    public func setDidStopCallback(stopCallback : FAAnimationDidStop) {
       
        if callbacksSupported() == false {
            print("DidStopCallbacks are not supported for \(self)")
        }
        
        var activeDelegate : FAAnimationDelegate?
        
        if let currentDelegate = delegate as? FAAnimationDelegate {
            activeDelegate = currentDelegate
        } else {
            activeDelegate = FAAnimationDelegate()
        }
 
        activeDelegate!.setDidStopCallback({ completion in
            if let _ = self.delegate as? FAAnimationDelegate {
                stopCallback(complete: completion)
            }
        })
        
        self.delegate = activeDelegate
    }
    
    public func setDidStartCallback(startCallback : FAAnimationDidStart) {
        
        if callbacksSupported() == false {
            print("DidStartCallback are not supported for \(self)")
        }
        
        var activeDelegate : FAAnimationDelegate?
        
        if let currentDelegate = delegate as? FAAnimationDelegate {
            activeDelegate = currentDelegate
        } else {
            activeDelegate = FAAnimationDelegate()
        }
        
        activeDelegate!.setDidStartCallback({
            if let _ = self.delegate as? FAAnimationDelegate {
                startCallback()
            }
        })
        
        self.delegate = activeDelegate
    }
    
    private func callbacksSupported() -> Bool {
        if let _ = self as? FAAnimationGroup {
        } else if let _ = self as? FAAnimation {
        } else{
            return false
        }
        return true
    }
}
