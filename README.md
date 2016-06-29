#FlightAnimator

[![Cocoapods Compatible](https://img.shields.io/badge/pod-v0.4.0-blue.svg)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)]()
[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)]()
[![License](https://img.shields.io/badge/license-MIT-343434.svg)](/LICENSE.md)

![alt tag](/Documentation/FlightBanner.jpg?raw=true)

##Introduction

FlightAnimator is a natural animation engine built on top of CoreAnimation. Implemented with a blocks based approach it is very easy to create, configure, cache, and reuse animations dynamically based on the current state. 

FlightAnimator uses CAKeyframeAnimation(s) and CoreAnimationGroup(s) under the hood. You can apply animations on a view directly, or cache animations to define states to apply at a later time. The animations are technically a custom CAAnimationGroup, once applied to the layer, will dynamically synchronize the remaining progress based on the current presentationLayer's values.

<br>

##Features

* Support for 43+ parametric curves
* Custom springs and decay animations
* Blocks based animation builder
* Muti-Curve group synchronisation
* Progress based animation sequencing
* Support for triggering cached animations
* Easing curve synchronization

##Installation

* [Installation Documentation](/Documentation/installation.md)

##Basic Use 

There are two ways you can use this framework, you can perform an animation on a specific view, or register an animation on a view to perform later. 

When creating or registering an animation, the frame work uses a blocks cased approach to build the animation. You can apply a value, a timing, and set the primary flag, which will be discussed at a later point in the documentation.

###Simple Animation

To perform a simple animation  call the `animate(:)` method on the view you want to animate. Let's look at a simple example below.

```
view.animate { (animator) in
      animator.bounds(newBounds).duration(0.5).easing(.EaseOutCubic)
      animator.position(newPositon).duration(0.5).easing(.EaseInSine)
}
```
The closure returns an instance of an FAAnimationMaker, which can be used to build a complex animation to perform, one property at a time. You can apply different durations, and easing curves for each individual property in the animation. And that's it, the animation kicks itself off, applies the final animation to the layer, and sets all the final layers values on the model layer.

In the case you have defined a custom NSManaged animatable property, i.e progress to draw a circle. You can use the `value(value:forKeyPath:)` method on the animator to animate that property.

```
view.animate { (animator) in
      animator.value(value, forKeyPath : "progress").duration(0.5).easing(.EaseOutCubic)
}
```

##Sequence

Chaining animations together in flight animator is very easy, and allows you to trigger another animation based on the time progress, or the value progress of an animation.

You can nest a trigger on a parent animation at a specified progress, and trigger which will trigger accordingly, and can be applied to the view being animated, or any other view define.

Let's look at how we can nest some animations using time and value based progress triggers.

####Time Progress Trigger

A time based trigger will apply the next animation based on the the progressed time of the overall parent animation. Below is an examples that will trigger the second animation at the halfway point in time of the parent animation by calling `triggerAtTimeProgress(...)`

```
view.animate { (animator) in
	animator.bounds(newBounds).duration(0.5).easing(.EaseOutCubic)
    animator.position(newPositon).duration(0.5).easing(.EaseOutCubic)
    
    animator.triggerAtTimeProgress(atProgress: 0.5, onView: self.secondaryView, animator: { (animator) in
         animator.bounds(newSecondaryBounds).duration(0.5).easing(.EaseOutCubic)
         animator.position(newSecondaryCenter).duration(0.5).easing(.EaseOutCubic)
    })
}
```

####Value Progress Trigger

A value based progress trigger will apply the next animation based on the the value progress of the overall parent animation. Below is an examples that will trigger the second animation at the halfway point of the value progress on the parent animation by calling `animator.triggerAtValueProgress(...)`

```
view.animate { (animator) in
	animator.bounds(newBounds).duration(0.5).easing(.EaseOutCubic)
    animator.position(newPositon).duration(0.5).easing(.EaseOutCubic)
    
    animator.triggerAtValueProgress(atProgress: 0.5, onView: self.secondaryView, animator: { (animator) in
         animator.bounds(newSecondaryBounds).duration(0.5).easing(.EaseOutCubic)
         animator.position(newSecondaryCenter).duration(0.5).easing(.EaseOutCubic)
    })
}
```
##Cache and Reuse Animations

You can define animation states up fron using keys, and triggers then at any other time in your application flow. When the animation is applied, if the view is in mid flight, it will synchronize itself accordingly, and animate to it's final destination. To register an animation, you can call a glabally defined method, and just as you did earlier define the property animations within the maker block.

####Register Animation

The following example shows how to register, and cache it for a key on a specified view view. This animation is only cached, and is not performed until it is manually triggered at a later point.

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

####Trigger Keyed Animation


To trigger the animation all you have to do is call the following 

```
view.applyAnimation(forKey: AnimationKeys.CenterStateFrameAnimation)
```

In the case there is a need to apply the final values without actually animating the view, you can override the default animated flag to false, and it will apply all the final values to the model layer of the associated view.

```
view.applyAnimation(forKey: AnimationKeys.CenterStateFrameAnimation, animated : false)
```


##Future Enhancements

To Be Continued

##Appendix

####Supported Parametric Curves

A good reference for the supported easings can be found [here](http://easings.net/)

<table>
  <tbody>
    <tr>
      <td>EaseInSine <br>EaseOutSine<br>EaseInOutSine<br>EaseOutInSine</td>
      <td>EaseInQuadratic<br>EaseOutQuadratic<br>EaseInOutQuadratic<br>EaseOutInQuadratic</td>
   <td>EaseInCubic <br>EaseOutCubic<br>EaseInOutCubic<br>EaseOutInCubic</td>
       
    </tr>
    <tr>    
      <td>EaseInQuartic <br>EaseOutQuartic<br>EaseInOutQuartic<br>EaseOutInQuartic</td>
      <td>EaseInQuintic <br>EaseOutQuintic<br>EaseInOutQuintic<br>EaseOutInQuintic</td>
     <td>EaseInExponential <br>EaseOutExponential<br>EaseInOutExponential<br>EaseOutInExponential </td>
    </tr>
        <tr>
     
      <td>EaseInCircular <br>EaseOutCircular<br>EaseInOutCircular<br>EaseOutInCircular</td>
      <td>EaseInBack <br>EaseOutBack<br>EaseInOutBack<br>EaseOutInBack</td>
    <td>EaseInElastic <br>EaseOutElastic<br>EaseInOutElastic<br>EaseOutInElastic </td>
      
      </tr>
    <tr>
      <td>EaseInBounce <br>EaseOutBounce<br>EaseInOutBounce<br>EaseOutInBounce</td>
      <td>Linear <br>LinearSmooth<br>LinearSmoother</td>
      <td></td>
    </tr> 
  </tbody>
</table>

*  SpringDecay(velocity)
*  SpringCustom(velocity, frequency, damping)

####Supported Animatable Properties

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