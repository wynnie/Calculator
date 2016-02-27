//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Vinod Ananth on 2/16/15.
//  Copyright (c) 2015 Vinod Ananth. All rights reserved.
//

import Foundation
class CalculatorBrain {
    //enum can only have computed properties
    private enum Op: Printable {  //Printable is a protocol, it is not inheritance.
        case Variable (String)
        case Operand (Double)
        case UnaryOperation (String, Double -> Double)
        case BinaryOperation (String, (Double,Double) -> Double)
        case ConstantValue (String, Double)
        
        var description:String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .ConstantValue(let symbol,_):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                }
                
            }
        }
    }
    //var opStack = Array<Op>()
    private var opStack = [Op]()
    //var knownOps = Dictionary<String,Op>()
    private var knownOps = [String : Op]()
    var variableValues = [String:Double]()

    var program: AnyObject { //guaranteed to be a PropertyList
        get {
            return opStack.map {$0.description}
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    //Initializer
    init() {
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["÷"] = Op.BinaryOperation("÷") {$1 / $0}
        knownOps["+"] = Op.BinaryOperation("+",+)
        knownOps["−"] = Op.BinaryOperation("−") {$1 - $0}
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["π"] = Op.ConstantValue("π",M_PI)
    }
    
    //Except classes, everything else is passed by value. Arrays & Dicts are structs (even doubles and ints)
    //Pass by values are all read only by default
    private func evaluate (ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            //Switching enums
            switch op {
            case .Operand(let operand):
                return (operand,remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand),operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1,operand2),op2Evaluation.remainingOps)
                    }
                }
            case .ConstantValue(_, let operand):
                return (operand,remainingOps)
            case .Variable(let symbol):
                return (variableValues[symbol],remainingOps)
            }
            
        }
        return (nil,ops) //If any fails, return nil
    }
    func evaluate() -> Double? {
        let (result,remainder) = evaluate(opStack)
        println("\(opStack) evaluated to  \(result). Left over is \(remainder)")
        return result
    }
    
    private func description (ops:[Op]) -> (result:String?, remainingOps:[Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            //Switching enums
            switch op {
            case .Operand(let operand):
                return ("\(operand)",remainingOps)
            case .UnaryOperation(let symbol, _):
                let operandEvaluation = description(remainingOps)
                if let operand = operandEvaluation.result {
                    return (symbol+"("+operand+")",operandEvaluation.remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                let op1Evaluation = description(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = description(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return ("("+operand2+symbol+operand1+")",op2Evaluation.remainingOps)
                    }
                }
            case .ConstantValue(let symbol, _):
                return (symbol,remainingOps)
            case .Variable(let symbol):
                return (symbol,remainingOps)
            }
            
        }
        return (nil,ops) //If any fails, return nil

    }
    var description:String? {
        get {
            let (result,_) = description(opStack)
            return result
        }
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    func pushOperand(symbol:String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    func performOperation (symbol:String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    func allClear() {
        opStack.removeAll(keepCapacity: false)
    }
    func varClear(symbol:String) {
        variableValues[symbol] = nil
    }
  
    
    //    func performOperation (operation: (Double, Double) -> Double) {
    //        if (operandStack.count >= 2) {
    //            displayValue = operation (operandStack.removeLast(), operandStack.removeLast())
    //            enter()
    //        }
    //    }
    //    func performOperation (operation: Double -> Double) {
    //        if (operandStack.count >= 1) {
    //            displayValue = operation (operandStack.removeLast())
    //            enter()
    //        }
    //    }
    //    func performOperation (value: Double) {
    //        displayValue = value
    //        enter()
    //    }
    //    func operate () {
    //        switch operation {
    //            case "×": performOperation ({ (op1:Double, op2:Double) -> Double in return op1 * op2} ) //inline function
    //            //Swift has strong type inference, so no need for the doubles. Also, for a single line expression, it knows that it is the return value, so no need of return
    //            case "÷": performOperation ({ (op1,op2) in op2 / op1 })
    //            // Variables don't need names, can use the default $0,$1,$2 etc. names for the 1st, 2nd,3rd ... arguments.
    //            case "+": performOperation ({ $0 + $1 })
    //            //The last argument can go outside the () of the function
    //            case "−": performOperation () { $1 - $0 }
    //            //If there is only one argument, and you put it outside the (), then you can just remove the ()
    //            case "√": performOperation { sqrt($0) }
    //            case "sin": performOperation { sin($0) }
    //            case "π" : performOperation (M_PI)
    //            case "AC": allclear()
    //            default: break
    //        }
    //    }

}