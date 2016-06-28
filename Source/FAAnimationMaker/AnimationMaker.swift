//
//  AnimationMaker.swift
//
//
//  Created by Anton Doudarev on 6/23/16.
//
//

import Foundation
import UIKit

public protocol PropertyConfiguration {
    var easingCurve : FAEasing { get }
    var duration : CGFloat { get }
    
    func duration(duration : CGFloat) -> PropertyConfiguration
    func easing(easing : FAEasing) -> PropertyConfiguration
    func primary(primary : Bool) -> PropertyConfiguration
}

public class Configuration {
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

class ConfigurationValue<T : FAAnimatable> : PropertyConfiguration {
    
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

public class FlightAnimator {
    
    private weak var associatedView : UIView?
    private var animationKey : String?
    
    var animationConfigurations = [String : PropertyConfiguration]()
    var primaryTimingPriority : FAPrimaryTimingPriority = .MaxTime
    
    init(withView view : UIView, forKey key: String) {
        animationKey = key
        associatedView = view
        configureNewGroup()
    }
    
    private func configureNewGroup() {
        
        if associatedView!.cachedAnimations == nil {
            associatedView!.cachedAnimations = [String : FAAnimationGroup]()
        }
        
        let newGroup = FAAnimationGroup()
        newGroup.animationKey = animationKey
        newGroup.weakLayer = associatedView?.layer
        
        associatedView!.cachedAnimations![animationKey!] = newGroup
    }
    
    public func triggerOnStart(onView view: UIView,
                        maker: (maker : FlightAnimator) -> Void) {
        triggerAnimation(true, key: animationKey!, view: view, progress: 0.0, maker: maker)
    }
    
    public func triggerAtTimeProgress(atProgress progress: CGFloat, onView view: UIView,
                        maker: (maker : FlightAnimator) -> Void) {
        triggerAnimation(true, key: animationKey!, view: view, progress: 0.0, maker: maker)
    }
    
    public func triggerAtValueProgress(progress: CGFloat, onView view: UIView,
                            maker: (maker : FlightAnimator) -> Void) {
        triggerAnimation(true, key: animationKey!, view: view, progress: progress, maker: maker)
    }
    
    private func triggerAnimation(timeBased : Bool,
                                  key: String,
                                  view: UIView,
                                  progress: CGFloat = 0.0,
                                  maker: (maker : FlightAnimator) -> Void) {
        
        let newSegment = SegmentItem()
        newSegment.animationKey = animationKey!
        newSegment.timedProgress = false
        newSegment.animatedView = view
        
        if let animationGroup = associatedView!.cachedAnimations![animationKey!] {
            animationGroup.segmentArray[progress] = newSegment
            associatedView!.attachAnimation(animationGroup, forKey: animationKey!)
        }
        
        
        let newMaker = FlightAnimator(withView: view, forKey : animationKey!)
        maker(maker : newMaker)
    }
    
    public func value<T : FAAnimatable>(value : T, forKeyPath key : String) -> PropertyConfiguration {
        animationConfigurations[key] = ConfigurationValue(value: value, forKeyPath: key, view : associatedView!, animationKey: animationKey!)
        return animationConfigurations[key]!
    }
    
    public func alpha(value : CGFloat) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "opacity")
    }
    
    public func anchorPoint<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "anchorPoint")
    }
    
    public func bounds<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "bounds")
    }
    
    public func borderWidth<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "borderWidth")
    }
    
    public func contentsRect<T : FAAnimatable>(value : T) -> PropertyConfiguration{
        return self.value(value, forKeyPath : "contentsRect")
    }
    
    public func cornerRadius<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "cornerRadius")
    }
    
    public func frame<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        position(CGPointMake((value as? CGRect)!.midX, (value as? CGRect)!.midY))
        return bounds(CGRectMake(0, 0, (value as? CGRect)!.width, (value as? CGRect)!.height))
    }
    
    public func opacity<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "opacity")
    }
    
    public func position<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "position")
    }
    
    public func shadowOffset<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "shadowOffset")
    }
    
    public func shadowOpacity<T : FAAnimatable>(value : T) -> PropertyConfiguration{
        return self.value(value, forKeyPath : "shadowOpacity")
    }
    
    public func shadowRadius<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "shadowRadius")
    }
    
    public func size<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return bounds(CGRectMake(0, 0, (value as? CGSize)!.width, (value as? CGSize)!.height))
    }
    
    public func sublayerTransform<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "sublayerTransform")
    }
    
    public func transform<T : FAAnimatable>(value : T) -> PropertyConfiguration{
        return self.value(value, forKeyPath : "transform")
    }
    
    public func animateZPosition<T : FAAnimatable>(value : T) -> PropertyConfiguration {
        return self.value(value, forKeyPath : "animateZPosition")
    }
}




