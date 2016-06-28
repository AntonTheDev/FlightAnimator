#FlightAnimator

[![Cocoapods Compatible](https://img.shields.io/badge/pod-v0.2.0-blue.svg)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)]()
[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)]()
[![License](https://img.shields.io/badge/license-MIT-343434.svg)](/LICENSE.md)

![alt tag](/Documentation/FlightBanner.jpg?raw=true)

##Introduction

FlightAnimator is a natural animation engine built on top of CoreAnimation. Implemented with a blocks based approach it is very easy to create, configure, cache, and reuse animations dynamically based on the current state. 

FlightAnimator uses CAKeyframeAnimation(s) and CoreAnimationGroup(s) under the hood. All animations that are registered with the view, are technically a custom CAAnimationGroup, that once applied, the group dynamically synchronizes the remaining progress based on the current presentationLayer's values, performs interpolation to the final values accordingly, and applies itself to the view, and updates all the model layer values.

<br>

##Features

* Support for 31+ parametric curves
* Custom springs and decay animations
* Blocks based animation builder
* Muti-Curve group synchronisation
* Progress based animation sequencing
* Support for triggering cached animations
* Easing curve synchronization

##Installation

* [Installation Documentation](/Documentation/installation.md)

##Basic Use 

The core of concept for the framework is to register an animation for a unique key, and triggered the animation using the unique key.

###Simple Animation

#####Register Animation

The following example shows how to register, and cache an animation to a specified view. This animation is only cached, and is not performed until it is manually triggered at a later point.

```
struct AnimationKeys {
	static let CenterStateFrameAnimation  = "CenterStateFrameAnimation"
}

...

registerAnimation(onView : view, forKey : AnimationKeys.CenterStateFrameAnimation) { (animator) in
      animator.bounds(newBounds).duration(0.5).easing(.EaseOutCubic)
      animator.position(newPositon).duration(0.5).easing(.EaseOutCubic)
})

```

As simple as that the animator instance creates the animation, and applies a different curve for each property. Once the animation is triggered off using the key, it will build the animation group and synchronize it accordingly.

If you want to animate a custom property you can use. 

```
public func value<T : FAAnimatable>(value : T, forKeyPath key : String)
```

#####Trigger Animation

To trigger the animation all you have to do is call the following 

```
view.applyAnimation(forKey: AnimationKeys.CenterStateFrameAnimation)
```

In the case there is a need to apply the final values without animation, you can override the default animated flag to false, and it will apply all the final values to the view in question

```
view.applyAnimation(forKey: AnimationKeys.CenterStateFrameAnimation, animated : false)
```

###Animation Sequence

Often time we need to observe the current progress of a specific animation, and trigger another animation to start when either, the time progress, or the value progress of the animation reaches a certain point.

The ``FlightAnimator`` provides the ability to attach a trigger to a parent animation based on the specified progress, which will then trigger the animation accordingly while in mid flight.

There are two types of triggers, one is time based, and one is value based trigger independent of the time itself.

Let's look at how we can nest the two types of animations.

####Time Progress Based Animation Sequence

A time based trigger will start the next animation, based on the the progressed time of the overall parent animation. Below is an examples that will trigger the second animation at the halfway point in time of the parent animation by calling `triggerAtTimeProgress(...)`

```
struct AnimationKeys {
	static let TimeNestedAnimationKey  = "TimeNestedAnimationKey"
}

...

registerAnimation(onView : view, forKey : AnimationKeys.TimeNestedAnimationKey) { (animator) in
      animator.bounds(newBounds).duration(0.5).easing(.EaseOutCubic)
      animator.position(newPositon).duration(0.5).easing(.EaseOutCubic)
      
   	  animator.triggerAtTimeProgress(atProgress: 0.5, onView: self.secondaryView, maker: { (animator) in
                animator.bounds(newSecondaryBounds).duration(0.5).easing(.EaseOutCubic)
                animator.position(newSecondaryCenter).duration(0.5).easing(.EaseOutCubic))
            })
})
```

####Value Progress Based Animation Sequence

A progressed based trigger will start the next animation, based on the the value progress of the overall parent animation. Below is an examples that will trigger the second animation at the halfway point of the value progress on the parent animation by calling `animator.triggerAtValueProgress(...)`

```
struct AnimationKeys {
	static let NestedValueProgressAnimationKey  = "NestedValueProgressAnimationKey"
}

...

registerAnimation(onView : view, forKey : AnimationKeys.NestedValueProgressAnimationKey) { (animator) in
      animator.bounds(newBounds).duration(0.5).easing(.EaseOutCubic)
      animator.position(newPositon).duration(0.5).easing(.EaseOutCubic)
      
   	  animator.triggerAtValueProgress(atProgress: 0.5, onView: self.secondaryView, maker: { (animator) in
                animator.bounds(newSecondaryBounds).duration(0.5).easing(.EaseOutCubic)
                animator.position(newSecondaryCenter).duration(0.5).easing(.EaseOutCubic))
            })
})
```

##Future Enhancements

To Be Continued

##Appendix

###Supported Parametric Curves

<table>
  <tbody>
    <tr>
      <td>Linear <br>LinearSmooth<br>LinearSmoother</td>
      <td>EaseInSine <br>EaseOutSine<br>EaseInOutSine</td>
      <td>EaseInQuadratic <br>EaseOutQuadratic<br>EaseInOutQuadratic</td>
    
    </tr>
    <tr>
      <td>EaseInCubic <br>EaseOutCubic<br>EaseInOutCubic</td>
      <td>EaseInQuartic <br>EaseOutQuartic<br>EaseInOutQuartic</td>
      <td>EaseInQuintic <br>EaseOutQuintic<br>EaseInOutQuintic</td>
    </tr>
        <tr>
      <td>EaseInExponential <br>EaseOutExponential<br>EaseInOutExponential </td>
      <td>EaseInCircular <br>EaseOutCircular<br>EaseInOutCircular</td>
      <td>EaseInBack <br>EaseOutBack<br>EaseInOutBack</td>
    </tr>
    <tr>
      <td>EaseInElastic <br>EaseOutElastic<br>EaseInOutElastic </td>
      <td>EaseInBounce <br>EaseOutBounce<br>EaseInOutBounce</td>
      <td></td>
    </tr> 
  </tbody>
</table>

*  SpringDecay(velocity)
*  SpringCustom(velocity, frequency, damping)

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
* CGRect
* CATransform3D

## License

FlightAnimator is released under the MIT license. See [License](/LICENSE.md) for details.