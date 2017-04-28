//
//  UIView+FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    
    public func animate(_ timingPriority : FAPrimaryTimingPriority = .maxTime,
                        animator : (_ animator : FlightAnimator) -> Void ) {
        
        let animationKey = UUID().uuidString
        
        let newAnimator = FlightAnimator(withView: self, forKey : animationKey,  priority : timingPriority)
        animator(newAnimator)
        applyAnimation(forKey: animationKey)
    }
    
    public func registerAnimation(forKey key: String,
                                  timingPriority : FAPrimaryTimingPriority = .maxTime,
                                  animator : (_ animator : FlightAnimator) -> Void ) {
        
        let newAnimator = FlightAnimator(withView: self, forKey : key, priority : timingPriority)
        animator(newAnimator)
    }
    
    public func applyAnimation(forKey key: String,
                               animated : Bool = true) {
        
        if let cachedAnimationsArray = cachedAnimations,
            let animation = cachedAnimationsArray[key as NSString] {
            animation.applyFinalState(animated)
        }
    }
}

extension FlightAnimator  {
    
    @discardableResult open func value(_ value : Any, forKeyPath key : String) -> FAPropertyAnimator {
    
        let formalValue = associatedView?.formattedNumericValue(forValue: value, forKey: key)

        if let formalValue = formalValue as? UIColor {
            animationConfigurations[key] = FAPropertyAnimator(value: formalValue.cgColor,
                                                              forKeyPath: key,
                                                              view : associatedView!,
                                                              animationKey: animationKey!)
        } else {
            animationConfigurations[key] = FAPropertyAnimator(value: formalValue ?? value,
                                                              forKeyPath: key,
                                                              view : associatedView!,
                                                              animationKey: animationKey!)
        }
        
        return animationConfigurations[key]!
    }
    
    @discardableResult public func alpha(_ value : CGFloat) -> FAPropertyAnimator {
        return self.value(value, forKeyPath : "opacity")
    }
    
    @discardableResult public func anchorPoint(_ value : CGPoint) -> FAPropertyAnimator {
        return self.value(value, forKeyPath : "anchorPoint")
    }
    
    @discardableResult public func backgroundColor(_ value : CGColor) -> FAPropertyAnimator {
        return self.value(value, forKeyPath : "backgroundColor")
    }
    
    @discardableResult public func bounds(_ value : CGRect) -> FAPropertyAnimator {
        return self.value(value, forKeyPath : "bounds")
    }
    
    @discardableResult public func borderColor(_ value : CGColor) -> FAPropertyAnimator {
        return self.value(value, forKeyPath : "borderColor")
    }
    
    @discardableResult public func borderWidth(_ value : CGFloat) -> FAPropertyAnimator {
        return self.value(value, forKeyPath : "borderWidth")
    }
    
    @discardableResult public func contentsRect(_ value : CGRect) -> FAPropertyAnimator {
        return self.value(value, forKeyPath : "contentsRect")
    }
    
    @discardableResult public func cornerRadius(_ value : CGFloat) -> FAPropertyAnimator {
        return self.value(value, forKeyPath : "cornerRadius")
    }
    
    @discardableResult public func opacity(_ value : CGFloat) -> FAPropertyAnimator {
        return self.value(value, forKeyPath : "opacity")
    }
    
    @discardableResult public func position(_ value : CGPoint) -> FAPropertyAnimator {
        return self.value(value, forKeyPath : "position")
    }
    
    @discardableResult public func shadowColor(_ value : CGColor) -> FAPropertyAnimator {
        return self.value(value, forKeyPath : "shadowColor")
    }
    
    @discardableResult public func shadowOffset(_ value : CGSize) -> FAPropertyAnimator {
        return self.value(value, forKeyPath : "shadowOffset")
    }
    
    @discardableResult public func shadowOpacity(_ value : CGFloat) -> FAPropertyAnimator {
        return self.value(value, forKeyPath : "shadowOpacity")
    }
    
    @discardableResult public func shadowRadius(_ value : CGFloat) -> FAPropertyAnimator {
        return self.value(value, forKeyPath : "shadowRadius")
    }
    
    @discardableResult public func size(_ value : CGSize) -> FAPropertyAnimator {
        return bounds(CGRect(x: 0, y: 0, width: value.width, height: value.height))
    }
    
    @discardableResult public func sublayerTransform(_ value : CATransform3D) -> FAPropertyAnimator {
        return self.value(value, forKeyPath : "sublayerTransform")
    }
    
    @discardableResult public func transform(_ value : CATransform3D) -> FAPropertyAnimator{
        return self.value(value, forKeyPath : "transform")
    }
    
    @discardableResult public func zPosition(_ value : CGFloat) -> FAPropertyAnimator {
        return self.value(value, forKeyPath : "zPosition")
    }
}

extension FlightAnimator {
    
    public func triggerOnStart(onView view: UIView,
                               timingPriority : FAPrimaryTimingPriority = .maxTime,
                               animator: (_ animator : FlightAnimator) -> Void) {
        
        triggerAnimation(timingPriority, timeBased : true, view: view, progress: 0.0, animator: animator)
    }
    
    public func triggerOnCompletion(onView view: UIView,
                                    timingPriority : FAPrimaryTimingPriority = .maxTime,
                                    animator: (_ animator : FlightAnimator) -> Void) {
        
        triggerAnimation(timingPriority, timeBased : true, view: view, progress: 1.0, animator: animator)
    }
    
    public func triggerOnProgress(_ progress: CGFloat,
                                  onView view: UIView,
                                  timingPriority : FAPrimaryTimingPriority = .maxTime,
                                  animator: (_ animator : FlightAnimator) -> Void) {
        
        triggerAnimation(timingPriority, timeBased : true, view: view, progress: progress, animator: animator)
    }
    
    public func triggerOnValueProgress(_ progress: CGFloat,
                                       onView view: UIView,
                                       timingPriority : FAPrimaryTimingPriority = .maxTime,
                                       animator: (_ animator : FlightAnimator) -> Void) {
        
        triggerAnimation(timingPriority, timeBased : false, view: view, progress: progress, animator: animator)
    }
}

extension FlightAnimator {
    
    public func setDidCancelCallback(_ cancelCallback : @escaping FAAnimationDelegateCallBack) {
        if ((associatedView?.cachedAnimations?.keys.contains(NSString(string: animationKey!))) != nil) {
            associatedView!.cachedAnimations![NSString(string: animationKey!)]!.setDidCancelCallback(cancelCallback)
        }
    }
    
    public func setDidStopCallback(_ stopCallback : @escaping FAAnimationDelegateCallBack) {
        if ((associatedView?.cachedAnimations?.keys.contains(NSString(string: animationKey!))) != nil) {
            associatedView!.cachedAnimations![NSString(string: animationKey!)]!.setDidStopCallback(stopCallback)
        }
    }
    
    public func setDidStartCallback(_ startCallback : @escaping FAAnimationDelegateCallBack) {
        if ((associatedView?.cachedAnimations?.keys.contains(NSString(string: animationKey!))) != nil) {
            associatedView!.cachedAnimations![NSString(string: animationKey!)]!.setDidStartCallback(startCallback)
        }
    }
}
