//
//  BezierTestViewController.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 4/25/18.
//  Copyright © 2018 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

class BezierTestViewController : UIViewController {
    
    let spiralShape1 = CAShapeLayer()
    let spiralShape2 = CAShapeLayer()
    let π = CGFloat(Double.pi)
    var bounds = CGRect()
    var center = CGPoint()
    var radius = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bounds = view.bounds
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        clockwiseSpiral()
        counterclockwiseSpiral()
        
        // Animate drawing
      //   drawLayerAnimation(layer: spiralShape2)
        // Animate drawing
      //  drawLayerAnimation(layer: spiralShape1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Setup the clockwise spiral settings
    func clockwiseSpiral(){
        
        var startAngle:CGFloat = 3*π/2
        var endAngle:CGFloat = 0
        
        center = CGPoint(x:bounds.width/3, y: bounds.height/3)
        
        // Setup the initial radius
        radius = bounds.width/90
        
        // Use UIBezierPath to create the CGPath for the layer
        // The path should be the entire spiral
        
        // 1st arc
        let linePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        // 2 - 9 arcs
        for _ in 2..<10 {
            
            startAngle = endAngle
            
            switch startAngle {
            case 0, 2*π:
                center = CGPoint(x: center.x - radius/2, y: center.y)
                endAngle = π/2
            case π:
                center = CGPoint(x: center.x + radius/2, y: center.y)
                endAngle = 3*π/2
            case π/2:
                center = CGPoint(x: center.x  , y: center.y - radius/2)
                endAngle = π
            case 3*π/2:
                center = CGPoint(x: center.x, y: center.y + radius/2)
                endAngle = 2*π
            default:
                center = CGPoint(x:bounds.width/3, y: bounds.height/3)
            }
            
            radius = 1.5 * radius
            linePath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle,clockwise: true)
        }
        
        // Setup the CAShapeLayer with the path, line width and stroke color
        spiralShape1.position = center
        spiralShape1.path = linePath.cgPath
        spiralShape1.lineWidth = 6.0
        spiralShape1.strokeColor = UIColor.yellow.cgColor
        spiralShape1.bounds = spiralShape1.path!.boundingBox// CGPathGetBoundingBox(spiralShape1.path!)
        spiralShape1.fillColor = UIColor.clear.cgColor
        
        // Add the CAShapeLayer to the view's layer's sublayers
        view.layer.addSublayer(spiralShape1)
        
        // Animate drawing
      //  drawLayerAnimation(layer: spiralShape1)
        
    }
    
    // Setup the ounterclockwise spiral settings
    func counterclockwiseSpiral(){
        
        var startAngle:CGFloat = 3*π/2
        var endAngle:CGFloat = π
        
        center = CGPoint(x:bounds.width/3 + bounds.width/3, y: bounds.height/3)
        
        // Setup the initial radius
        radius = bounds.width/90
        
        // Use UIBezierPath to create the CGPath for the layer
        // The path should be the entire spiral
        
        // 1st arc
        let linePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        // 2 - 9 arcs
        for _ in 2..<10 {
            
            startAngle = endAngle
            
            switch startAngle {
            case 0:
                center = CGPoint(x: center.x - radius/2, y: center.y)
                endAngle = 3*π/2
            case π:
                center = CGPoint(x: center.x + radius/2, y: center.y)
                endAngle = π/2
            case π/2:
                center = CGPoint(x: center.x , y: center.y - radius/2)
                endAngle = 0
            case 3*π/2:
                center = CGPoint(x: center.x, y: center.y + radius/2)
                endAngle = π
            default:
                center = CGPoint(x:bounds.width/3 + bounds.width/3, y: bounds.height/3)
            }
            
            radius = 1.5 * radius
            linePath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle,clockwise: false)
        }
        
        // Setup the CAShapeLayer with the position, path, line width and stroke color
        spiralShape2.position = center
        spiralShape2.path = linePath.cgPath
        spiralShape2.lineWidth = 6.0
        spiralShape2.strokeColor = UIColor(red:0.99, green:0.57, blue:0.18, alpha:1.0).cgColor
        spiralShape2.bounds = spiralShape2.path!.boundingBox
        spiralShape2.fillColor = UIColor.clear.cgColor
        
        // Add the CAShapeLayer to the view's layer's sublayers
        view.layer.addSublayer(spiralShape2)
        
        // Animate drawing
        drawLayerAnimation(layer: spiralShape2)
        
    }
    
    func drawLayerAnimation(layer: CAShapeLayer!)
    {
        let layerShape = layer
        
        
        // The starting point
        layerShape?.strokeStart = 0.0
        
        // Don't draw the spiral initially
        layerShape?.strokeEnd = 0.0
        
        view.animate { (animator) in
            animator.value(1.0, forKeyPath: "strokeEnd").easing(.outSine).duration(0.5)
        }
        /*
        // Animate from 0 (no spiral stroke) to 1 (full spiral path)
        let drawAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        drawAnimation.fromValue = 0.0
        drawAnimation.toValue = 1.0
        drawAnimation.duration = 1.6
        drawAnimation.fillMode = kCAFillModeForwards
        drawAnimation.isRemovedOnCompletion = false
        layerShape?.add(drawAnimation, forKey: nil)
 */
    }
}


import UIKit
class MyCustomView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        
        // Create a CAShapeLayer
        let shapeLayer = CAShapeLayer()
        
        // The Bezier path that we made needs to be converted to
        // a CGPath before it can be used on a layer.
        shapeLayer.path = createBezierPath().cgPath
        
        // apply other properties related to the path
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.position = CGPoint(x: 10, y: 10)
        
        // add the new layer to our custom view
        self.layer.addSublayer(shapeLayer)
    }
    
    func createBezierPath() -> UIBezierPath {
        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: 50,  y: 0))
        arrowPath.addLine(to: CGPoint(x: 70,  y: 25))
        arrowPath.addLine(to: CGPoint(x: 60,  y: 25))
        arrowPath.addLine(to: CGPoint(x: 60,  y: 75))
        arrowPath.addLine(to: CGPoint(x: 40,  y: 75))
        arrowPath.addLine(to: CGPoint(x: 40,  y: 25))
        arrowPath.addLine(to: CGPoint(x: 30,  y: 25))
        arrowPath.addLine(to: CGPoint(x: 50, y: 0))
        arrowPath.close()
        
        print(arrowPath.cgPath.getPathElementsPoints())
        
        return arrowPath
    }
}
