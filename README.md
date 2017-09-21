# FlightAnimator
[![Cocoapods Compatible](https://img.shields.io/badge/pod-v0.9.9-blue.svg)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)]()
[![Build Status](https://travis-ci.org/AntonTheDev/FlightAnimator.svg?branch=master)](https://travis-ci.org/AntonTheDev/FlightAnimator)
[![Platform](https://img.shields.io/badge/platform-iOS%20|%20tvOS-lightgrey.svg)]()
[![License](https://img.shields.io/badge/license-MIT-343434.svg)](/LICENSE.md)
[![Join the chat at https://gitter.im/AntonTheDev/FlightAnimator](https://badges.gitter.im/AntonTheDev/FlightAnimator.svg)](https://gitter.im/AntonTheDev/FlightAnimator?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

![alt tag](/Documentation/FlightBanner.jpg?raw=true)

**Moved to Swift 3.1 Support:**

* For Swift 3.1 - Use **tag** Version 0.9.9
* See [Installation Instructions](/Documentation/installation.md) for clarification

## Introduction

FlightAnimator provides a very simple blocks based animation definition language that allows you to dynamically create, configure, group, sequence, cache, and reuse property animations.

Unlike `CAAnimationGroups`, and `UIViewAnimations`, which animate multiple properties using a single easing curve, **FlightAnimator** allows configuration, and synchronization, of unique easing curves per individual property animation.

## Features

- [x] [46+ Parametric Curves, Decay, and Springs](/Documentation/parametric_easings.md)
- [x] Blocks Syntax for Building Complex Animations
- [x] Chain and Sequence Animations:
- [x] Apply Unique Easing per Property Animation
- [x] Advanced Multi-Curve Group Synchronization
- [x] Define, Cache, and Reuse Animations


Check out the [FlightAnimator Project Demo](#demoApp) in the video below to <br> experiment with all the different capabilities of the **FlightAnimator**.

<p align=left>
<a href="http://www.youtube.com/watch?feature=player_embedded&v=8XyH5mpfoC8&vq=hd1080
" target="_blank"><img src="http://img.youtube.com/vi/8XyH5mpfoC8/0.jpg"
alt="FlightAnimator Demo" border="0" /> </a>
</p>


## Installation

* **Requirements** : XCode 7.3+, iOS 8.0+, tvOS 9.0+
* [Installation Instructions](/Documentation/installation.md)
* [Release Notes](/Documentation/release_notes.md)

## Communication

- If you **found a bug**, or **have a feature request**, open an issue.
- If you **need help** or a **general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/flight-animator). (tag 'flight-animator')
- If you **want to contribute**, review the [Contribution Guidelines](/Documentation/CONTRIBUTING.md), and submit a pull request.

## Basic Use

**FlightAnimator** provides a very flexible syntax for defining animations ranging in complexity with ease. Following a blocks based builder approach you can easily define an animation group, and it's property animations in no time.

Under the hood animations built are `CAAnimationGroup`(s) with multiple custom `CAKeyframeAnimation`(s) defined uniquely per property. Once it's time to animate, **FlightAnimator** will dynamically synchronize the remaining progress for all the animations relative to the current presentationLayer's values, then continue to animate to it's final state.

### Simple Animation

To really see the power of **FlightAnimator**, let's first start by defining an animation using `CoreAnimation`, then re-define it using the framework's blocks based syntax. The animation below uses a `CAAnimationGroup` to group 3 individual `CABasicAnimations` for alpha, bounds, and position.

```swift
let alphaAnimation 			= CABasicAnimation(keyPath: "position")
alphaAnimation.toValue 			= 0.0
alphaAnimation.fromValue 		= 1.0
alphaAnimation.fillMode              	= kCAFillModeForwards
alphaAnimation.timingFunction        	= CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)

let boundsAnimation 			= CABasicAnimation(keyPath: "bounds")
boundsAnimation.toValue 		= NSValue(CGRect : toBounds)
boundsAnimation.fromValue 		= NSValue(CGRect : view.layer.bounds)
boundsAnimation.fillMode              	= kCAFillModeForwards
boundsAnimation.timingFunction        	= CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)

let positionAnimation 			= CABasicAnimation(keyPath: "position")
positionAnimation.toValue 		= NSValue(CGPoint : toPosition)
positionAnimation.fromValue 		= NSValue(CGPoint : view.layer.position)
positionAnimation.fillMode              = kCAFillModeForwards
positionAnimation.timingFunction        = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)

let progressAnimation 			= CABasicAnimation(keyPath: "animatableProgress")
progressAnimation.toValue 		= 1.0
progressAnimation.fromValue 		= 0
progressAnimation.fillMode              = kCAFillModeForwards
progressAnimation.timingFunction        = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)

let animationGroup 			= CAAnimationGroup()
animationGroup.duration 		= 0.5
animationGroup.removedOnCompletion   	= true
animationGroup.animations 		= [alphaAnimation,  boundsAnimation, positionAnimation, progressAnimation]

view.layer.addAnimation(animationGroup, forKey: "PositionAnimationKey")
view.frame = toFrame
```

Now that we saw the example above. Let's re-define **FlightAnimator**'s blocks based syntax


```swift
view.animate {  [unowned self] (animator) in
	animator.alpha(toAlpha).duration(0.5).easing(.OutCubic)
	animator.bounds(toBounds).duration(0.5).easing(.OutCubic)
      	animator.position(toPosition).duration(0.5).easing(.OutCubic)
      	animator.value(toProgress, forKeyPath : "animatableProgress").duration(0.5).easing(.OutCubic)
}
```

Calling `animate(:)` on the **view** begins the `FAAnimationGroup` creation process. Inside the closure the **animator** creates, configures, then appends custom animations to the newly created parent group. Define each individual property animation by calling one of the  [pre-defined property setters](/Documentation/predefined_setters.md), and/or the `func value(:, forKeyPath:) -> PropertyAnimator` method for **any** other animatable property.

Once the property animation is initiated, recursively configure the `PropertyAnimator` by chaining duration, easing, and/or primary designation, to create the final `FABasicAnimation`, and add it to the parent group.

```swift
func duration(duration : CGFloat) -> PropertyAnimator
func easing(easing : FAEasing) -> PropertyAnimator
func primary(primary : Bool) -> PropertyAnimator
```

Once the function call exits the closure, **FlightAnimator** performs the following:

1. Adds the newly created `FAAnimationGroup` to the calling **view**'s layer,
2. Synchronizes the grouped `FABasicAnimations` relative to the calling **view**'s presentation layer values
3. Triggers the animation by applying the **toValue** from the grouped animations to to the calling **view**'s layer.

## Chaining Animations

Chaining animations together in FlightAnimator is simple.

### Trigger on Start

The animation created on the secondaryView is triggered once the the primaryView's animation begins.    	

```swift
primaryView.animate { [unowned self] (animator) in
	....

    animator.triggerOnStart(onView: self.secondaryView, animator: { (animator) in
         ....
    })
}
```

### Trigger on Completion

The animation created on the secondaryView is triggered once the the primaryView's animation completes.

```swift
primaryView.animate { [unowned self] (animator) in
	....

    animator.triggerOnCompletion(onView: self.secondaryView, animator: { (animator) in
         ....
    })
}
```

### Time Progress Trigger

The animation created on the secondaryView is triggered when the driving animation reaches the relative half way point in duration on the primaryView's animation.

```swift
primaryView.animate { [unowned self] (animator) in
	....

    animator.triggerOnProgress(0.5, onView: self.secondaryView, animator: { (animator) in
         ....
    })
}
```

### Value Progress Trigger

The animation created on the secondaryView is triggered when the driving animation reaches the relative half way point between the fromValue and toValue of the primaryView's animation. This is driven

```swift
primaryView.animate { [unowned self] (animator) in
	....

    animator.triggerOnValueProgress(0.5, onView: self.secondaryView, animator: { (animator) in
         ....
    })
}
```

### Nesting Animation Triggers

There is built in support for nesting triggers within triggers to sequence animations, and attach multiple types of triggers relative to the scope of the parent animation.


```swift
primaryView.animate { [unowned self] (animator) in
	....

    animator.triggerOnStart(onView: self.secondaryView, animator: { (animator) in
         -> Relative to primaryView animation

	animator.triggerOnCompletion(onView: self.tertiaryView, animator: { (animator) in
		-> Relative to secondaryView animation

        	animator.triggerOnProgress(0.5, onView: self.quaternaryView, animator: { (animator) in
			-> Relative to tertiaryView animation
    		})
     	})

        animator.triggerOnValueProgress(0.5, onView: self.quinaryView, animator: { (animator) in
         		-> Relative to secondaryView animation
    	})
    })

    animator.triggerOnStart(onView: self.senaryView, animator: { (animator) in
         	-> Relative to primaryView animation
    })
}
```

### CAAnimationDelegate Callbacks

Sometimes there is a need to perform some logic on the start of an animation, or the end of the animation by responding to the CAAnimationDelegate methods

```swift
view.animate { (animator) in
    ....

    animator.setDidStartCallback({ (animator) in
         // Animation Did Start
    })

    animator.setDidStopCallback({ (animator, complete) in
         // Animation Did Stop   
    })
}
```

These can be nested just as the animation triggers, and be applied animator on the group in scope of the animation creation closure by the animator.

## Cache & Reuse Animations

FlightAnimator allows for registering animations (aka states) up front with a unique animation key. Once defined it can be manually triggered at any time in the application flow using the animation key used registration.

When the animation is applied, if the view is in mid flight, it will synchronize itself with the current presentation layer values, and animate to its final destination.

#### Register/Cache Animation

To register an animation, call a globally defined method, and create an animations just as defined earlier examples within the maker block. The following example shows how to register, and cache an animation for a key on a specified view.

```swift
struct AnimationKeys {
	static let CenterStateFrameAnimation  = "CenterStateFrameAnimation"
}
...

view.registerAnimation(forKey : AnimationKeys.CenterStateFrameAnimation) { (animator) in
      animator.bounds(newBounds).duration(0.5).easing(.OutCubic)
      animator.position(newPositon).duration(0.5).easing(.OutCubic)
})
```

This animation is only cached, and is not performed until it is manually triggered.

#### Apply Registered Animation


To trigger the animation call the following

```swift
view.applyAnimation(forKey: AnimationKeys.CenterStateFrameAnimation)
```

To apply final values without animating the view, override the default animated flag to false, and it will apply all the final values to the model layer of the associated view.


```swift
view.applyAnimation(forKey: AnimationKeys.CenterStateFrameAnimation, animated : false)
```


## Advanced Use

### Timing Adjustments

Due to the dynamic nature of the framework, it may take a few tweaks to get the animation just right.

FlightAnimator has a few options for finer control over timing synchronization:

* **Timing Priority** - Adjust how the time is select during synchronization of the overall animation
* **Primary Drivers** - Defines animations that affect timing during synchronization of the overall animation

#### Timing Priority

First a little background, the framework basically does some magic so synchronize the time by prioritizing the maximum time remaining based on progress if redirected in mid flight.

Lets look at the following example of setting the timingPriority on a group animation to .MaxTime, which is the default value for FlightAnimator.

```swift
func animateView(toFrame : CGRect) {

	let newBounds = CGRectMake(0,0, toFrame.width, toFrame.height)
	let newPosition = CGPointMake(toFrame.midX, toFrame.midY)

	view.animate(.MaxTime) { (animator) in
      		animator.bounds(newBounds).duration(0.5).easing(.OutCubic)
      		animator.position(newPositon).duration(0.5).easing(.InSine)
	}
}
```
Just like the demo app, This method gets called by different buttons, and takes on the frame value of button that triggered the method. Let's the animation has been triggered, and is in mid flight. While in mid flight another button is tapped, a new animation is applied, and ehe position changes, but the bounds stay the same.

Internally the framework will figure out the current progress in reference to the last animation, and will select the max duration value from the array of durations on the grouped property animations.

Lets assume the bounds don't change, thus animation's duration is assumed to be 0.0 after synchronization. The new animation will synchronize to the duration of the position animation based on progress, and automatically becomes the max duration based on the **.MaxTime** timing priority.

The timing priority can also be applied on ``triggerAtTimeProgress()``  or ``triggerAtValueProgress()``. Now this leads into the next topic, and that is the primary flag.

The more property animations within a group, the more likely the need to adjust how the timing is applied. For this purpose there are 4 timing priorities to choose from:

* .MaxTime
* .MinTime
* .Median
* .Average


#### Primary Flag

As in the example prior, there is a mention that animations can get quite complex, and the more property animations within a group, the more likely the animation will have a hick-up in the timing, especially when synchronizing 4+ animations with different curves and durations.

For this purpose, set the primary flag on individual property animations, and designate them as primary duration drivers. By default, if no property animation is set to primary, during synchronization, FlightAnimator will use the timing priority setting to find the corresponding value from all the animations after progress synchronization.

If we need only some specific property animations to define the progress accordingly, and become the primary drivers, set the primary flag to true, which will exclude any other animation which is not marked as primary from consideration.

Let's look at an example below of a simple view that is being animated from its current position to a new frame using bounds and position.

```swift
view.animate(.MaxTime) { (animator) in
      animator.bounds(newBounds).duration(0.5).easing(.OutCubic).primary(true)
      animator.position(newPositon).duration(0.5).easing(.InSine).primary(true)
      animator.alpha(0.0).duration(0.5).easing(.OutCubic)
      animator.transform(newTransform).duration(0.5).easing(.InSine)
}
```

Simple as that, now when the view is redirected during an animation in mid flight, only the bounds and position animations will be considered as part of the timing synchronization.


### .SpringDecay w/ Initial Velocity

When using a UIPanGestureRecognizer to move a view around on the screen by adjusting its position, and say there is a need to smoothly animate the view to the final destination right as the user lets go of the gesture. This is where the .SpringDecay easing comes into play. The .SpringDecay easing will slow the view down easily into place, all that need to be configured is the initial velocity, and it will calculate its own time relative to the velocity en route to its destination.

Below is an example of how to handle the handoff and use ``.SpringDecay(velocity: velocity)`` easing to perform the animation.

```swift
func respondToPanRecognizer(recognizer : UIPanGestureRecognizer) {
    switch recognizer.state {
    ........

    case .Ended:
    	let currentVelocity = recognizer.velocityInView(view)

      	view.animate { (animator) in
         	animator.bounds(finalBounds).duration(0.5).easing(.OutCubic)
  			animator.position(finalPositon).duration(0.5).easing(.SpringDecay(velocity: velocity))
      	}
    default:
        break
    }
}
```

## Reference

[Supported Parametric Curves](/Documentation/parametric_easings.md)

[CALayer's Supported Animatable Property](/Documentation/supported_animatable_properties.md)

[Current Release Notes](/Documentation/release_notes.md)

[Contribution Guidelines](/Documentation/CONTRIBUTING.md)


### <a name="demoApp"></a>Framework Demo App

The project includes a highly configurable demo app that allows for experimentation to explore resulting effects of the unlimited configurations FlightAnimator supports.

Demo Features Included:

* Animate a view to different location on the screen
* Drag and release view to apply Decay easing to the final destination
* Adjust timing curves for bounds, position, alpha, and transform.
* Enable a secondary view, which follows the main view to it's last location
* Adjust group timing priority to test synchronization
* Adjust progress for time based/value based triggers on the secondary view


## License

*FlightAnimator is released under the MIT license. See [License](/LICENSE.md) for details.*
