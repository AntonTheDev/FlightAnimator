#FlightAnimator

[![Cocoapods Compatible](https://img.shields.io/badge/pod-v0.1.0Beta-blue.svg)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)]()
[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)]()
[![License](https://img.shields.io/badge/license-MIT-343434.svg)]()

![alt tag](/Documentation/FlightBanner.jpg?raw=true)

##Introduction

***Currently found on dev branch until documentation is complete***

Flight Animator is a natural animation engine built on top of CoreAnimation. The framework uses CAKeyframeAnimation(s) to dynamically interpolate based on the presentation layer's values when the animation is applied. With a blocks based approach it is very easy to create, configure, caching, reusability dynamically on the current state, to even more advanced options. 
<br>


##Features

* Seamless integration mimicking CoreAnimation APIs
* Damping, Decay, and 33 Different Parametric Curves
* Block-Based Animation Statewise Configuration
* Key based animation caching
* Easing curve synchronization
* Block-Based CoreAnimation delegation
* Animation progress scrubbing
* View Hierarchy manipulation in mid animation aka flight :)

##Installation

* [Installation Documentation](/Documentation/installation.md)

##Basic Use 

Since the framework was build mimicking CoreAnimation's APIs allowing simple integration wherever CABasicAnimations, and CAAnimationGroups are used. FAAnimation has multiple approaches in it can be used and is very flexible at the moment.

Let's explore how to take a currently defined animation, and easily convert it to FAAnimation to unlock more advanced features


###Integration

Let's explore how to easily convert an existing CABasicAnimation to an FAAnimation, to unlock more advanced features which we will explore later in the documentation.

##### CABasicAnimation vs. FAAnimation

Using a CABasicAnimation, it can get lengthy to write an animation. Even after creating some sort of helper mechanism, CABasicAnimations have their limitations, especially the lack of timingFunctions. Let's observe the following CABasicAnimation. 

```
	let toCenterPoint = CGPointMake(100,100)

    let positionAnimation 					= CABasicAnimation(keyPath: "position")
    positionAnimation.duration 				= 0.5
    positionAnimation.toValue 				= NSValue(CGPoint : toCenterPoint)
    positionAnimation.fromValue 			= NSValue(CGPoint : view.layer.position)
    positionAnimation.fillMode              = kCAFillModeForwards
    positionAnimation.removedOnCompletion   = false
    positionAnimation.timingFunction        = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)

    view.layer.addAnimation(positionAnimation, forKey: "PositionAnimationKey")
    view.center = toCenterPoint
```
Below is the equvalent using FAAnimation.

```
	let toCenterPoint = CGPointMake(100,100)
	
    let positionAnimation 					= FAAnimation(keyPath: "position")
    positionAnimation.toValue 				= NSValue(CGPoint : toCenterPoint)
    positionAnimation.duration 				= 0.5
	positionAnimation.easingFuntion         = .EaseOutCubic
    
    view.layer.addAnimation(positionAnimation, forKey: "PositionAnimationKey")
    view.center = toCenterPoint
```

The key differences you will notice:

1. `CABasicAnimation` becomes an instance of `FAAnimation`
2. The **removedOnCompletion**, **fillMode**, and **fromValue** are now set automatically by the framework
3. The **timingFunction** becomes the **easingFuntion**, with 35 enumerated options4. 


##### CAAnimationGroup vs. FAAnimationGroup

As easy it is to conver a CABasicAnimation to an FAAnimation, and before diving into some more advanced topics, lets now take a quick look at how the CAAnimationGroup compares to the FAAnimationGroup. 

First lets created an two animations to animate the frame of our view. Observe how we create a following CAAnimationGroup, with two animations, one for bounds, and the other for position.

```
	let toFrame  		= CGRectMake(100,100,100,100)
	let toCenter 		= CGPointMake(toFrame.midX, toFrame.midY)
	let toBounds 		= CGCGRectMake(0, 0, toFrame.width, toFrame.height)

    let positionAnimation 					= CABasicAnimation(keyPath: "position")
    positionAnimation.duration 				= 0.5
    positionAnimation.toValue 				= NSValue(CGPoint : toCenterPoint)
    positionAnimation.fromValue 			= NSValue(CGPoint : view.layer.position)
    positionAnimation.fillMode              = kCAFillModeForwards
    positionAnimation.removedOnCompletion   = false
    positionAnimation.timingFunction        = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)

    let boundsAnimation 					= CABasicAnimation(keyPath: "bounds")
    boundsAnimation.duration 				= 0.5
    boundsAnimation.toValue 				= NSValue(CGRect : toBounds)
    boundsAnimation.fromValue 				= NSValue(CGRect : view.layer.bounds)
    boundsAnimation.fillMode              	= kCAFillModeForwards
    boundsAnimation.removedOnCompletion   	= false
    boundsAnimation.timingFunction        	= CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)

	let animationGroup = CAAnimationGroup()
	animationGroup.timingFunction = kCAMediaTimingFunctionEaseInEaseOut
	animationGroup.duration = 0.5
	animationGroup.animations = [positionAnimation, boundsAnimation]

    view.layer.addAnimation(animationGroup, forKey: "PositionAnimationKey")
    view.frame = toFrame
```

Now let's look at how he would implement this using FAAnimationGroup

```
	let toFrame  		= CGRectMake(100,100,100,100)
	let toCenter 		= CGPointMake(toFrame.midX, toFrame.midY)
	let toBounds 		= CGRectMake(0, 0, toFrame.width, toFrame.height)

    let positionAnimation 					= FAAnimation(keyPath: "position")
    positionAnimation.duration 				= 0.5
    positionAnimation.toValue 				= NSValue(CGPoint : toCenterPoint)
    positionAnimation.easingFuntion         = .EaseOutCubic

    let boundsAnimation 					= FAAnimation(keyPath: "bounds")
    boundsAnimation.duration 				= 0.5
    boundsAnimation.toValue 				= NSValue(CGRect : toBounds)
    boundsAnimation.easingFuntion          = .EaseOutCubic
    
	let animationGroup = FAAnimationGroup()
	animationGroup.animations = [positionAnimation, boundsAnimation]

    view.layer.addAnimation(animationGroup, forKey: "PositionAnimationKey")
    view.frame = toFrame
```

1. `CAAnimationGroup` becomes an instance of `FAAnimationGroup`
2. The **removedOnCompletion**, **fillMode**, and **fromValue** are now set automatically by the framework
3. The **timingFunction** becomes the **easingFuntion**, with 35 enumerated options

###Caching Animations

The cool thing about this framework is that you can register animations for a specific key, and trigger them as needed based on the Animation Key it registered against. By defining multiple states up front, we can toggle them when needed, and it will synchronize / interpolate all the values accordingly when applied.

####Register Animation

FAAnimation allows for caching animations, and reusing them at a later point. for the purpose of this example lets first create an animation key to register a position animation against

```
	struct AnimationKeys {
    	static let PositionAnimation  = "PositionAnimation"
	}
```

Now that the key is defined, create lets create an animation.

```
    let positionAnimation 					= FAAnimation(keyPath: "position")
    positionAnimation.toValue 				= NSValue(CGPoint : toCenterPoint)
    positionAnimation.duration 				= 0.5
	positionAnimation.easingFuntion         = .EaseOutCubic
``` 

Once the animation is created, we then need to register it with to the view with out defined animation key.

```
	// Register Animation Groups
	view.registerAnimation(positionAnimation, forKey: AnimationKeys.PositionAnimation)
```

**Note**: Registering an FAAnimationGroup works the exact same way as the registering an FAAnimation documented above. Technically, when registering a simple FAAnimation, the framework wraps the animation in an FAAnimationGroup anyways.

####Applying Registered Animations

To apply the animation state, all we have to do is call the following. This will synchronize the current presentations values with a prior animation, apply the relative remaining time of travel, and will apply the animation to the final destination.

```
	 view.applyAnimation(forKey: AnimationKeys.PositionAnimation)
```

If you want to just apply the final values of a registered animation without actually performing the animation, just call the following

```
	 view.applyAnimation(forKey: AnimationKeys.PositionAnimation, animated : false)
```

####Register Waterfall Animations


###Block Based Animations

```
	struct AnimationKeys {
    	static let InitialStateFrameAnimation  = "InitialStateFrameAnimation"
	}
	
	...
	
	let toFrame         = CGRectMake(100,100,100,100)
    let toCenter        = CGPointMake(toFrame.midX, toFrame.midY)
    let toBounds        = CGRectMake(0, 0, toFrame.width, toFrame.height)

 	view.registerAnimation(forKey: AnimationKeys.InitialStateFrameAnimation, createMaker:  { (maker) in
            maker.addAnimation(forKeyPath: "bounds",
                duration: 0.5,
                easingFunction: .EaseOutCubic,
                toValue: toBounds))

            maker.addAnimation(forKeyPath: "position",
                duration: 0.5,
                easingFunction: .EaseOutCubic,
                toValue: toCenter)
    })
```
##Future Enhancements

TBC

##Appendix

###Supported Animatable Properties

The following animatable properties are supported by FlightAnimator

* anchorPoint : CGPoint
* borderWidth : CGFloat
* bounds : CGRect
* contentsRect : CGRect
* cornerRadius : CGFloat
* opcacity : CGFloat
* position : CGFloat
* shadowOffset : CGPoint
* shadowOpacity : CGFloat
* shadowRadius : CGFloat
* sublayerTransform : CATransform3D
* transform : CATransform3D
* zPosition : CGFloat

FlightAnimator also supports any user defined animatable properties of the following types:

* CGFloat
* CGSize
* CGPoint
* CGRectC
* CATransform3D

###Supported Easing Curves

*  Linear
*  LinearSmooth
*  LinearSmoother
*  EaseInSine
*  EaseOutSine
*  EaseInOutSine
*  EaseInQuadratic
*  EaseOutQuadratic
*  EaseInOutQuadratic
*  EaseInCubic
*  EaseOutCubic
*  EaseInOutCubic
*  EaseInQuartic
*  EaseOutQuartic
*  EaseInOutQuartic
*  EaseInQuintic
*  EaseOutQuintic
*  EaseInOutQuintic
*  EaseInExponential
*  EaseOutExponential
*  EaseInOutExponential
*  EaseInCircular
*  EaseOutCircular
*  EaseInOutCircular
*  EaseInBack
*  EaseOutBack
*  EaseInOutBack
*  EaseInElastic
*  EaseOutElastic
*  EaseInOutElastic
*  EaseInBounce
*  EaseOutBounce
*  EaseInOutBounce
*  SpringDecay(velocity)
*  SpringCustom(velocity, frequency, damping)

## License
<br>

     The MIT License (MIT)  
      
     Copyright (c) 2016 Anton Doudarev  
      
     Permission is hereby granted, free of charge, to any person obtaining a copy
     of this software and associated documentation files (the "Software"), to deal
     in the Software without restriction, including without limitation the rights
     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
     copies of the Software, and to permit persons to whom the Software is
     furnished to do so, subject to the following conditions:  
     
     The above copyright notice and this permission notice shall be included in all
     copies or substantial portions of the Software.  
      
     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
     SOFTWARE.  