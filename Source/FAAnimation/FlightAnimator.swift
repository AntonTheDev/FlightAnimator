//
//  UIView+FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public func registerAnimation(onView view : UIView, forKey key: String, animator : (animator : FlightAnimator) -> Void ) {
    let newAnimator = FlightAnimator(withView: view, forKey : key)
    animator(animator : newAnimator)
}

public extension UIView {
    
    func animate(@noescape animator : (animator : FlightAnimator) -> Void ) {
        let newAnimator = FlightAnimator(withView: self, forKey : "AppliedAnimation")
        animator(animator : newAnimator)
        applyAnimation(forKey: "AppliedAnimation")
    }

    func applyAnimation(forKey key: String,
                        animated : Bool = true) {
        
        if let cachedAnimationsArray = self.cachedAnimations,
            let animation = cachedAnimationsArray[key] {
            animation.applyFinalState(animated)
        }
    }
    
    func applyAnimationTree(forKey key: String,
                            animated : Bool = true) {
        
        applyAnimation(forKey : key, animated:  animated)
        applyAnimationsToSubViews(self, forKey: key, animated: animated)
    }
}









