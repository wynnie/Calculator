//
//  ViewController.swift
//  Calculator
//
//  Created by Vinod Ananth on 2/14/15.
//  Copyright (c) 2015 Vinod Ananth. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, GraphViewDataSource {

    //Outlet = Instance variable, also called a property.
    //All properties have to have a value when initialized
    //All objects are pointers and live in the heap. No need for * or &
    //var name: type
    //! unwraps the optional at declaration. Called implicitly unwrapped optional
    
    @IBOutlet weak var stack: UILabel!
    @IBOutlet weak var display: UILabel!
    
    //All variables must be initialized. Optionals get initialized to nul automatically
    var userIsInTheMiddleOfTyping: Bool = false
    var dotInText = false
    var brain = CalculatorBrain()
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let gvc = destination as? GraphViewController {
            gvc.dataSource = self
            gvc.title = brain.description
        }
    }
    
    func y (x:Double) -> Double? {
        let oldM = brain.variableValues["M"]
        brain.variableValues["M"] = x
        let result = brain.evaluate()
        brain.variableValues["M"] = oldM
        return result
    }

    //Action is a method. Make sure send type is not anyObject but UIButton
    //The @ puts a button in the gutter on the left
    //sender is the var name in the function and UIButton is the type
    @IBAction func appendDigit(sender: UIButton) {
        //let is the same as var, except that it is a CONSTANT
        //Exclamation point unwraps an optional, so that digit is a string. But if it is a nil state, then program
        //will crash
        let digit = sender.currentTitle!
        
        if (userIsInTheMiddleOfTyping)  {
            if (digit == ".") {
                if (!dotInText) {
                    dotInText = true
                    display.text = display.text! + digit
                }
            } else {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
        //println("digit = \(digit)")
    }
    //If a variable can be inferred, it should be. So instead of commented out code below,
    //we just use the variable with type inference
    //var operandStack: Array<double> = Array<double>()
    
    @IBAction func varSet(sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        dotInText = false
        brain.variableValues["M"] = displayValue
        displayValue = 0
    }
    @IBAction func varUse(sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        dotInText = false
        displayValue = brain.pushOperand("M")
        stackText = brain.description
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTyping = false
        dotInText = false
        displayValue = brain.pushOperand(displayValue!)
        stackText = brain.description
        //println("operandStack = \(operandStack)")
    }
    
    @IBAction func memClear() {
        brain.varClear("M")
    }
    @IBAction func allclear() {
        displayValue = 0
        stackText = "0"
        brain.allClear()
    }
    //To tie the display text to this double variable, make it a function with get/set
    //newValue is
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            if let nv = newValue {
                display.text = "\(nv)"
            } else {
                display.text = "ERROR"
            }
            userIsInTheMiddleOfTyping = false
        }
    }
    var stackText : String? {
        get {
            return stack.text
        }
        set {
            if let nv = newValue {
                stack.text = nv
            } else {
                stack.text = "0"
            }
        }
    }

    @IBAction func operate(sender: UIButton) {
        if (userIsInTheMiddleOfTyping) {
            enter()
        }
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
            stackText = brain.description
        }
    }
}

