# Release Notes

#### Version 0.9.8
* Added support for monochromatic color
* Added Travis CI Configuration

#### Version 0.9.7
* Fixed an issue that was incorrectly applying the from value.
	- The framework assumed that the view's layer properties relative to the presentation layer.
* Updated the maker block to nonescaping as it should have been

#### Version 0.9.6
* Updated caching API as follows & fixed documentation accordingly
	```
	// Deleted
	func cacheAnimation(animation: Any,
                            forKey key: String,
                            timingPriority : FAPrimaryTimingPriority = .maxTime)

 	// Added
	func registerAnimation(animation: Any,
                               forKey key: String,
                               timingPriority : FAPrimaryTimingPriority = .maxTime)
	```



#### Version 0.9.5
* Swift 3.0 / 3.1 Support
* Removed support for Swift 2.2 / 2.3
* Few minor bug fixes

#### Version 0.9.4-3.x  / 0.9.4-2.x

* Swift 3.0 / 2.2 / 2.3 Update :
	- 0.9.4-3.x (Swift 3.0)
	- 0.9.4-2.x (Swift 2.2 / Swift 2.3)

* Cleanup on Swift 3.0 branch


#### Version 0.9.3

* Stability Updates / Performance Improvements
* Bug Fixes for the .Average / .Median priority calculations

#### Version 0.9.2

* For consistency APIs have been updated,
	- Renamed FAAnimation -> FABasicAnimation
	- API Changed :

	<br>

	```
	FlightAnimator.Swift

	// Deleted
	public func triggerOnStart(timingPriority:, onView :, animator:)
	public func triggerAtTimeProgress(timingPriority :, atProgress :, onView :, animator:)                                                
	public func triggerAtValueProgress(timingPriority:, atProgress:, onView:, animator:)                         

	// Added
	public func triggerOnStart(onView:, timingPriority: ,animator:)
	public func triggerOnProgress(progress:, onView :, timingPriority :, animator:)
	public func triggerOnValueProgress(progress:, onView:, timingPriority:, animator:)

    // New
	public func triggerOnCompletion(onView:, timingPriority:, animator:)  


	UIView+FAAnimation

	// Added
	func cacheAnimation(forKey: String, timingPriority:, animator:)
	func cacheAnimation(animation: , forKey:, timingPriority :)   

    func applyAnimation(forKey key: String, animated : Bool = true)

	Global Definitions

	// Removed
	registerAnimation(onView : UIView, forKey: String, timingPriority :, animator :)

	```

* Bug fixes:
 	- Sequencing Animations:  You can not trigger an animation by an animation on the triggering view



#### Version 0.9.1
* No API differences
* Fixed Decay Configuration

#### Version 0.9.0
* No API differences
* Refactored Interpolation logic, simplified the structure to using vectors
* Fix bug, where prior triggers were not getting cancelled
* Fixed Issue animating between color spaces with different numbers of components

#### Version 0.8.1
* Fixed Bug Issue #13 reported by @springlo, M33 Property sprign pointing to M34

#### Version 0.8.0
* Added tvOS Support for both Carthage and Cocoapods
* Added the ability to listen to CAAnimationDelegate by setting a closure on the animator instance within the build closure
* Added the ability to interpolate CGColor, RGBA, HSBA, and Monochromatic
* Added property accessors for backgroundColor, borderColor, shadowColor
* Fix for synchronizing, it was running the sychronization logic twice, 30%+ performance improvement

#### Version 0.7.3
* Removed unnecessary Type Conversion between Doubles and CGFloats
* Refactored the value / time based progress logic

#### Version 0.7.2
* Added Build support for iOS 8.0+ (prior was only built via Carthage / Cocoapods for ios 9.3)

#### Version 0.7.1

* Added missing file references for the Carthage Framework Project
* Update parts of the README
* Added Contibution documentation
* Added Code of Conduct

#### Version 0.7.0

* Refactored the Interpolator
* Refactored / Fixed Sequencing Logic
	* Multiple Sequences for the same progress trigger value should fire correctly
	* Value Based triggers now work with springs
* Renamed Linear timing curves:
	* LinearSmooth -> SmoothStep
	* LinearSmoother -> SmootherStep
* Added 3 more timing curves:
	* InAtan
	* OutAtan
	* InOutAtan
* Updated the app demo
	* Added option to enable and disable a secondary view
	* Added ability to test out time based / value based triggers with secondary view
	* Moved the picker into individual cells for each property 	

#### Version 0.6.1

* Refactored some of the code:
	* Created an FAInterpolator for all the interpolation logic
* Accidentally removed OutIn easings in version 0.6.0, fixed


#### Version 0.6.0

* Refactored some of the code:
	* Separate file for FAEasing and FASpring
	* Simplified the synchronization logic inside of FAAnimation
	* Removed some of the loose extensions
* You can also set the timing priority on ``triggerAtTimeProgress()`` or ``triggerAtValueProgress()``.


#### Version 0.5.0

* Updated the naming convention of the easing curves by removing the 'Ease' prefix on the enumerator to make swift-like syntax, now you can easily access animations without being presented too many types.
	* i.e .EaseInSine -> .InSine ,
	* i.e .EaseInOutSine -> .InOutSine
* Added the ability to set the timing priority on the ``registerAimation()`` and ``animate()`` method
	* The default is **.MaxTime**
* Refactored some code and ensured that it is in the right places
* Separated the readme into multiple pages, with a reference for easing curves, supported animatable properties, and alas these release notes


#### Version 0.4.0

* Added the following parametric curves
	* EaseOutInSine
	* EaseOutInQuadratic
	* EaseOutCubic
	* EaseOutInCubic
	* EaseOutInQuartic
	* EaseOutInQuintic
	* EaseOutInExponential
	* EaseOutInCircular
	* EaseOutInBack
	* EaseOutInElastic
	* EaseOutInBounce

#### Version 0.3.0

* Added animate() as part of a UIView extension
	* This triggers an animation without caching it.
	* Prior you had to cache an animation, then trigger it
* Fixed the progress trigger logic
	* Bug was introduced during work on the blocks based animations

#### Version 0.2.0

* Initial Public Release
* Introduced blocks based animation builder
