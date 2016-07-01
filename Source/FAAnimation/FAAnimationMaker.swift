//
//  FlightAnimate+Private.swift
//  
//
//  Created by Anton on 6/29/16.
//
//

import Foundation
import UIKit

public class FAAnimationMaker {
    
    internal weak var associatedView : UIView?
    internal var animationKey : String?
    
    var animationConfigurations = [String : PropertyConfiguration]()
    var primaryTimingPriority : FAPrimaryTimingPriority = .MaxTime
    
    init(withView view : UIView, forKey key: String, priority : FAPrimaryTimingPriority = .MaxTime) {
        animationKey = key
        associatedView = view
        primaryTimingPriority = priority
        configureNewGroup()
    }
    
    private func configureNewGroup() {
        
        if associatedView!.cachedAnimations == nil {
            associatedView!.cachedAnimations = [String : FAAnimationGroup]()
        }
        
        let newGroup = FAAnimationGroup()
        newGroup.animationKey = animationKey
        newGroup.weakLayer = associatedView?.layer
        newGroup.primaryTimingPriority = primaryTimingPriority
        
        associatedView!.cachedAnimations![animationKey!] = newGroup
    }
    
    internal func triggerAnimation(timingPriority : FAPrimaryTimingPriority = .MaxTime,
                                   timeBased : Bool,
                                   key: String,
                                   view: UIView,
                                   progress: CGFloat = 0.0,
                                   @noescape animator: (animator : FlightAnimator) -> Void) {
        
        let newSegment = SegmentItem()
        newSegment.animationKey = animationKey!
        newSegment.timedProgress = timeBased
        newSegment.animatedView = view
        
        if let animationGroup = associatedView!.cachedAnimations![animationKey!] {
            animationGroup.segmentArray[progress] = newSegment
            associatedView!.attachAnimation(animationGroup, forKey: animationKey!)
        }
        
        
        let newAnimator = FlightAnimator(withView: view, forKey : animationKey!, priority : timingPriority)
        animator(animator : newAnimator)
    }
}

public protocol PropertyConfiguration {
    var easingCurve : FAEasing { get }
    var duration : CGFloat { get }
    
    func duration(duration : CGFloat) -> PropertyConfiguration
    func easing(easing : FAEasing) -> PropertyConfiguration
    func primary(primary : Bool) -> PropertyConfiguration
}

private class Configuration {
    var value: PropertyConfiguration
    
    init<T : FAAnimatable>(value: T, forKeyPath key : String, view : UIView, animationKey : String) {
        self.value = ConfigurationValue(value: value, forKeyPath : key, view : view, animationKey : animationKey)
    }
    
    func duration(duration : CGFloat) {
        value.duration(duration)
    }
    
    func easing(easing : FAEasing) {
        value.easing(easing)
    }
}

internal class ConfigurationValue<T : FAAnimatable> : PropertyConfiguration {
    
    private weak var associatedView : UIView?
    private var animationKey : String?
    private var keyPath : String?
    
    var toValue : T
    var easingCurve : FAEasing = .Linear
    var duration : CGFloat
    var primary : Bool
    
    init(value: T, forKeyPath key : String, view : UIView, animationKey : String) {
        self.animationKey = animationKey
        self.associatedView = view
        self.keyPath = key
        self.toValue = value
        self.easingCurve = .Linear
        self.duration = 0.0
        self.primary = false
    }
    
    func duration(duration : CGFloat) -> PropertyConfiguration {
        self.duration = duration
        updateAnimation()
        return self
    }
    
    func easing(easing : FAEasing) -> PropertyConfiguration {
        self.easingCurve = easing
        updateAnimation()
        return self
    }
    
    func primary(primary : Bool) -> PropertyConfiguration {
        self.primary = primary
        updateAnimation()
        return self
    }
    
    private func updateAnimation() {
        guard let animationGroup = associatedView!.cachedAnimations![animationKey!] else {
            return
        }
        
        let animation = FAAnimation(keyPath: keyPath)
        animation.easingFunction = easingCurve
        animation.toValue = toValue.valueRepresentation()
        animation.duration = Double(duration)
        animation.setAnimationAsPrimary(primary)
        
        animationGroup.weakLayer = associatedView?.layer
        animationGroup.animations!.append(animation)
        
        associatedView!.cachedAnimations![animationKey!] = animationGroup
    }
}