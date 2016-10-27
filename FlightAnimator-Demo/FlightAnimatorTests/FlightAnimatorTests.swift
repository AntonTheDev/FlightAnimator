//
//  FlightAnimatorTests.swift
//  FlightAnimatorTests
//
//  Created by Anton Doudarev on 7/8/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import XCTest

class FlightAnimatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFAVectorComponents() {
        
        XCTAssertEqual(FAVector(value: CGSize(width: 10,height: 10)).components.count, 2, "CGSize Vector has incorrectnumber of components")
        XCTAssertEqual(FAVector(value: CGPoint(x: 10,y: 10)).components.count, 2, "CGPoint Vector  has incorrectnumber of components")
        XCTAssertEqual(FAVector(value: CGRect(x: 0,y: 0, width: 10, height: 10)).components.count, 4, "CGRect Vector has incorrectnumber of components")
        XCTAssertEqual(FAVector(value: CGFloat(1.0)).components.count, 1, "CGFloat Vector has incorrectnumber of components")
        XCTAssertEqual(FAVector(value: CATransform3DIdentity).components.count, 16, "CATransform3D Vector has incorrectnumber of components")
        
        let RGBColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.2).cgColor
        let HSBColor = UIColor(hue: 0.2, saturation: 0.2, brightness: 0.2, alpha: 0.2).cgColor
        let MonochromaticColor = UIColor(white: 0.2, alpha: 0.2).cgColor
        
        XCTAssertEqual(FAVector(value: RGBColor).components.count, 4, "RGBColor Vector has incorrectnumber of components")
        XCTAssertEqual(FAVector(value: HSBColor).components.count, 4, "HSBColor Vector has incorrectnumber of components")
        XCTAssertEqual(FAVector(value: MonochromaticColor).components.count, 2, "MonochromaticColor Vector has incorrectnumber of components")
   }
    
    func testSizeVectorDifference() {
        
        let sizeVectorOne = FAVector(value: CGSize(width: 10,height: 8))
        let sizeVectorTwo = FAVector(value: CGSize(width: 4,height: 5))
        
        let sizeVectorDifference = sizeVectorOne - sizeVectorTwo
        
        XCTAssertEqual(sizeVectorOne.components[0], 10, "SizeVectorOne Mutated")
        XCTAssertEqual(sizeVectorOne.components[1], 8, "SizeVectorOne Mutated")
        XCTAssertEqual(sizeVectorTwo.components[0], 4, "sizeVectorTwo Mutated")
        XCTAssertEqual(sizeVectorTwo.components[1], 5, "sizeVectorTwo Mutated")
        
        XCTAssertEqual(sizeVectorDifference.components[0], 6, "sizeVectorDifference Not Calculated Correctly Mutated")
        XCTAssertEqual(sizeVectorDifference.components[1], 3, "sizeVectorDifference Not Calculated Correctly Mutated")
    }
    
    func testPointVectorDifference() {
        let pointVectorOne = FAVector(value: CGPoint(x: 10,y: 8))
        let pointVectorTwo = FAVector(value: CGPoint(x: 4,y: 5))
        
        let pointVectorDifference = pointVectorOne - pointVectorTwo
        
        XCTAssertEqual(pointVectorOne.components[0], 10, "pointVectorOne Mutated")
        XCTAssertEqual(pointVectorOne.components[1], 8, "pointVectorOne Mutated")
        XCTAssertEqual(pointVectorTwo.components[0], 4, "pointVectorTwo Mutated")
        XCTAssertEqual(pointVectorTwo.components[1], 5, "pointVectorTwo Mutated")
        
        XCTAssertEqual(pointVectorDifference.components[0], 6, "pointVectorDifference Not Calculated Correctly Mutated")
        XCTAssertEqual(pointVectorDifference.components[1], 3, "pointVectorDifference Not Calculated Correctly Mutated")
    }
    
    func testFloatVectorDifference() {
        let floatVectorOne = FAVector(value: CGFloat(10))
        let floatVectorTwo = FAVector(value: CGFloat(4))
        
        let floatVectorDifference = floatVectorOne - floatVectorTwo
        
        XCTAssertEqual(floatVectorOne.components[0], 10, "floatVectorOne Mutated")
        XCTAssertEqual(floatVectorTwo.components[0], 4,  "floatVectorTwo Mutated")
        
        XCTAssertEqual(floatVectorDifference.components[0], 6, "floatVectorDifference Not Calculated Correctly Mutated")
    }
    
    func testRectVectorDifference() {
        let rectVectorOne = FAVector(value: CGRect(x: 8, y: 6, width: 10, height: 8))
        let rectVectorTwo = FAVector(value: CGRect(x: 2, y: 3, width: 4, height: 5))
        
        let rectVectorDifference = rectVectorOne - rectVectorTwo
        
        XCTAssertEqual(rectVectorOne.components[0], 8, "rectVectorOne Mutated")
        XCTAssertEqual(rectVectorOne.components[1], 6, "rectVectorOne Mutated")
        XCTAssertEqual(rectVectorOne.components[2], 10, "rectVectorOne Mutated")
        XCTAssertEqual(rectVectorOne.components[3], 8, "rectVectorOne Mutated")
        
        XCTAssertEqual(rectVectorTwo.components[0], 2, "rectVectorTwo Mutated")
        XCTAssertEqual(rectVectorTwo.components[1], 3, "rectVectorTwo Mutated")
        XCTAssertEqual(rectVectorTwo.components[2], 4, "rectVectorTwo Mutated")
        XCTAssertEqual(rectVectorTwo.components[3], 5, "rectVectorTwo Mutated")
        
        XCTAssertEqual(rectVectorDifference.components[0], 6, "rectVectorDifference Not Calculated Correctly Mutated")
        XCTAssertEqual(rectVectorDifference.components[1], 3, "rectVectorDifference Not Calculated Correctly Mutated")
        XCTAssertEqual(rectVectorDifference.components[2], 6, "rectVectorDifference Not Calculated Correctly Mutated")
        XCTAssertEqual(rectVectorDifference.components[3], 3, "rectVectorDifference Not Calculated Correctly Mutated")
    }
    
    func testCATrasform3DVectorDifference() {
        // Fill This In
    }
    
    func testCGColorVectorDifference() {
        // Fill This In
    }
}
