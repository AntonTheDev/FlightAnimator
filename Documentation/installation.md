#Installation

###Manual Install

1. Clone the both [CoreFlightAnimation](https://github.com/AntonTheDev/CoreFlightAnimation.git) and [FlightAnimator](https://github.com/AntonTheDev/FlightAnimator.git) repositories 
2. Add the contents of ***/FlightAnimator/Source*** and  ***/CoreFlightAnimation/Source*** directories


****
###CocoaPods

1. Edit the project's podfile, and save

	```
	Swift 3.0: 
    pod 'FlightAnimator', '~> 0.9.4-3.x'

	Swift 2.2 / Swift 2.3 : 
    pod 'FlightAnimator', '~> 0.9.4-2.x'
	```
2. Install FlightAnimator by running

    ```
    pod install
    ```
**** 
###Carthage

The installation instruction below for iOS and AppleTV

####Installation

1. Create/Update the Cartfile with with the following
	
	```
	Swift 3.0:
	
	#FlightAnimator
	git "https://github.com/AntonTheDev/FlightAnimator.git" >= 0.9.4-3.x

	Swift 2.2 / Swift 2.3:
	
	#FlightAnimator
	git "https://github.com/AntonTheDev/FlightAnimator.git" >= 0.9.4-2.x
	```
2. Run `carthage update`. This will fetch dependencies into a [Carthage/Checkouts][] folder, then build each one.
3. In the application targets’ “General” settings tab, in the “Embedded Binaries” section, drag and drop each framework for use from the Carthage/Build folder on disk.
4. Follow the installation instruction above. Once complete, perform the following steps
(If you have setup a carthage build task for iOS already skip to Step 6) 
5. Navigate to the targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script with the following content:

  	```
  	/usr/local/bin/carthage copy-frameworks
  	```
  	
6. Add the paths to the frameworks you want to use under “Input Files” within the carthage build phase as follows e.g.:

	```
	// iOS
	$(SRCROOT)/Carthage/Build/iOS/CoreFlightAnimation.framework
 	$(SRCROOT)/Carthage/Build/iOS/FlightAnimator.framework
  	
  	or
  	
  	// tvOS
  	$(SRCROOT)/Carthage/Build/tvOS/CoreFlightAnimation.framework
  	$(SRCROOT)/Carthage/Build/tvOS/FlightAnimator.framework
  	```