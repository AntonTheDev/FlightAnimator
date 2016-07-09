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

func ==(lhs:AnimationTrigger, rhs:AnimationTrigger) -> Bool {
    return lhs.animatedView == rhs.animatedView &&
        lhs.isTimedBased == rhs.isTimedBased &&
        lhs.triggerProgessValue == rhs.triggerProgessValue &&
        lhs.animationKey == rhs.animationKey
}

internal struct AnimationTrigger : Equatable {
    var isTimedBased = true
    var triggerProgessValue : CGFloat?
    var animationKey : String?
    weak var animatedView : UIView?
}

final public class FAAnimationGroup : CAAnimationGroup {
    
    var primaryTimingPriority : FAPrimaryTimingPriority = .MaxTime
    var animationKey : String?
    
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
    
    // This is used to
    private var primaryEasingFunction : FAEasing = FAEasing.Linear
    private var primaryAnimation : FAAnimation?
    
    private var displayLink : CADisplayLink?
    
    var _segmentArray = [AnimationTrigger]()
    var segmentArray = [AnimationTrigger]()
    
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
        animationGroup.segmentArray             = segmentArray
        
        animationGroup._segmentArray            = _segmentArray
        
        animationGroup.primaryTimingPriority    = primaryTimingPriority
        return animationGroup
    }
}

//MARK: Public API

extension FAAnimationGroup {
    
    func synchronizeAnimationGroup(oldAnimationGroup : FAAnimationGroup?) {
        synchronizeAnimations(oldAnimationGroup)
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
                            animationLayer.setValue(toValue, forKeyPath: subAnimation.keyPath!)
                        }
                    }
                }
            }
        }
        
        startTriggerTimer()
    }
}


//MARK: - Animation Synchronization

extension FAAnimationGroup {
    
    private func synchronizeAnimations(oldAnimationGroup : FAAnimationGroup?) {
        
        var durationArray =  [Double]()
        
        var oldAnimations = animationDictionaryForGroup(oldAnimationGroup)
        var newAnimations = animationDictionaryForGroup(self)
        
        // Find all Primary Animations
        let filteredPrimaryAnimations = newAnimations.filter({ $0.1.isAnimationPrimary() == true })
        let filteredNonPrimaryAnimations = newAnimations.filter({ $0.1.isAnimationPrimary() == false })
        
        var primaryAnimations = [String : FAAnimation]()
        var nonPrimaryAnimations = [String : FAAnimation]()
        
        for result in filteredPrimaryAnimations {
            primaryAnimations[result.0] = result.1
        }
        
        for result in filteredNonPrimaryAnimations {
            nonPrimaryAnimations[result.0] = result.1
        }
        
        //If no animation is primary, all animations become primary
        if primaryAnimations.count == 0 {
            primaryAnimations = newAnimations
            nonPrimaryAnimations = [String : FAAnimation]()
        }
        
        for key in primaryAnimations.keys {
            
            if  let newPrimaryAnimation = primaryAnimations[key] {
                let oldAnimation : FAAnimation? = oldAnimations[key]
                
                newPrimaryAnimation.synchronize(runningAnimation: oldAnimation)
                
                durationArray.append(newPrimaryAnimation.duration)
                newAnimations[key] = newPrimaryAnimation
            }
        }
        
        animations = newAnimations.map {$1}
        
        updateGroupDurationBasedOnTimePriority(durationArray)
    }
    
    private func updateGroupDurationBasedOnTimePriority(durationArray: Array<CFTimeInterval>) {
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
            primaryAnimation = primaryDrivingAnimation
            primaryEasingFunction = primaryDrivingAnimation.easingFunction
        }
        
        guard animations != nil else {
            return
        }
        
        var newAnimationsArray = [FAAnimation]()
        newAnimationsArray.append(filteredAnimation.first! as! FAAnimation)
        
        for animation in animations! {
            animation.duration = duration
            
            if let customAnimation = animation as? FAAnimation {
                switch customAnimation.easingFunction {
                case .SpringDecay(_):
                    break
                case .SpringCustom(_, _, _):
                    break
                default:
                    customAnimation.synchronize()
                }
           
                newAnimationsArray.append(customAnimation)
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

//MARK: - Sequence Configuration and Timing

extension FAAnimationGroup {
    
    internal func updateLoop() {
        for segment in segmentArray {
            
            if segment.isTimedBased && primaryAnimation?.timeProgress() >= segment.triggerProgessValue ||
              !segment.isTimedBased && primaryAnimation?.valueProgress() >= segment.triggerProgessValue  {
               
                segment.animatedView!.applyAnimation(forKey: segment.animationKey!)
                segmentArray.removeObject(segment)
            }
        }
        
        if segmentArray.count <= 0 {
            stopTriggerTimer()
            return
        }
    }
    
    private func startTriggerTimer() {
        if _segmentArray.count == 0 {
            return
        }
        
        segmentArray = _segmentArray
        
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(FAAnimationGroup.updateLoop))
            displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            displayLink!.paused = false
        }
    }
    
    private func stopTriggerTimer() {
        displayLink?.paused = true
        displayLink?.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        displayLink = nil
    }
}
