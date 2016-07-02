//
//  FAAnimationGroup.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

internal class SegmentItem : Copying {
    var timedProgress = true
    var animationKey : String?
    var easingFunction : String?
    weak var animatedView : UIView?
    
    required init(original: SegmentItem) {
        timedProgress = original.timedProgress
        animationKey = original.animationKey
        easingFunction = original.easingFunction
        animatedView = original.animatedView
    }
    
    init() {
        
    }
}


protocol Copying {
    init(original: Self)
}

extension Copying {
    func copy() -> Self {
        return Self.init(original: self)
    }
}

final public class FAAnimationGroup : CAAnimationGroup {
    
    var _segmentDictionary = [CGFloat : SegmentItem]()
    
    var segmentDictionary = [CGFloat : SegmentItem]() {
        didSet {
            for (key, value) in segmentDictionary {
                _segmentDictionary[key] = value.copy()
            }
        }
    }
    
    private var primaryEasingFunction : FAEasing = FAEasing.Linear
    
    var primaryTimingPriority : FAPrimaryTimingPriority = .MaxTime
    var animationKey : String?
    
    private var timeProgress: CGFloat = 0.0
    private var displayLink : CADisplayLink?
    
    weak var weakLayer : CALayer? {
        didSet {
            if let currentAnimations = animations {
                for animation in currentAnimations {
                    if let customAnimation = animation as? FAAnimation {
                        customAnimation.weakLayer = weakLayer
                    }
                }
            }
        }
    }
    
    // The start time of the animation, set by the current time of
    // the layer when it is added. Used by the springs to find the
    // current velocity in motion
    var startTime : CFTimeInterval? {
        didSet {
            if let currentAnimations = animations {
                for animation in currentAnimations {
                    if let customAnimation = animation as? FAAnimation {
                        customAnimation.startTime = startTime
                    }
                }
            }
        }
    }
    
    override init() {
        super.init()
        animations = [CAAnimation]()
        fillMode = kCAFillModeForwards
        removedOnCompletion = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        let animationGroup = super.copyWithZone(zone) as! FAAnimationGroup
        animationGroup.weakLayer                = weakLayer
        animationGroup.startTime                = startTime
        animationGroup.animationKey             = animationKey
        animationGroup.segmentDictionary        = segmentDictionary
        animationGroup.primaryTimingPriority    = primaryTimingPriority
        return animationGroup
    }
    
    func scrubToProgress(progress : CGFloat) {
        weakLayer?.speed = 0.0
        weakLayer?.timeOffset = CFTimeInterval(duration * Double(progress))
    }
    
    func applyFinalState(animated : Bool = false) {
        stopTriggerTimer()
        
        if let animationLayer = weakLayer {
            if animated {
                animationLayer.speed = 1.0
                animationLayer.timeOffset = 0.0
                startTime = animationLayer.convertTime(CACurrentMediaTime(), fromLayer: nil)
                animationLayer.addAnimation(self, forKey: self.animationKey)
            }
            
            if let subAnimations = animations {
                for animation in subAnimations {
                    if let subAnimation = animation as? FAAnimation,
                        let toValue = subAnimation.toValue {
                        
                        //TODO: Figure out why the opacity is not reflected on the UIView
                        //All properties work correctly, but to ensure that the opacity is reflected
                        //I am setting the alpha on the UIView itsel ?? WTF
                        if subAnimation.keyPath! == "opacity" {
                            animationLayer.owningView()!.setValue(toValue, forKeyPath: "alpha")
                        } else {
                            animationLayer.modelLayer().setValue(toValue, forKeyPath: subAnimation.keyPath!)
                        }
                    }
                }
            }
        }
        
        startTriggerTimer()
    }
}


//MARK: Synchronization Logic

extension FAAnimationGroup {
    
