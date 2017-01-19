//
//  FlightAnimate+Private.swift
//  
//
//  Created by Anton on 6/29/16.
//
//

import Foundation
import UIKit

internal let DebugTriggerLogEnabled = false

open class FlightAnimator {
    
    internal weak var associatedView : UIView?
    internal var animationKey : String?
    
    var animationConfigurations = [String : FAPropertyAnimator]()
    var primaryTimingPriority : FAPrimaryTimingPriority = .maxTime
    
    init(withView view : UIView, forKey key: String, priority : FAPrimaryTimingPriority = .maxTime) {
        animationKey = key
        associatedView = view
        primaryTimingPriority = priority
        configureNewGroup()
    }
    
    fileprivate func configureNewGroup() {
        
        if associatedView!.cachedAnimations == nil {
            associatedView!.cachedAnimations = [NSString : FAAnimationGroup]()
        }
       
        if associatedView!.cachedAnimations!.keys.contains(NSString(string: animationKey!)) {
            associatedView!.cachedAnimations![NSString(string: animationKey!)]?.stopTriggerTimer()
            associatedView!.cachedAnimations![NSString(string: animationKey!)] = nil
        }
        
        let newGroup = FAAnimationGroup()
        newGroup.configureAnimationGroup(withLayer: associatedView?.layer, animationKey: animationKey)
        newGroup.primaryTimingPriority = primaryTimingPriority
        
        associatedView!.cachedAnimations![NSString(string: animationKey!)] = newGroup
    }
    
    internal func triggerAnimation(_ timingPriority : FAPrimaryTimingPriority = .maxTime,
                                   timeBased : Bool,
                                   view: UIView,
                                   progress: CGFloat = 0.0,
                                   animator: (_ animator : FlightAnimator) -> Void) {

        let triggerKey = UUID().uuidString
        
        if let animationGroup = associatedView!.cachedAnimations![NSString(string: animationKey!)] {
            
            let animationTrigger = AnimationTrigger()
            animationTrigger.isTimedBased = timeBased
            animationTrigger.triggerProgessValue = progress
            animationTrigger.animationKey = triggerKey as NSString?
            animationTrigger.animatedView = view
            
            animationGroup._segmentArray.append(animationTrigger)

            associatedView!.appendAnimation(animationGroup, forKey: animationKey!)
        }
        
        let newAnimator = FlightAnimator(withView: view, forKey : triggerKey,  priority : timingPriority)
        animator(newAnimator)
    }
}
