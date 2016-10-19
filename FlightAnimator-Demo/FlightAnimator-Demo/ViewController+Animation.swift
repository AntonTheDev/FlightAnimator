//
//  ViewController+Animation.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 6/13/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit
/**
 *  This is used to keep track of the settings in the configuration screen
 */
struct AnimationConfiguration {
    
    var primaryTimingPriority : FAPrimaryTimingPriority = .MaxTime
    
    var sizeFunction : FAEasing = FAEasing.OutSine
    var positionFunction : FAEasing =  FAEasing.SpringCustom(velocity: CGPointZero, frequency: 14, ratio: 0.8)
    var alphaFunction : FAEasing = FAEasing.InSine
    var transformFunction : FAEasing = FAEasing.OutBack
    
    var positionPrimary : Bool = true
    var sizePrimary : Bool = false
    var alphaPrimary : Bool = false
    var transformPrimary : Bool = false
    
    // For thr purpose of the example
    // 0 - Trigger Instantly
    // 1 - Trigger Based on Time Progress
    // 2 - Trigger Based on Value Progress
    var triggerType  : Int = 0
    
    var triggerProgress  : CGFloat = 0
    
    var enableSecondaryView  : Bool = false
    
    static func titleForFunction(function : FAEasing) -> String {
        return functionTypes[functions.indexOf(function)!]
    }
}

/**
 *  These are the keys you register for the animation
 */
struct AnimationKeys {
    
    // The Animation to show and hide the configuration view
    // is toggled by these keys in the example below
    static let ShowConfigAnimation  = "ShowConfigAnimation"
    static let HideConfigAnimation  = "HideConfigAnimation"
    
    // This is the key for the pangesture recogniser that
    // you can flick the view with
    static let PanGestureKey            = "PanGestureKey"
    
    // This key is used to overwrite and sychronize the old
    // animation with the new animation, taking the current position
    // into account
    static let TapStageOneAnimationKey  = "TapStageOneAnimationKey"
    static let TapStageTwoAnimationKey  = "TapStageTwoAnimationKey"
    static let SecondaryAnimationKey    = "SecondaryAnimationKey"
}

let screenBounds = UIScreen.mainScreen().bounds
let openConfigFrame = CGRectMake(20, 20, screenBounds.width - 40, screenBounds.height - 40)
let closedConfigFrame = CGRectMake(20, screenBounds.height + 20, screenBounds.width - 40, screenBounds.height - 40)

extension ViewController {
    
    /**
     Called on viewDidLoad, preloads the animation states into memory
     */
    func registerConfigViewAnimations() {
        
        configView.cacheAnimation(forKey : AnimationKeys.ShowConfigAnimation, timingPriority: self.animConfig.primaryTimingPriority) {[unowned self] (animator) in
            
            let toBounds = CGRectMake(0,0, openConfigFrame.width, openConfigFrame.height)
            let toPosition = CGPointMake(openConfigFrame.midX, openConfigFrame.midY)
            
            animator.bounds(toBounds).duration(0.8).easing(.OutExponential)
            animator.position(toPosition).duration(0.8).easing(.OutExponential).primary(true)
            
            animator.triggerOnProgress(0.5, onView: self.dimmerView, animator: {  (animator) in
                animator.alpha(0.5).duration(0.8).easing(.OutExponential)
                animator.backgroundColor(UIColor.blackColor().CGColor).duration(0.6).easing(.Linear)
            })
        }
        
        configView.cacheAnimation(forKey : AnimationKeys.HideConfigAnimation, timingPriority: self.animConfig.primaryTimingPriority) {[unowned self] (animator) in
            
            let toBounds = CGRectMake(0,0, closedConfigFrame.width, closedConfigFrame.height)
            let toPosition = CGPointMake(closedConfigFrame.midX, closedConfigFrame.midY)
            
            animator.bounds(toBounds).duration(0.8).easing(.InOutExponential)
            animator.position(toPosition).duration(0.8).easing(.InOutExponential).primary(true)
            
            animator.triggerOnProgress(0.5, onView: self.dimmerView, animator: {  (animator) in
                animator.alpha(0.0).duration(0.8).easing(.InOutExponential)
                animator.backgroundColor(UIColor.clearColor().CGColor).duration(0.6).easing(.Linear)
            })
        }
        
    }
    