    func synchronizeAnimationGroup(oldAnimationGroup : FAAnimationGroup?) {
        
        preconfigureTimer(oldAnimationGroup)
        
        var durationArray =  [Double]()
        
        var oldAnimations = animationDictionaryForGroup(oldAnimationGroup)
        var newAnimations = animationDictionaryForGroup(self)
        
        // Find all Primary Animations
        let filteredAnimation = newAnimations.filter({ $0.1.isAnimationPrimary() == true })
        var primaryAnimations = [String : FAAnimation]()
        
        for result in filteredAnimation {
            primaryAnimations[result.0] = result.1
        }

        //If not animation is primary, all animations become primary
        if primaryAnimations.count == 0 {
            primaryAnimations = newAnimations
        }
        
        for key in newAnimations.keys {
            
            if  let newPrimaryAnimation = primaryAnimations[key] {
                let oldAnimation : FAAnimation? = oldAnimations[key]
                
                newPrimaryAnimation.synchronizeWithAnimation(oldAnimation)
               
                durationArray.append(newPrimaryAnimation.duration)
                newAnimations[key] = newPrimaryAnimation
            }
        }

        if durationArray.count == 0 {
            durationArray = newAnimations.map { $1.duration }.filter { $0 > 0 }
        }
        
        animations = newAnimations.map {$1}
        adjustGroupDurationWith(primaryDurationsArray: durationArray)
    }
    
    private func adjustGroupDurationWith(primaryDurationsArray durationArray: Array<CFTimeInterval>) {
        switch primaryTimingPriority {
        case .MaxTime:
            duration = durationArray.maxElement()!
        case .MinTime:
            duration = durationArray.minElement()!
        case .Median:
            duration = durationArray.sort(<)[durationArray.count / 2]
        case .Average:
            duration = durationArray.reduce(0, combine: +) / Double(durationArray.count)
        }
        
        let filteredAnimation = animations!.filter({ $0.duration == duration })
        
        if let primaryDrivingAnimation = filteredAnimation.first as? FAAnimation {
            primaryEasingFunction = primaryDrivingAnimation.easingFunction
        }
        
        guard animations != nil else {
            return
        }
        
        for animation in animations! {
            animation.duration = duration
            
            if let customAnimation = animation as? FAAnimation {
                switch customAnimation.easingFunction {
                case .SpringDecay(_):
                    break
                case .SpringCustom(_, _, _):
                    break
                default:
                    customAnimation.configureValues()
                }
            }
        }
    }
    
    private func animationDictionaryForGroup(animationGroup : FAAnimationGroup?) -> [String : FAAnimation] {
        var animationDictionary = [String: FAAnimation]()
        
        if let group = animationGroup {
            if let currentAnimations = group.animations {
                for animation in currentAnimations {
                    if let customAnimation = animation as? FAAnimation {
                        animationDictionary[customAnimation.keyPath!] = customAnimation
                    }
                }
            }
        }
        
        return animationDictionary
    }
}

extension FAAnimationGroup {
    
    
    private func preconfigureTimer(oldAnimationGroup : FAAnimationGroup?) {
        dispatch_async(dispatch_get_main_queue()) {
            oldAnimationGroup?.stopTriggerTimer()
        }
        
        for (key, value) in _segmentDictionary {
            segmentDictionary[key] = value.copy()
        }
    }
    
    func updateLoop() {
        for (key, _) in _segmentDictionary {
            if let segment = segmentDictionary[key] {
                if segment.timedProgress {
                    if timeProgressed() > key {
                        segment.animatedView!.applyAnimation(forKey: segment.animationKey!)
                        segmentDictionary.removeValueForKey(key)
                    }
                } else {
                    switch self.primaryEasingFunction {
                    case .SpringDecay:
                        break
                    case .SpringCustom(_, _, _):
                        break
                    default:
                        let progress = primaryEasingFunction.parametricProgress(timeProgressed())
                        if progress > key {
                            segment.animatedView!.applyAnimation(forKey: segment.animationKey!)
                            segmentDictionary.removeValueForKey(key)
                        }
                    }
                }
            }
        }
        
        if segmentDictionary.keys.count <= 0 {
            stopTriggerTimer()
            return
        }
    }
    
    func startTriggerTimer() {
        if segmentDictionary.keys.count == 0 {
            return
        }
        
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(FAAnimationGroup.updateLoop))
            displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            timeProgress = 0.0
            displayLink!.paused = false
        }
    }
    
    private func stopTriggerTimer() {
        displayLink?.paused = true
        displayLink?.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        displayLink = nil
    }
    
    private func timeProgressed() -> CGFloat {
        let currentTime = weakLayer?.presentationLayer()!.convertTime(CACurrentMediaTime(), toLayer: nil)
        let difference = CGFloat(currentTime! - startTime!)
        return CGFloat(round(100 * (difference / CGFloat(duration)))/100)
    }
}


