//
//  UIView+FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public func registerAnimation(onView view : UIView, forKey key: String, maker : (maker : FlightAnimator) -> Void ) {
    let newMaker = FlightAnimator(withView: view, forKey : key)
    maker(maker : newMaker)
}

public extension UIView {
      
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









