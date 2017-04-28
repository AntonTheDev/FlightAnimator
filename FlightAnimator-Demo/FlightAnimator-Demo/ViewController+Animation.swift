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
    
    var primaryTimingPriority : FAPrimaryTimingPriority = .maxTime
    
    var sizeFunction : FAEasing = FAEasing.outSine
    var positionFunction : FAEasing =  FAEasing.springCustom(velocity: CGPoint.zero, frequency: 14, ratio: 0.8)
    var alphaFunction : FAEasing = FAEasing.inSine
    var transformFunction : FAEasing = FAEasing.outBack
    
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
    
    static func titleForFunction(_ function : FAEasing) -> String {
        return functionTypes[functions.index(of: function)!]
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

let screenBounds = UIScreen.main.bounds
let openConfigFrame = CGRect(x: 20, y: 20, width: screenBounds.width - 40, height: screenBounds.height - 40)
let closedConfigFrame = CGRect(x: 20, y: screenBounds.height + 20, width: screenBounds.width - 40, height: screenBounds.height - 40)

extension ViewController {
    
    /**
     Called on viewDidLoad, preloads the animation states into memory
     */
    func registerConfigViewAnimations() {
        
        configView.registerAnimation(forKey : AnimationKeys.ShowConfigAnimation, timingPriority: self.animConfig.primaryTimingPriority) {[unowned self] (animator) in
            
            let toBounds = CGRect(x: 0,y: 0, width: openConfigFrame.width, height: openConfigFrame.height)
            let toPosition = CGPoint(x: openConfigFrame.midX, y: openConfigFrame.midY)
            
            animator.bounds(toBounds).duration(0.8).easing(.outExponential)
            animator.position(toPosition).duration(0.8).easing(.outExponential).primary(true)
            
            animator.triggerOnProgress(0.5, onView: self.dimmerView, animator: {  (animator) in
                animator.alpha(0.5).duration(0.8).easing(.outExponential)
                animator.backgroundColor(UIColor.black.cgColor).duration(0.6).easing(.linear)
            })
        }
        
        configView.registerAnimation(forKey : AnimationKeys.HideConfigAnimation, timingPriority: self.animConfig.primaryTimingPriority) {[unowned self] (animator) in
            
            let toBounds = CGRect(x: 0,y: 0, width: closedConfigFrame.width, height: closedConfigFrame.height)
            let toPosition = CGPoint(x: closedConfigFrame.midX, y: closedConfigFrame.midY)
            
            animator.bounds(toBounds).duration(0.8).easing(.inOutExponential)
            animator.position(toPosition).duration(0.8).easing(.inOutExponential).primary(true)
            
            animator.triggerOnProgress(0.5, onView: self.dimmerView, animator: {  (animator) in
                animator.alpha(0.0).duration(0.8).easing(.inOutExponential)
                animator.backgroundColor(UIColor.clear.cgColor).duration(0.6).easing(.linear)
            })
        }
        
    }
    
    func tappedShowConfig() {
        configView.applyAnimation(forKey: AnimationKeys.ShowConfigAnimation)
    }
    
    func tappedCloseConfig() {
        configView.applyAnimation(forKey: AnimationKeys.HideConfigAnimation)
    }
    
    func animateView(_ toFrame : CGRect,
                     velocity : CGPoint = CGPoint.zero,
                     transform : CATransform3D = CATransform3DIdentity,
                     toAlpha : CGFloat = 1.0,
                     duration : CGFloat = 0.5) {
        
        guard lastToFrame != toFrame else {
            return
        }
        
        
        let config = self.animConfig
        
        let toBounds = CGRect(x: 0, y: 0, width: toFrame.size.width , height: toFrame.size.height)
        let toPosition = CGCSRectGetCenter(toFrame)
        
        dragView.animate(self.animConfig.primaryTimingPriority) { (a) in

            a.setDidStartCallback({ (anim) in
                print("DID START")
            })
            
            a.setDidStopCallback({ (anim) in
                print("DID STOP")
            })
            
            a.setDidCancelCallback({ (anim) in
                print("DID Cancel")
            })
            
            a.bounds(toBounds).duration(duration).easing(config.sizeFunction).primary(config.sizePrimary)
            a.position(toPosition).duration(duration).easing(config.positionFunction).primary(config.positionPrimary)
            a.alpha(toAlpha).duration(duration).easing(config.alphaFunction).primary(config.alphaPrimary)
            a.transform(transform).duration(duration).easing(config.transformFunction).primary(config.transformPrimary)
            
            
            if config.enableSecondaryView {
                
                let currentBounds = CGRect(x: 0, y: 0, width: self.lastToFrame.size.width , height: self.lastToFrame.size.height)
                let currentPosition = CGCSRectGetCenter(self.lastToFrame)
                let currentAlpha = self.dragView.alpha
                let currentTransform = self.dragView.layer.transform
                
                switch config.triggerType {
                case 1:
                    a.triggerOnProgress(config.triggerProgress,
                                        onView: self.dragView2,
                                        animator: { (a) in
                                            
                                            a.setDidStopCallback({ (anim) in
                                                print("DID STOP")
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
    
    func finalizePanAnimation(_ toFrame : CGRect,
                              velocity : CGPoint = CGPoint.zero) {
        
        let finalFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 240)
        let finalBounds = CGRect(x: 0, y: 0, width: toFrame.size.width, height: toFrame.size.height)
        let finalCenter = CGCSRectGetCenter(finalFrame)
        
        let currentBounds = CGRect(x: 0, y: 0, width: lastToFrame.size.width , height: lastToFrame.size.height)
        let currentPosition = CGCSRectGetCenter(lastToFrame)
        let currentAlpha = dragView.alpha
        let currentTransform = dragView.layer.transform
        
        var easingFunction :FAEasing = animConfig.positionFunction
        
        switch animConfig.positionFunction {
        case .springDecay(_):
            easingFunction = .springDecay(velocity: velocity)
            
        case let .springCustom(_, frequency, ratio):
            easingFunction = .springCustom(velocity: velocity, frequency: frequency, ratio: ratio)
        default:
            break
        }
        
        let duration : CGFloat = 0.5
        
        dragView.animate(self.animConfig.primaryTimingPriority) { (anim) in

            anim.bounds(finalBounds).duration(0.5).easing(.outQuadratic).primary(false)
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
