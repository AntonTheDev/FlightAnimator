//
//  FADefinitions+Defaults.swift
//  FlightAnimator-Demo
//
//  Created by Anton on 4/29/18.
//  Copyright © 2018 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

extension FAAnimatable
{
	public func magnitude<T>(toValue value : T) -> CGFloat
	{
		return abs(self.magnitude - (value as! FAAnimatable).magnitude)
	}
	
	public var componentCount : Int {
		get {
			return vector.count
		}
	}
	
	public func valueProgress<T>(fromValue : T, atValue : T) -> CGFloat
	{
		guard let fromValue = fromValue as? FAAnimatable,
			let atValue = atValue as? FAAnimatable else
		{
			return 0.0
		}
		
		let progressedMagnitude = atValue.magnitude(toValue:fromValue)
		let overallMagnitude = fromValue.magnitude(toValue:self)
		
		if overallMagnitude == 0.0
		{
			return 1.0
		}
		
		return abs(progressedMagnitude / overallMagnitude)
	}
}


public func -<T : FAAnimatable>(lhs:T, rhs:T) -> T
{
	var calculatedComponents = [CGFloat]()
	
	for index in 0..<lhs.vector.count {
		let vectorDiff = lhs.vector[index] - rhs.vector[index]
		calculatedComponents.append(vectorDiff)
	}
	
	return lhs.valueFromComponents(calculatedComponents)
}


public func ==(lhs:FAAnimatable, rhs:FAAnimatable) -> Bool
{
	if  lhs.vector.count == rhs.vector.count
	{
		for index in 0..<lhs.vector.count {
			if lhs.vector[index] != rhs.vector[index] {
				return false
			}
		}
	}
	
	return true
}


