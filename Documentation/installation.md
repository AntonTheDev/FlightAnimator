# Installation

### Manual Install

1. Clone [FlightAnimator](https://github.com/AntonTheDev/FlightAnimator.git) repositories
2. Add the contents of ***/FlightAnimator/Source***


****
### CocoaPods

1. Edit the project's podfile, and save

```
pod 'FlightAnimator', :git => 'https://github.com/AntonTheDev/FlightAnimator.git', :tag => '0.9.9'
```
2. Install FlightAnimator by running

```
pod install
```
****
### Carthage

The installation instruction below for iOS and AppleTV

#### Installation

1. Create/Update the Cartfile with with the following

```
Swift 3.1:

#FlightAnimator
git "https://github.com/AntonTheDev/FlightAnimator.git" >= 0.9.9
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
$(SRCROOT)/Carthage/Build/iOS/FlightAnimator.framework

 or

// tvOS
$(SRCROOT)/Carthage/Build/tvOS/FlightAnimator.framework
```
