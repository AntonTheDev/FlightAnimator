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

internal class SegmentItem {
    var timedProgress = true
    var animationKey : String?
    var easingFunction : String?
    weak var animatedView : UIView?
}

public class FAAnimationGroup : CAAnimationGroup {
    
    var segmentArray = [CGFloat : SegmentItem]()
    var primaryEasingFunction : FAEasing = FAEasing.Linear
    
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
        animationGroup.weakLayer        = weakLayer
        animationGroup.startTime        = startTime
        animationGroup.animationKey    = animationKey
        animationGroup.segmentArray    = segmentArray
        return animationGroup
    }
    
    func synchronizeAnimationGroup(oldAnimationGroup : FAAnimationGroup?) {     
        dispatch_async(dispatch_get_main_queue()) {
            oldAnimationGroup?.stopUpdateLoop()
        }
        
        let relativeAnimationGroup = oldAnimationGroup != nil ? oldAnimationGroup : self
        var durationArray =  [Double]()
        
        var oldAnimations = animationDictionaryForGroup(relativeAnimationGroup)
        var newAnimations = animationDictionaryForGroup(self)
        
        for key in newAnimations.keys {
            if  let newAnimation = newAnimations[key] {
                
                let oldAnimation : FAAnimation? = oldAnimations[key]
                newAnimation.synchronizeWithAnimation(oldAnimation)
                
                if newAnimation.isAnimationPrimary() && newAnimation.duration > 0 {
                    durationArray.append(newAnimation.duration)
                    primaryEasingFunction = newAnimation.easingFunction
                }
                
                newAnimations[key] = newAnimation
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
            duration = durationArray.median
        case .Average:
            duration = durationArray.reduce(0, combine: +) / Double(durationArray.count)
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
    
    func scrubToProgress(progress : CGFloat) {
        weakLayer?.speed = 0.0
        weakLayer?.timeOffset = CFTimeInterval(duration * Double(progress))
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
    
    func applyFinalState(animated : Bool = false) {
        stopUpdateLoop()
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
                        animationLayer.setValue(toValue, forKeyPath: subAnimation.keyPath!)
                    }
                }
            }
        }
        startUpdateLoop()
    }
}


extension FAAnimationGroup {
    
    func updateLoop() {

        if segmentArray.keys.count <= 0 {
            stopUpdateLoop()
            return
        }
        
        if let presentationLayer = weakLayer?.presentationLayer(),
           let animationStartTime = startTime {
            
        
            let currentTime = presentationLayer.convertTime(CACurrentMediaTime(), toLayer: nil)
            let difference = CGFloat(currentTime - animationStartTime)
       
            let totalTimeProgress = CGFloat(round(100 * (difference / CGFloat(duration)))/100)
            var progress = totalTimeProgress //primaryEasingFunction.parametricProgress(CGFloat(totalTimeProgress))

            if let firstProgressKey = self.segmentArray.keys.first,
               let firstSegment = segmentArray[firstProgressKey] {
                
                if firstSegment.timedProgress {
                    if CGFloat(totalTimeProgress) > firstProgressKey {
                        let segment = segmentArray[firstProgressKey]
                        segment!.animatedView!.applyAnimation(forKey: segment!.animationKey!)
                        segmentArray.removeValueForKey(firstProgressKey)
                    }
                } else {
                    
                    switch self.primaryEasingFunction {
                    case .SpringDecay:
                        break
                    case .SpringCustom(_, _, _):
                        break
                    default:
                        progress = primaryEasingFunction.parametricProgress(CGFloat(totalTimeProgress))
                    }
                    
                    // print("AnimationProgress duration", duration, "\nDifference", difference, "\ntotalTimeProgress", totalTimeProgress, "\nprogress", progress, "\n\n")
                   
                    if CGFloat(progress) > firstProgressKey {
                        let segment = segmentArray[firstProgressKey]
                        segment!.animatedView!.applyAnimation(forKey: segment!.animationKey!)
                        segmentArray.removeValueForKey(firstProgressKey)
                    }
                }
            }
            
            if segmentArray.keys.count <= 0 {
                stopUpdateLoop()
                return
            }
        }
    }
    
    func startUpdateLoop() {
        
        if self.segmentArray.keys.count == 0 {
            return
        }
        
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(FAAnimationGroup.updateLoop))
            displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            timeProgress = 0.0
            displayLink!.paused = false
        }
    }
    
    func stopUpdateLoop() {
        displayLink?.paused = true
        displayLink?.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        displayLink = nil
    }
}


