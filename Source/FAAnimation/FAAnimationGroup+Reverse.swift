//
//  FAAnimationGroup+Reverse.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 4/30/18.
//  Copyright © 2018 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Auto Reverse Logic

internal extension FAAnimationGroup
{    
    func configureAutoreverseIfNeeded()
    {
        if autoreverse
        {
            if autoreverseConfigured == false
            {
                configuredAutoreverseGroup()
            }
            
            if autoreverseCount == 0
            {
                return
            }
            
            if autoreverseActiveCount >= (autoreverseCount * 2)
            {
                clearAutoreverseGroup()
                return
            }
            
            autoreverseActiveCount = autoreverseActiveCount + 1
        }
    }
    
    func configuredAutoreverseGroup()
    {
        let animationGroup = FAAnimationGroup()
        
        animationGroup.animationKey            = animationKey! + "REVERSE"
        animationGroup.animatingLayer          = animatingLayer
        animationGroup.animations              = reverseAnimationArray()
        animationGroup.duration                = duration
        animationGroup.primaryTimingPriority   = primaryTimingPriority
        animationGroup.autoreverse             = autoreverse
        animationGroup.autoreverseCount        = autoreverseCount
        animationGroup.autoreverseActiveCount  = autoreverseActiveCount
        animationGroup.reverseEasingCurve      = reverseEasingCurve
        
        if let view =  animatingLayer?.owningView()
        {
            let progressDelay = max(0.0 , autoreverseDelay/duration)
            configureFAAnimationTrigger(animationGroup, onView: view, atTimeProgress : 1.0 + CGFloat(progressDelay))
        }
        
        isRemovedOnCompletion = false
    }
    
    func clearAutoreverseGroup()
    {
        _animationTriggerArray = [FAAnimationTrigger]()
        isRemovedOnCompletion = true
        stopTriggerTimer()
    }
    
    func reverseAnimationArray() ->[FABasicAnimation]
    {
        var reverseAnimationArray = [FABasicAnimation]()
        
        if let animations = self.animations
        {
            for animation in animations
            {
                if let customAnimation = animation as? FABasicAnimation
                {
                    let newAnimation = FABasicAnimation(keyPath: customAnimation.keyPath)
                    newAnimation.easingFunction = reverseEasingCurve ? customAnimation.easingFunction.reverseEasing() : customAnimation.easingFunction
                    
                    newAnimation.isPrimary = customAnimation.isPrimary
                    newAnimation.values = customAnimation.values!.reversed()
                    newAnimation.toValue = customAnimation.fromValue
                    newAnimation.fromValue = customAnimation.toValue
                    
                    reverseAnimationArray.append(newAnimation)
                }
            }
        }
        
        return reverseAnimationArray
    }
}