    func tappedShowConfig() {
        configView.applyAnimation(forKey: AnimationKeys.ShowConfigAnimation)
    }
    
    func tappedCloseConfig() {
        configView.applyAnimation(forKey: AnimationKeys.HideConfigAnimation)
    }
    
    func animateView(toFrame : CGRect,
                     velocity : CGPoint = CGPointZero,
                     transform : CATransform3D = CATransform3DIdentity,
                     toAlpha : CGFloat = 1.0,
                     duration : CGFloat = 0.5) {
        
        guard lastToFrame != toFrame else {
            return
        }
        
        
        let config = self.animConfig
        
        let toBounds = CGRectMake(0, 0, toFrame.size.width , toFrame.size.height)
        let toPosition = CGCSRectGetCenter(toFrame)
        
        dragView.animate(self.animConfig.primaryTimingPriority) { (a) in

            a.setDidStartCallback({ (anim) in
                print("DID START")
            })
            
            a.setDidStopCallback({ (anim, complete) in
                print("DID STOP")
            })
            
            a.bounds(toBounds).duration(duration).easing(config.sizeFunction).primary(config.sizePrimary)
            a.position(toPosition).duration(duration).easing(config.positionFunction).primary(config.positionPrimary)
            a.alpha(toAlpha).duration(duration).easing(config.alphaFunction).primary(config.alphaPrimary)
            a.transform(transform).duration(duration).easing(config.transformFunction).primary(config.transformPrimary)
            
            
            if config.enableSecondaryView {
                
                let currentBounds = CGRectMake(0, 0, self.lastToFrame.size.width , self.lastToFrame.size.height)
                let currentPosition = CGCSRectGetCenter(self.lastToFrame)
                let currentAlpha = self.dragView.alpha
                let currentTransform = self.dragView.layer.transform
                
                switch config.triggerType {
                case 1:
                    a.triggerOnProgress(config.triggerProgress,
                                        onView: self.dragView2,
                                        animator: { (a) in
                                            
                                            a.setDidStopCallback({ (anim, complete) in
                                                "DID STOP"
                                            })
                                            a.bounds(currentBounds).duration(duration).easing(config.sizeFunction).primary(config.sizePrimary)
                                            a.position(currentPosition).duration(duration).easing(config.positionFunction).primary(config.positionPrimary)
                                            a.alpha(currentAlpha).duration(duration).easing(config.alphaFunction).primary(config.alphaPrimary)
                                            a.transform(currentTransform).duration(duration).easing(config.transformFunction).primary(config.transformPrimary)
                                            
                    })
                case 2:
                    a.triggerOnValueProgress(config.triggerProgress,
                                             onView: self.dragView2,
                                             animator: { (a) in
                                                
                                                a.bounds(currentBounds).duration(duration).easing(config.sizeFunction).primary(config.sizePrimary)
                                                a.position(currentPosition).duration(duration).easing(config.positionFunction).primary(config.positionPrimary)
                                                a.alpha(currentAlpha).duration(duration).easing(config.alphaFunction).primary(config.alphaPrimary)
                                                a.transform(currentTransform).duration(duration).easing(config.transformFunction).primary(config.transformPrimary)
                    })
                default:
                    a.triggerOnStart(onView: self.dragView2,
                                     animator: { (a) in
                                        
                                        a.bounds(currentBounds).duration(duration).easing(config.sizeFunction).primary(config.sizePrimary)
                                        a.position(currentPosition).duration(duration).easing(config.positionFunction).primary(config.positionPrimary)
                                        a.alpha(currentAlpha).duration(duration).easing(config.alphaFunction).primary(config.alphaPrimary)
                                        a.transform(currentTransform).duration(duration).easing(config.transformFunction).primary(config.transformPrimary)
                                        
                    })
                }
            }
            }
        
        lastToFrame = toFrame
    }
    
