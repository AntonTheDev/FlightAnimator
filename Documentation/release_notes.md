#Release Notes

####Version 0.7.0

* Refactored the Interpolator
* Refactored / Fixed Sequencing Logic
	* Multiple Sequences for the same progress trigger value should fire correctly
	* Value Based triggers now work with springs
* Added 3 more timing curves:
	* InAtan
	* OutAtan
	* InOutAtan
* Updated the app demo
	* Added option to enable and disable a secondary view
	* Added ability to test out time based / value based triggers with secondary view
	* Moved the picker into individual cells for each property 	
	
####Version 0.6.1

* Refactored some of the code:
	* Created an FAInterpolator for all the interpolation logic
* Accidentally removed OutIn easings in version 0.6.0, fixed 


####Version 0.6.0

* Refactored some of the code:
	* Separate file for FAEasing and FASpring
	* Simplified the synchronization logic inside of FAAnimation
	* Removed some of the loose extensions
* You can also set the timing priority on ``triggerAtTimeProgress()`` or ``triggerAtValueProgress()``. 


####Version 0.5.0

* Updated the naming convention of the easing curves by removing the 'Ease' prefix on the enumerator to make swift-like syntax, now you can easily access animations without being presented too many types.
	* i.e .EaseInSine -> .InSine , 
	* i.e .EaseInOutSine -> .InOutSine
* Added the ability to set the timing priority on the ``registerAimation()`` and ``animate()`` method 
	* The default is **.MaxTime**
* Refactored some code and ensured that it is in the right places
* Separated the readme into multiple pages, with a reference for easing curves, supported animatable properties, and alas these release notes


####Version 0.4.0

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

####Version 0.3.0

* Added animate() as part of a UIView extension
	* This triggers an animation without caching it.
	* Prior you had to cache an animation, then trigger it
* Fixed the progress trigger logic
	* Bug was introduced during work on the blocks based animations

####Version 0.2.0

* Initial Public Release
* Introduced blocks based animation builder
