//
//  FlightUITests.swift
//  FlightUITests
//
//  Created by Anton Doudarev on 4/25/18.
//  Copyright © 2018 Anton Doudarev. All rights reserved.
//

import XCTest

class FlightUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSingleView() {
        
        let app = XCUIApplication()
        app.buttons["Center Left"].tap()
        
        let bottomCenterButton = app.buttons["Bottom Center"]
        bottomCenterButton.tap()
        
        let centerCenterTransformButton = app.buttons["Center Center + Transform"]
        centerCenterTransformButton.tap()
        centerCenterTransformButton.tap()
        app.buttons["Top Right"].tap()
        app.buttons["Bottom Left"].tap()
        centerCenterTransformButton.tap()
        
        let topCenterButton = app.buttons["Top Center"]
        topCenterButton.tap()
        bottomCenterButton.tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .button).element(boundBy: 9).tap()
        app.buttons["   ▲      TOP AND EXPAND                  "].tap()
        app.buttons["   ▼      BOTTOM AND EXPAND          "].tap()
        bottomCenterButton.tap()
        centerCenterTransformButton.tap()
        topCenterButton.tap()
        app.buttons["Top Left + Alpha"].tap()
        app.buttons["Bottom Right"].tap()
        app.staticTexts["Panable Area\n\nTap here to pan view"].tap()
    }
    
    
    func testDoubleViewInstantProgress() {
        let app = XCUIApplication()
        app.buttons["SettingsButton"].tap()
        app.switches["EnableSecondarySwitch"].tap()
        app.buttons["▼"].tap()
        
        Thread.sleep(forTimeInterval: 1)
        
        app.buttons["Bottom Left"].tap()
        
        let centerCenterTransformButton = app.buttons["Center Center + Transform"]
        centerCenterTransformButton.tap()
        app.buttons["Bottom Right"].tap()
        app.buttons["Top Right"].tap()
        app.buttons["Top Center"].tap()
        app.buttons["Top Left + Alpha"].tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .button).element(boundBy: 9).tap()
        centerCenterTransformButton.tap()

     
        
    }
    
    func testDoubleViewTimeProgress() {

        let app = XCUIApplication()
        app.buttons["SettingsButton"].tap()
        app.switches["EnableSecondarySwitch"].tap()
        app.buttons["Time Progress"].tap()
        app.sliders["SecondaryProgressSlider"].adjust(toNormalizedSliderPosition: 0.5)
        app.buttons["▼"].tap()
        
        Thread.sleep(forTimeInterval: 1)
        
        app.buttons["Bottom Left"].tap()
        
        let centerCenterTransformButton = app.buttons["Center Center + Transform"]
        centerCenterTransformButton.tap()
        app.buttons["Bottom Right"].tap()
        app.buttons["Top Right"].tap()
        app.buttons["Top Center"].tap()
        app.buttons["Top Left + Alpha"].tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .button).element(boundBy: 9).tap()
        centerCenterTransformButton.tap()
    }
    
    func testDoubleViewValueProgress() {
        
        let app = XCUIApplication()
        app.buttons["SettingsButton"].tap()
        app.switches["EnableSecondarySwitch"].tap()
        app.buttons["Value Progress"].tap()
        app.sliders["SecondaryProgressSlider"].adjust(toNormalizedSliderPosition: 0.5)
        app.buttons["▼"].tap()
        
        Thread.sleep(forTimeInterval: 1)
        
        app.buttons["Bottom Left"].tap()
        
        let centerCenterTransformButton = app.buttons["Center Center + Transform"]
        centerCenterTransformButton.tap()
        app.buttons["Bottom Right"].tap()
        app.buttons["Top Right"].tap()
        app.buttons["Top Center"].tap()
        app.buttons["Top Left + Alpha"].tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .button).element(boundBy: 9).tap()
        centerCenterTransformButton.tap()
    }

    func testExample()
    {
        let app = XCUIApplication()
        app.buttons["SettingsButton"].tap()
        app.switches["EnableSecondarySwitch"].tap()
        
        let collectionviewCollectionView = app.collectionViews["CollectionView"]
        collectionviewCollectionView.cells["BoundsCell"].pickerWheels.element.adjust(toPickerWheelValue: "InSine")
        app.buttons["▼"].tap()
    }
    
}
