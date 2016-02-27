//
//  GraphView.swift
//  Calculator
//
//  Created by Vinod Ananth on 2/28/15.
//  Copyright (c) 2015 Vinod Ananth. All rights reserved.
//

import UIKit

//A graph view data source should implement this protocol
protocol GraphViewDataSource: class {
    func y(x: Double) -> Double?
}

@IBDesignable
class GraphView: UIView {

    //When device is rotated, you want to redraw. Go to IB and change the mode from scale to fill to redraw
    private var viewCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }
    var origin: CGPoint? {
        didSet {
            setNeedsDisplay()
        }
    }
    var pointsPerUnit:CGFloat = 50 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    //dataSource is the delegate. Has to be weak because this will be a pointer to controller which also has a pointer to this view
    weak var dataSource: GraphViewDataSource?
    

    //Cannot have an uninitialized variable. So have to use lazy. But cannot pass things into initializer of lazy var, so need to have 
    // a closure that will return the reference
    lazy var graphAxes:AxesDrawer = { return AxesDrawer(color: UIColor.blueColor(), contentScaleFactor: self.contentScaleFactor) } ()
    
    private struct Scaling {
        static let PinchToPPURatio:CGFloat = 2
    }
    
    //Scaling the graph
    func scale (gesture:UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            pointsPerUnit = pointsPerUnit * gesture.scale  //Change the points per unit depending on how much zoom was there
            //println("Gesture scale = \(gesture.scale)  PPU = \(pointsPerUnit)")
            gesture.scale = 1 //Reset scale so that next time you get the change
        }
    }
    
    //Panning the graph
    func pan (gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(self)
            origin?.x += translation.x
            origin?.y += translation.y
            //println("Panning: origin.x = \(origin?.x), origin.y = \(origin?.y)")
            gesture.setTranslation(CGPointZero, inView: self)
        default:break
        }
    }
    
    //Double tap
    func doubletap (gesture:UITapGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            let tapPoint = gesture.locationInView(self)
            //println("DoubleTap: graphX=\(origin!.x), graphY=\(origin!.y), tapX=\(tapPoint.x), tapY=\(tapPoint.y)")
            pointsPerUnit *= 2 //Scale
            origin?.x += viewCenter.x - tapPoint.x
            origin?.y += viewCenter.y - tapPoint.y
        default: break
        }
    }
    
    private func functionPath () -> UIBezierPath {
        var point = CGPoint()
        var firstPoint = true
        let path = UIBezierPath()
        
        for idx in Int(bounds.minX)...Int(bounds.maxX) {
            point.x = CGFloat(idx)
            if let eval = dataSource?.y(Double((point.x - origin!.x)/pointsPerUnit)) {
                if (!eval.isNormal) { //Discontinuous functions Nan etc., break and continue
                    firstPoint = true
                    continue
                }
                point.y = origin!.y - CGFloat(eval)*pointsPerUnit
            } else { //No evaluation available, graph just a point in origin
                point = origin!
                break
            }
            //println("Going to plot x=\(point.x) , y=\(point.y)")
            if firstPoint {
                path.moveToPoint(align(point))
                firstPoint = false
            } else {
                path.addLineToPoint(align(point))
            }
        }
        return path
    }
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * contentScaleFactor) / contentScaleFactor
    }
    private func align(point: CGPoint) -> CGPoint {
        var alignedPoint = CGPoint()
        alignedPoint.x = align(point.x)
        alignedPoint.y = align(point.y)
        return alignedPoint
    }

    
    override func drawRect(rect: CGRect) {
        if origin == nil {
            origin = viewCenter
        }
        graphAxes.drawAxesInRect(self.bounds, origin: origin!, pointsPerUnit: pointsPerUnit)
        functionPath().stroke()
    }

}
