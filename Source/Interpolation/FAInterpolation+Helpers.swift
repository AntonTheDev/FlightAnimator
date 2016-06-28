//
//  FAInterpolation+Helpers.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 4/23/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit


// TODO: - Not sure where to put these micro extensions yet

extension Array where Element: Comparable {
    var median: Element {
        return self.sort(<)[self.count / 2]
    }
}

extension CGFloat {
    mutating func roundToScreen() {
        let scale = UIScreen.mainScreen().scale
        self = CGFloat(round(self * scale) / scale)
    }
}