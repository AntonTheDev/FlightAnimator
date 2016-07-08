#FlightAnimator


[![Cocoapods Compatible](https://img.shields.io/badge/pod-v0.8.0-blue.svg)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)]()
[![Platform](https://img.shields.io/badge/platform-ios | tvos-lightgrey.svg)]()
[![License](https://img.shields.io/badge/license-MIT-343434.svg)](/LICENSE.md)

![alt tag](/Documentation/FlightBanner.jpg?raw=true)

##Introduction

FlightAnimator is a natural animation engine built on top of CoreAnimation, and provides a very simple blocks based syntax to create, configure, cache, and reuse animations dynamically. 

A unique to feature about FlightAnimator, is that you can group multiple animations, and apply different easing curves per property. FlightAnimator takes care of the rest to synchronize them accordingly to create some very interesting effects :)

##Features

- [x] [46+ Parametric Curves, Decay, and Springs](/Documentation/parametric_easings.md) 
- [x] Blocks Syntax for Building Complex Animations
- [x] Chain Animations:
	* Synchronously 
	* Time Progress Relative
	* Value Progress Relative
- [x] Apply Unique Easing per Property Animation
- [x] Advanced Multi-Curve Group Synchronization
- [x] Define, Cache, and Reuse Animations

<br>

<p align=center>
<a href="http://www.youtube.com/watch?feature=player_embedded&v=8XyH5mpfoC8&vq=hd1080
" target="_blank"><img src="http://img.youtube.com/vi/8XyH5mpfoC8/0.jpg" 
alt="FlightAnimatore Demo" border="0" /></a>
</p>


##Installation

* **Requirements** : XCode 7.3+, iOS 8.0+, tvOS 9.0+
* [Installation Instructions](/Documentation/installation.md)
* [Release Notes](/Documentation/release_notes.md)

##Communication

- If you **found a bug**, or **have a feature request**, open an issue.
- If you **need help** or a **general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/flight-animator). (tag 'flight-animator')
- If you **want to contribute**, review the [Contribution Guidelines](/Documentation/CONTRIBUTING.md), and submit a pull request. 

##Basic Use 

There are a many ways to use FlightAnimator as it provides a very flexible syntax for defining animations ranging in completexy with ease. Whether performing an animation, chaining animations, or registering/caching an animation, the framework follows a common blocks based builder approach to define property animations within an animation group. Each property animation, is configured with final value, and easing curve, and optionally the primary flag to adjust synchronization of the animations within a group when applied to the layer.

Under the hood animations are built as CAAnimationGroup(s) with multiple custom CAKeyframeAnimation(s) defined uniquely per property. Once it's time to animate, FlightAnimator will dynamically synchronize the remaining progress for all the animations relative to the current presentationLayer's values, then continue to animate to it's final state.

Check out the [Framework Demo App](#demoApp) to experiment with all the different capabilities of FlightAnimator.

###Simple Animation

To perform a simple animation call the `animate(:)` method on the view to animate. Once the animator completes the creation process, the animation applies itself on it's own to the layer, and sets all the final layers values on the model layer.

```swift
view.animate { (animator) in
      animator.bounds(newBounds).duration(0.5).easing(.OutCubic)
      animator.position(newPositon).duration(0.5).easing(.InSine)
}
```

The closure returns an instance FlightAnimator used to build a complex animation to perform one property at a time. Technically the animator creates a CGAnimationGroup under the hood to add individual animations to. Once inside the closure, the first step is to creating individual property animation with a destination value, then configure the duration, and easing curve accordingly.

Methods on the FlightAnimator defined for every supported animatable property, but In the case there is a need to animate a custom defined NSManaged animatable property, i.e progress to draw a circle. Use the `value(value:forKeyPath:)` method on the animator to animate that property.

```swift
view.animate { (animator) in
    animator.value(value, forKeyPath : "progress").duration(0.5).easing(.OutCubic)    
}
```

Once you have created a property animation within the group, it recursively returns an instance of PropertyAnimationConfig, which allows for chaining the a duration, easing curve, or primary flag, documentated documented at a later point in the documentation. 

```swift
func duration(duration : CGFloat) -> PropertyAnimationConfig
func easing(easing : FAEasing) -> PropertyAnimationConfig
func primary(primary : Bool) -> PropertyAnimationConfig
```

###Animation Delegate Callbacks

If there is a need to implement the CAAnimationDelegate, you can directly apply the callbacks on the animator instance during creation.

```
view.animate { (animator) in
    animator.bounds(newBounds).duration(0.5).easing(.OutCubic)
    animator.position(newPositon).duration(0.5).easing(.InSine)
    
    animator.setDidStartCallback({ (anim) in
         // Animation Did Start
    })
    
    animator.setDidStopCallback({ (anim, complete) in
         // Animation Did Stop   
    })
}
```

##Chaining Animations

Chaining animations together in FlightAnimator is simple easy. You can nest animations using three different types triggers:

* Simultaneously
* Time Progress Based
* Value Progress Based
 
These can be applied to the view being animated, or any other view accessible in the view heirarchy.

####Trigger Simultaneously

To trigger an animation right as the parent animation begins, attach a trigger on a parent animator by calling `animator.triggerOnStart(...)`. The trigger will perform the animation enclosed accordingly right as the parent begins animating. 

```
// Parent Animation Group
view.animate { (animator) in
	animator.bounds(newBounds).duration(0.5).easing(.EaseOutCubic)
    animator.position(newPositon).duration(0.5).easing(.EaseOutCubic)
    
    // Child Animation Group, Triggered by Parent Group
    animatortriggerOnStart(onView: self.secondaryView, animator: { (animator) in
         animator.bounds(newSecondaryBounds).duration(0.5).easing(.OutCubic)
         animator.position(newSecondaryCenter).duration(0.5).easing(.OutCubic)
    })
}
```

####Trigger Relative to Time Progress

A time based trigger will apply the next animation based on the progressed time of the overall parent animation. The progress value is defined with a range from 0.0 - 1.0, if the over all time of an animation is 1.0 second, by setting the atProgress paramter to 0.5, will trigger the animation at the 0.5 seconds into the parent animation. 

Below is an examples that will trigger the second animation at the halfway point in time of the parent animation by calling `triggerAtTimeProgress(...)`

```swift
view.animate { (animator) in
	animator.bounds(newBounds).duration(0.5).easing(.OutCubic)
    animator.position(newPositon).duration(0.5).easing(.OutCubic)
    
    animator.triggerAtTimeProgress(atProgress: 0.5, onView: self.secondaryView, animator: { (animator) in
         animator.bounds(newSecondaryBounds).duration(0.5).easing(.OutCubic)
         animator.position(newSecondaryCenter).duration(0.5).easing(.OutCubic)
    })
}
```

####Trigger Relative to Value Progress

A value based progress trigger will apply the next animation based on the value progress of the overall parent animation. Below is an examples that will trigger the second animation at the halfway point of the value progress on the parent animation by calling `animator.triggerAtValueProgress(...)`

```swift
view.animate { (animator) in
	animator.bounds(newBounds).duration(0.5).easing(.EaseOutCubic)
    animator.position(newPositon).duration(0.5).easing(.EaseOutCubic)
    
    animator.triggerAtValueProgress(atProgress: 0.5, onView: self.secondaryView, animator: { (animator) in
         animator.bounds(newSecondaryBounds).duration(0.5).easing(.OutCubic)
         animator.position(newSecondaryCenter).duration(0.5).easing(.OutCubic)
    })
}
```

##Cache & Reuse Animations

FlighAnimator allows for registering animations (aka states) up front with a unique animation key. Once defined it can be manually triggered at any time in the application flow using the animation key used registration. 

When the animation is applied, if the view is in mid flight, it will synchronize itself with the current presentation layer values, and animate to its final destination. 

####Register/Cache Animation

To register an animation, call a globally defined method, and create an animations just as defined earlier examples within the maker block. The following example shows how to register, and cache an animation for a key on a specified view. 

```swift
struct AnimationKeys {
	static let CenterStateFrameAnimation  = "CenterStateFrameAnimation"
}
...

registerAnimation(onView : view, forKey : AnimationKeys.CenterStateFrameAnimation) { (animator) in
      animator.bounds(newBounds).duration(0.5).easing(.OutCubic)
      animator.position(newPositon).duration(0.5).easing(.OutCubic)
})
```

This animation is only cached, and is not performed until it is manually triggered.

####Apply Registered Animation


To trigger the animation call the following 

```
view.applyAnimation(forKey: AnimationKeys.CenterStateFrameAnimation)
```

To apply final values without animating the view, override the default animated flag to false, and it will apply all the final values to the model layer of the associated view.


```swift
view.applyAnimation(forKey: AnimationKeys.CenterStateFrameAnimation, animated : false)
```


##Advanced Use

###Timing Adjustments

Due to the dynamic nature of the framework, it may take a few tweaks to get the animation just right. 

FlightAnimator has a few options for finer control over timing synchronization:

* **Timing Priority** - Adjust how the time is select during synchronization of the overall animation
* **Primary Drivers** - Defines animations that affect timing during synchronization of the overall animation

####Timing Priority

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


####Primary Flag

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


###.SpringDecay w/ Initial Velocity

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

##Reference

[Supported Parametric Curves](/Documentation/parametric_easings.md)

[CALayer's Supported Animatable Property](/Documentation/supported_animatable_properties.md)

[Current Release Notes](/Documentation/release_notes.md)

[Contribution Guidelines](/Documentation/CONTRIBUTING.md)


###<a name="demoApp"></a>Framework Demo App

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