    func finalizePanAnimation(toFrame : CGRect,
                              velocity : CGPoint = CGPointZero) {
        
        let finalFrame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 240)
        let finalBounds = CGRectMake(0, 0, toFrame.size.width, toFrame.size.height)
        let finalCenter = CGCSRectGetCenter(finalFrame)
        
        let currentBounds = CGRectMake(0, 0, lastToFrame.size.width , lastToFrame.size.height)
        let currentPosition = CGCSRectGetCenter(lastToFrame)
        let currentAlpha = dragView.alpha
        let currentTransform = dragView.layer.transform
        
        var easingFunction :FAEasing = animConfig.positionFunction
        
        switch animConfig.positionFunction {
        case .SpringDecay(_):
            easingFunction = .SpringDecay(velocity: velocity)
            
        case let .SpringCustom(_, frequency, ratio):
            easingFunction = .SpringCustom(velocity: velocity, frequency: frequency, ratio: ratio)
        default:
            break
        }
        
        let duration : CGFloat = 0.5
        
        dragView.animate(self.animConfig.primaryTimingPriority) { (anim) in

            anim.bounds(finalBounds).duration(0.5).easing(.OutQuadratic).primary(false)
            anim.position(finalCenter).duration(0.6).easing(easingFunction).primary(true)
            
            if self.animConfig.enableSecondaryView {
                switch self.animConfig.triggerType {
                case 1:
                    anim.triggerOnProgress(self.animConfig.triggerProgress, onView: self.dragView2, animator: {[unowned self]  (anim) in
                        anim.bounds(currentBounds).duration(duration).easing(self.animConfig.sizeFunction).primary(self.animConfig.sizePrimary)
                        anim.position(currentPosition).duration(duration).easing(self.animConfig.positionFunction).primary(self.animConfig.positionPrimary)
                        anim.alpha(currentAlpha).duration(duration).easing(self.animConfig.alphaFunction).primary(self.animConfig.alphaPrimary)
                        anim.transform(currentTransform).duration(duration).easing(self.animConfig.transformFunction).primary(self.animConfig.transformPrimary)
                        })
                case 2:
                    anim.triggerOnValueProgress(self.animConfig.triggerProgress, onView: self.dragView2, animator: {[unowned self]  (anim) in
                        anim.bounds(currentBounds).duration(duration).easing(self.animConfig.sizeFunction).primary(self.animConfig.sizePrimary)
                        anim.position(currentPosition).duration(duration).easing(self.animConfig.positionFunction).primary(self.animConfig.positionPrimary)
                        anim.alpha(currentAlpha).duration(duration).easing(self.animConfig.alphaFunction).primary(self.animConfig.alphaPrimary)
                        anim.transform(currentTransform).duration(duration).easing(self.animConfig.transformFunction).primary(self.animConfig.transformPrimary)
                        })
                default:
                    anim.triggerOnStart(onView: self.dragView2, animator: {[unowned self]  (anim) in
                        anim.bounds(currentBounds).duration(duration).easing(self.animConfig.sizeFunction).primary(self.animConfig.sizePrimary)
                        anim.position(currentPosition).duration(duration).easing(self.animConfig.positionFunction).primary(self.animConfig.positionPrimary)
                        anim.alpha(currentAlpha).duration(duration).easing(self.animConfig.alphaFunction).primary(self.animConfig.alphaPrimary)
                        anim.transform(currentTransform).duration(duration).easing(self.animConfig.transformFunction).primary(self.animConfig.transformPrimary)
                        })
                }
            }
            }
    }
}
