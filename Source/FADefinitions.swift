//
//  FADefinitions.swift
//  FlightAnimator-Demo
//
//  Created by Anton on 4/29/18.
//  Copyright © 2018 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

struct FAConfig
{
	static let InterpolationFrameCount  : CGFloat = 60.0
	
	static let SpringDecayFrequency     : CGFloat = 15.0
	static let SpringDecayDamping       : CGFloat = 0.97
	static let SpringCustomBounceCount  : Int = 4
	
	static let SpringDecayMagnitudeThreshold  : CGFloat = 0.01
	
	static let AnimationTimeAdjustment   : CGFloat = 2.0 * (1.0 / FAConfig.InterpolationFrameCount)
}


public enum FAValueType : Int
{
	case cgFloat, cgPoint, cgSize, cgRect, cgColor, caTransform3d
}

public protocol FAAnimatable
{
	var valueType           : FAValueType { get }
	var vector              : [CGFloat] { get }
	var componentCount      : Int       { get }
	
	var magnitude           : CGFloat   { get }
	var valueRepresentation : AnyObject { get }
	var zeroVelocityValue   : FAAnimatable { get }
	
	func magnitude<T>(toValue value : T) -> CGFloat
	func valueFromComponents<T>(_ vector :  [CGFloat]) -> T
	func progressValue<T>(to value : T, atProgress progress : CGFloat) -> T
	
	func valueProgress<T>(fromValue : T, atValue : T) -> CGFloat
}

public enum FAEasing : Equatable
{
	case linear, smoothStep, smootherStep
	case inAtan, outAtan, inOutAtan
	case inSine, outSine, inOutSine, outInSine
	case inQuadratic, outQuadratic, inOutQuadratic, outInQuadratic
	case inCubic, outCubic, inOutCubic, outInCubic
	case inQuartic, outQuartic, inOutQuartic, outInQuartic
	case inQuintic, outQuintic, inOutQuintic, outInQuintic
	case inExponential, outExponential, inOutExponential, outInExponential
	case inCircular, outCircular, inOutCircular, outInCircular
	case inBack, outBack, inOutBack, outInBack
	case inElastic, outElastic, inOutElastic, outInElastic
	case inBounce, outBounce, inOutBounce, outInBounce
	
	case springDecay(velocity: Any?)
	case springCustom(velocity: Any?, frequency: CGFloat , ratio: CGFloat)
}


/**
Timing Priority to apply during synchronisation of hte animations
within the calling animationGroup.

The more property animations within a group, the more likely some
animations will need more control over the synchronization of
the timing over others.

There are 4 timing priorities to choose from:

.MaxTime, .MinTime, .Median, and .Average

By default .MaxTime is applied, so lets assume we have 4 animations:

1. bounds
2. position
3. alpha
4. transform

FABasicAnimation(s) are not defined as primary by default,
synchronization will figure out the relative progress for each
property animation within the group in flight, then adjust the
timing based on the remaining progress to the final destination
of the new animation being applied.

Then based on .MaxTime, it will pick the longest duration form
all the synchronized property animations, and resynchronize the
others with a new duration, and apply it to the group itself.

If the isPrimary flag is set on the bounds and position
animations, it will only include those two animation in
figuring out the the duration.

Use .MinTime, to select the longest duration in the group
Use .MinTime, to select the shortest duration in the group
Use .Median,  to select the median duration in the group
Use .Average, to select the average duration in the group

- MaxTime: find the longest duration, and adjust all animations to match
- MinTime: find the shortest duration and adjust all animations to match
- Median:  find the median duration, and adjust all animations to match
- Average: find the average duration, and adjust all animations to match
*/

public enum FAPrimaryTimingPriority : Int
{
	case maxTime, minTime, median, average
}
