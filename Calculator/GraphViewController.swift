//
//  GraphViewController.swift
//  Calculator
//
//  Created by Vinod Ananth on 2/28/15.
//  Copyright (c) 2015 Vinod Ananth. All rights reserved.
//

import UIKit


class GraphViewController: UIViewController, GraphViewDataSource {

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "pan:"))
            
            let doubleTapRecognizer = UITapGestureRecognizer(target: graphView, action: "doubletap:")
            doubleTapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTapRecognizer)
            graphView.dataSource = self //Set myself as the delegate
        }
    }
    weak var dataSource: GraphViewDataSource?
    
    func y (x: Double) -> Double? {
        return dataSource?.y(x)
    }
    
}
