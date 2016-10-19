//
//  UIView+FlightAnimator.swift
//  FlightAnimator
//
//  Created by Anton on 8/23/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    
    func cacheAnimation(forKey key: String,
                        timingPriority : FAPrimaryTimingPriority = .MaxTime,
                        @noescape animator : (animator : FlightAnimator) -> Void ) {
        
        let newAnimator = FlightAnimator(withView: self, forKey : key, priority : timingPriority)
        animator(animator : newAnimator)
    }
    
    func cacheAnimation(animation animation: Any,
                        forKey key: String,
                        timingPriority : FAPrimaryTimingPriority = .MaxTime) {
        
        if self.cachedAnimations == nil {
            self.cachedAnimations = [NSString : FAAnimationGroup]()
        }
        
        if self.cachedAnimations!.keys.contains(NSString(string: key)) {
            self.cachedAnimations![NSString(string: key)]?.stopTriggerTimer()
            self.cachedAnimations![NSString(string: key)] = nil
        }
        
        if let group = animation as? FAAnimationGroup {
            group.animationKey = key
            group.weakLayer = layer
            group.primaryTimingPriority = timingPriority
            
            cachedAnimations![NSString(string: key)] = group
        } else if let animation = animation as? FABasicAnimation {
            
            let newGroup = FAAnimationGroup()
            newGroup.animationKey = key
            newGroup.weakLayer = layer
            newGroup.primaryTimingPriority = timingPriority
            newGroup.animations = [animation]
            
            cachedAnimations![NSString(string: key)] = newGroup
        }
    }
    
    func applyAnimation(forKey key: String,
                        animated : Bool = true) {
        
        if let cachedAnimationsArray = cachedAnimations,
            let animation = cachedAnimationsArray[key] {
            animation.applyFinalState(animated)
        }
    }

    /*
     
    func applyAnimationTree(forKey key: String,
                                   animated : Bool = true) {
        
        applyAnimation(forKey : key, animated:  animated)
        applyAnimationsToSubViews(self, forKey: key, animated: animated)
    }
    
    private func applyAnimationsToSubViews(inView : UIView, forKey key: String, animated : Bool = true) {
        for subView in inView.subviews {
            subView.applyAnimation(forKey: key, animated: animated)
        }
    }
     
    */
}
