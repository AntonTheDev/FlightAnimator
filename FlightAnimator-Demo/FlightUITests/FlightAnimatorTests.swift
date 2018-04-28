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
        
        XCTAssertEqual(CGSize(width: 10,height: 10).vector.count, 2, "CGSize Vector has incorrectnumber of vector")
        XCTAssertEqual(CGPoint(x: 10,y: 10).vector.count, 2, "CGPoint Vector  has incorrectnumber of vector")
        XCTAssertEqual(CGRect(x: 0,y: 0, width: 10, height: 10).vector.count, 4, "CGRect Vector has incorrectnumber of vector")
        XCTAssertEqual(CGFloat(1.0).vector.count, 1, "CGFloat Vector has incorrectnumber of vector")
        XCTAssertEqual(CATransform3DIdentity.vector.count, 16, "CATransform3D Vector has incorrectnumber of vector")
        
        let RGBColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.2).cgColor
        let HSBColor = UIColor(hue: 0.2, saturation: 0.2, brightness: 0.2, alpha: 0.2).cgColor
        let MonochromaticColor = UIColor(white: 0.2, alpha: 0.2).cgColor
        
        XCTAssertEqual(RGBColor.vector.count, 4, "RGBColor Vector has incorrectnumber of vector")
        XCTAssertEqual(HSBColor.vector.count, 4, "HSBColor Vector has incorrectnumber of vector")
        XCTAssertEqual(MonochromaticColor.vector.count, 4, "MonochromaticColor Vector has incorrectnumber of vector")
   }
    
    func testSizeVectorDifference() {
        
        let sizeVectorOne = CGSize(width: 10,height: 8)
        let sizeVectorTwo = CGSize(width: 4,height: 5)
        
        let sizeVectorDifference = sizeVectorOne - sizeVectorTwo
        
        XCTAssertEqual(sizeVectorOne.vector[0], 10, "SizeVectorOne Mutated")
        XCTAssertEqual(sizeVectorOne.vector[1], 8, "SizeVectorOne Mutated")
        XCTAssertEqual(sizeVectorTwo.vector[0], 4, "sizeVectorTwo Mutated")
        XCTAssertEqual(sizeVectorTwo.vector[1], 5, "sizeVectorTwo Mutated")
        
        XCTAssertEqual(sizeVectorDifference.vector[0], 6, "sizeVectorDifference Not Calculated Correctly Mutated")
        XCTAssertEqual(sizeVectorDifference.vector[1], 3, "sizeVectorDifference Not Calculated Correctly Mutated")
    }
    
    func testPointVectorDifference() {
        let pointVectorOne = CGPoint(x: 10,y: 8)
        let pointVectorTwo = CGPoint(x: 4,y: 5)
        
        let pointVectorDifference = pointVectorOne - pointVectorTwo
        
        XCTAssertEqual(pointVectorOne.vector[0], 10, "pointVectorOne Mutated")
        XCTAssertEqual(pointVectorOne.vector[1], 8, "pointVectorOne Mutated")
        XCTAssertEqual(pointVectorTwo.vector[0], 4, "pointVectorTwo Mutated")
        XCTAssertEqual(pointVectorTwo.vector[1], 5, "pointVectorTwo Mutated")
        
        XCTAssertEqual(pointVectorDifference.vector[0], 6, "pointVectorDifference Not Calculated Correctly Mutated")
        XCTAssertEqual(pointVectorDifference.vector[1], 3, "pointVectorDifference Not Calculated Correctly Mutated")
    }
    
    func testFloatVectorDifference() {
        let floatVectorOne = CGFloat(10)
        let floatVectorTwo = CGFloat(4)
        
        let floatVectorDifference = floatVectorOne - floatVectorTwo
        
        XCTAssertEqual(floatVectorOne.vector[0], 10, "floatVectorOne Mutated")
        XCTAssertEqual(floatVectorTwo.vector[0], 4,  "floatVectorTwo Mutated")
        
        XCTAssertEqual(floatVectorDifference.vector[0], 6, "floatVectorDifference Not Calculated Correctly Mutated")
    }
    
    func testRectVectorDifference() {
        let rectVectorOne = CGRect(x: 8, y: 6, width: 10, height: 8)
        let rectVectorTwo = CGRect(x: 2, y: 3, width: 4, height: 5)
        
        let rectVectorDifference = rectVectorOne - rectVectorTwo
        
        XCTAssertEqual(rectVectorOne.vector[0], 8, "rectVectorOne Mutated")
        XCTAssertEqual(rectVectorOne.vector[1], 6, "rectVectorOne Mutated")
        XCTAssertEqual(rectVectorOne.vector[2], 10, "rectVectorOne Mutated")
        XCTAssertEqual(rectVectorOne.vector[3], 8, "rectVectorOne Mutated")
        
        XCTAssertEqual(rectVectorTwo.vector[0], 2, "rectVectorTwo Mutated")
        XCTAssertEqual(rectVectorTwo.vector[1], 3, "rectVectorTwo Mutated")
        XCTAssertEqual(rectVectorTwo.vector[2], 4, "rectVectorTwo Mutated")
        XCTAssertEqual(rectVectorTwo.vector[3], 5, "rectVectorTwo Mutated")
        
        XCTAssertEqual(rectVectorDifference.vector[0], 6, "rectVectorDifference Not Calculated Correctly Mutated")
        XCTAssertEqual(rectVectorDifference.vector[1], 3, "rectVectorDifference Not Calculated Correctly Mutated")
        XCTAssertEqual(rectVectorDifference.vector[2], 6, "rectVectorDifference Not Calculated Correctly Mutated")
        XCTAssertEqual(rectVectorDifference.vector[3], 3, "rectVectorDifference Not Calculated Correctly Mutated")
    }
    
    func testCATrasform3DVectorDifference() {
        // Fill This In
    }
    
    func testCGColorVectorDifference() {
        // Fill This In
    }
    
    func testReverseEasing()
    {
        XCTAssert(FAEasing.linear.reverseEasing() == .linear, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.smoothStep.reverseEasing() == .smoothStep, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.smootherStep.reverseEasing() == .smootherStep, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inAtan.reverseEasing() == .outAtan, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outAtan.reverseEasing() == .inAtan, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inOutAtan.reverseEasing() == .inOutAtan, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inSine.reverseEasing() == .outSine, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outSine.reverseEasing() == .inSine, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inOutSine.reverseEasing() == .outInSine, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outInSine.reverseEasing() == .inOutSine, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inQuadratic.reverseEasing() == .outQuadratic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outQuadratic.reverseEasing() == .inQuadratic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inOutQuadratic.reverseEasing() == .outInQuadratic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outInQuadratic.reverseEasing() == .inOutQuadratic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inCubic.reverseEasing() == .outCubic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outCubic.reverseEasing() == .inCubic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inOutCubic.reverseEasing() == .outInCubic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outInCubic.reverseEasing() == .inOutCubic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inQuartic.reverseEasing() == .outQuartic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outQuartic.reverseEasing() == .inQuartic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inOutQuartic.reverseEasing() == .outInQuartic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outInQuartic.reverseEasing() == .inOutQuartic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inQuintic.reverseEasing() == .outQuintic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outQuintic.reverseEasing() == .inQuintic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inOutQuintic.reverseEasing() == .outInQuintic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outInQuintic.reverseEasing() == .inOutQuintic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inExponential.reverseEasing() == .outExponential, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outExponential.reverseEasing() == .inExponential, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outInExponential.reverseEasing() == .inOutExponential, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inOutExponential.reverseEasing() == .outInExponential, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inCircular.reverseEasing() == .outCircular, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outCircular.reverseEasing() == .inCircular, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outInCircular.reverseEasing() == .inOutCircular, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inOutCircular.reverseEasing() == .outInCircular, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inBack.reverseEasing() == .outBack, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outBack.reverseEasing() == .inBack, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inOutBack.reverseEasing() == .outInBack, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outInBack.reverseEasing() == .inOutBack, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inElastic.reverseEasing() == .outElastic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outElastic.reverseEasing() == .inElastic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inOutElastic.reverseEasing() == .outInElastic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outInElastic.reverseEasing() == .inOutElastic, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inBounce.reverseEasing() == .outBounce, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outBounce.reverseEasing() == .inBounce, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.outInBounce.reverseEasing() == .inOutBounce, "[testReverseEasing] - incorrect reverseEasing")
        XCTAssert(FAEasing.inOutBounce.reverseEasing() == .outInBounce, "[testReverseEasing] - incorrect reverseEasing")
    }
    
    func testParametricEasing()
    {
        XCTAssert(FAEasing.linear.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.smoothStep.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.smootherStep.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inAtan.parametricProgress(0.5)) == 0.044 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outAtan.parametricProgress(0.5)) == 0.956 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.inOutAtan.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inSine.parametricProgress(0.5)) == 0.293 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outSine.parametricProgress(0.5)) == 0.707 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inOutSine.parametricProgress(0.75)) == 0.854 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.outInSine.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.inQuadratic.parametricProgress(0.5) == 0.25 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.outQuadratic.parametricProgress(0.5) == 0.75 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.inOutQuadratic.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.outInQuadratic.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.inCubic.parametricProgress(0.5) == 0.125 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.outCubic.parametricProgress(0.5) == 0.875 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.inOutCubic.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.outInCubic.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inQuartic.parametricProgress(0.25)) == 0.004 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.outQuartic.parametricProgress(0.5) == 0.9375 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.inOutQuartic.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.outInQuartic.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.inQuintic.parametricProgress(0.5) == 0.03125 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.outQuintic.parametricProgress(0.5) == 0.96875 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.inOutQuintic.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.outInQuintic.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.inExponential.parametricProgress(0.5) == 0.03125 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.outExponential.parametricProgress(0.5) == 0.96875 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outInExponential.parametricProgress(0.5)) == 0.500 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.inOutExponential.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inCircular.parametricProgress(0.5)) == 0.134 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outCircular.parametricProgress(0.5)) == 0.866 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.outInCircular.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.inOutCircular.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inBack.parametricProgress(0.5)) == -0.088 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.outBack.parametricProgress(0.5) == 1.0876975 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.outInBack.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.inOutBack.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inElastic.parametricProgress(0.5)) == -0.022 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outElastic.parametricProgress(0.5)) == 1.022 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.outInElastic.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.inOutElastic.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inBounce.parametricProgress(0.5)) == 0.281 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outBounce.parametricProgress(0.5)) == 0.719 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outInBounce.parametricProgress(0.5)) == 0.500 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(FAEasing.inOutBounce.parametricProgress(0.5) == 0.5 , "[testParametricEasing] - incorrect testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outSine.parametricProgress(0.4)) == 0.588 , "[testParametricEasing] - incorrect \(FAEasing.outSine.parametricProgress(0.4)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inOutQuadratic.parametricProgress(0.4)) == 0.32 , "[testParametricEasing] - incorrect \(FAEasing.inOutQuadratic.parametricProgress(0.4)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outInQuadratic.parametricProgress(0.2)) == 0.32 , "[testParametricEasing] - incorrect \(FAEasing.outInQuadratic.parametricProgress(0.2)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outInQuartic.parametricProgress(0.2)) == 0.435 , "[testParametricEasing] - incorrect \(FAEasing.outInQuartic.parametricProgress(0.2)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inOutQuartic.parametricProgress(0.2)) == 0.013 , "[testParametricEasing] - incorrect \(FAEasing.inOutQuartic.parametricProgress(0.2)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inOutQuintic.parametricProgress(0.2)) == 0.005 , "[testParametricEasing] - incorrect \(FAEasing.inOutQuintic.parametricProgress(0.2)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inOutCubic.parametricProgress(0.2)) == 0.032 , "[testParametricEasing] - incorrect \(FAEasing.inOutCubic.parametricProgress(0.2)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inExponential.parametricProgress(0.0)) == 0.0 , "[testParametricEasing] - incorrect \(FAEasing.inExponential.parametricProgress(0.0)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outInExponential.parametricProgress(1.0)) == 0.5 , "[testParametricEasing] - incorrect \(FAEasing.outInExponential.parametricProgress(1.0)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outInExponential.parametricProgress(0.4)) == 0.498 , "[testParametricEasing] - incorrect \(FAEasing.outInExponential.parametricProgress(0.4)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outInSine.parametricProgress(0.4)) == 0.476 , "[testParametricEasing] - incorrect \(FAEasing.outInSine.parametricProgress(0.4)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inOutExponential.parametricProgress(0.25)) ==  0.016 , "[testParametricEasing] - incorrect \(FAEasing.inOutExponential.parametricProgress(0.25)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inOutExponential.parametricProgress(0.0)) == 0.0 , "[testParametricEasing] - incorrect \(FAEasing.inOutExponential.parametricProgress(0.0)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inOutExponential.parametricProgress(1.0)) == 1.0 , "[testParametricEasing] - incorrect \(FAEasing.inOutExponential.parametricProgress(1.0)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inOutCircular.parametricProgress(0.4)) == 0.2 , "[testParametricEasing] - incorrect \(FAEasing.inOutCircular.parametricProgress(0.4)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outInCircular.parametricProgress(0.4)) ==  0.490 , "[testParametricEasing] - incorrect \(FAEasing.outInCircular.parametricProgress(0.4)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inOutBack.parametricProgress(0.4)) == 0.021 , "[testParametricEasing] - incorrect \(FAEasing.inOutBack.parametricProgress(0.4)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outInBack.parametricProgress(0.4)) == -0.055 , "[testParametricEasing] - incorrect \(FAEasing.outInBack.parametricProgress(0.4)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inOutElastic.parametricProgress(0.4)) == -0.073 , "[testParametricEasing] - incorrect \(FAEasing.inOutElastic.parametricProgress(0.4)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outInElastic.parametricProgress(0.4)) ==  2.176 , "[testParametricEasing] - incorrect \(FAEasing.outInElastic.parametricProgress(0.4)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outBounce.parametricProgress(0.85)) ==  0.926 , "[testParametricEasing] - incorrect \(FAEasing.outBounce.parametricProgress(0.85)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.inOutBounce.parametricProgress(0.4)) == 0.349 , "[testParametricEasing] - incorrect \(FAEasing.inOutBounce.parametricProgress(0.4)) testParametricEasing")
        XCTAssert(roundedCGFloat(FAEasing.outInBounce.parametricProgress(0.4)) == 0.151 , "[testParametricEasing] - incorrect \(FAEasing.outInBounce.parametricProgress(0.4)) testParametricEasing")
    }
    
    func roundedCGFloat(_ value : CGFloat) -> CGFloat
    {
        return CGFloat(round(1000*value)/1000)
    }
}
