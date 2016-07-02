//
//  ViewController+Animation.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 6/13/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit
//import FlightAnimator

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
    
    var enableSecondaryView  : Bool = true
    
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
    
        registerAnimation(onView : configView, forKey : AnimationKeys.ShowConfigAnimation, timingPriority: self.animConfig.primaryTimingPriority) { (animator) in
            
            let toBounds = CGRectMake(0,0, openConfigFrame.width, openConfigFrame.height)
            let toPosition = CGPointMake(openConfigFrame.midX, openConfigFrame.midY)
            
            animator.bounds(toBounds).duration(0.8).easing(.OutExponential)
            animator.position(toPosition).duration(0.8).easing(.OutExponential).primary(true)

            animator.triggerOnStart(onView: self.dimmerView, animator: { (animator) in
                animator.alpha(0.5).duration(0.8).easing(.OutExponential)
            })
        }
        
        registerAnimation(onView : configView, forKey : AnimationKeys.HideConfigAnimation, timingPriority: self.animConfig.primaryTimingPriority) { (animator) in

            let toBounds = CGRectMake(0,0, closedConfigFrame.width, closedConfigFrame.height)
            let toPosition = CGPointMake(closedConfigFrame.midX, closedConfigFrame.midY)
            
            animator.bounds(toBounds).duration(0.7).easing(.InOutExponential)
            animator.position(toPosition).duration(0.7).easing(.InOutExponential).primary(true)
        
            animator.triggerOnStart(onView: self.dimmerView, animator: { (animator) in
                animator.alpha(0.0).duration(0.7).easing(.InExponential)
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
        
        let currentBounds = CGRectMake(0, 0, lastToFrame.size.width , lastToFrame.size.height)
        let currentPosition = CGCSRectGetCenter(lastToFrame)
        let currentAlpha = self.dragView.alpha
        let currentTransform = self.dragView.layer.transform
        
        let toBounds = CGRectMake(0, 0, toFrame.size.width , toFrame.size.height)
        let toPosition = CGCSRectGetCenter(toFrame)
        
        registerAnimation(onView : dragView, forKey : AnimationKeys.TapStageOneAnimationKey, timingPriority: self.animConfig.primaryTimingPriority) { (animator) in
            animator.bounds(toBounds).duration(duration).easing(self.animConfig.sizeFunction).primary(self.animConfig.sizePrimary)
            animator.position(toPosition).duration(duration).easing(self.animConfig.positionFunction).primary(self.animConfig.positionPrimary)
            animator.alpha(toAlpha).duration(duration).easing(self.animConfig.alphaFunction).primary(self.animConfig.alphaPrimary)
            animator.transform(transform).duration(duration).easing(self.animConfig.transformFunction).primary(self.animConfig.transformPrimary)
            
            if self.animConfig.enableSecondaryView {
            
            animator.triggerAtTimeProgress(atProgress: 0.5, onView: self.dragView2, animator: { (animator) in
                animator.bounds(currentBounds).duration(duration).easing(self.animConfig.sizeFunction).primary(self.animConfig.sizePrimary)
                animator.position(currentPosition).duration(duration).easing(self.animConfig.positionFunction).primary(self.animConfig.positionPrimary)
                animator.alpha(currentAlpha).duration(duration).easing(self.animConfig.alphaFunction).primary(self.animConfig.alphaPrimary)
                animator.transform(currentTransform).duration(duration).easing(self.animConfig.transformFunction).primary(self.animConfig.transformPrimary)
            })
                
            }
        }

        dragView.applyAnimation(forKey: AnimationKeys.TapStageOneAnimationKey)
        lastToFrame = toFrame
    }
    
    func finalizePanAnimation(toFrame : CGRect,
                              velocity : CGPoint = CGPointZero) {
        
        let finalFrame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 240)
        let finalBounds = CGRectMake(0, 0, toFrame.size.width, toFrame.size.height)
        let finalCenter = CGCSRectGetCenter(finalFrame)
      
        let currentBounds = CGRectMake(0, 0, lastToFrame.size.width , lastToFrame.size.height)
        let currentPosition = CGCSRectGetCenter(lastToFrame)
        let currentAlpha = self.dragView.alpha
        let currentTransform = self.dragView.layer.transform
        
        var easingFunction :FAEasing = .SpringDecay(velocity: velocity)
        
        switch animConfig.positionFunction {
        case let .SpringCustom(_, frequency, ratio):
            easingFunction = .SpringCustom(velocity: velocity, frequency: frequency, ratio: ratio)
        default:
            break
        }
        
        registerAnimation(onView : dragView, forKey : AnimationKeys.PanGestureKey, timingPriority: self.animConfig.primaryTimingPriority) { (animator) in
            animator.bounds(finalBounds).duration(0.6).easing(.Linear).primary(false)
            animator.position(finalCenter).duration(0.0).easing(easingFunction).primary(true)

            
            if self.animConfig.enableSecondaryView {

            animator.triggerAtTimeProgress(atProgress: 0.5, onView: self.dragView2, animator: { (animator) in
                animator.bounds(currentBounds).duration(0.5).easing(self.animConfig.sizeFunction).primary(self.animConfig.sizePrimary)
                animator.position(currentPosition).duration(0.5).easing(self.animConfig.positionFunction).primary(self.animConfig.positionPrimary)
                animator.alpha(currentAlpha).duration(0.5).easing(self.animConfig.alphaFunction).primary(self.animConfig.alphaPrimary)
                animator.transform(currentTransform).duration(0.5).easing(self.animConfig.transformFunction).primary(self.animConfig.transformPrimary)
            })
                
            }
        }

        dragView.applyAnimation(forKey: AnimationKeys.PanGestureKey)
    }
}