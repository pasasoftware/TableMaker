//
//  Validator.swift
//  TableMaker
//
//  Created by Andrew Chai on 4/27/18.
//  Copyright © 2018 Andrew Chai. All rights reserved.
//

import Foundation

public protocol Validatable : AnyObject {
    associatedtype T
    var validators: [Validator<T>] {get set}
}

public extension Validatable {
    public func addValidator(_ validator: Validator<T>) {
        validators.append(validator)
    }
    
    public func removeValidator(_ validator: Validator<T>) {
        if let index = validators.index(where: {$0 === validator}) {
            validators.remove(at: index)
        }
    }
    
    func validate(_ value: T) -> Validator<T>? {
        for v in validators {
            if !v.validate(value) {
                return v
            }
        }
        return nil
    }
}

open class Validator<T>{
    open var message: String{
        return ""
    }
    
    public init() {
    }
    
    open func validate(_ value: T) -> Bool{
        return false
    }
}

public class RequiredValidator: Validator<String?>{
    public override var message: String{
        return "is required"
    }
    
//    public init() {
//        
//    }
    
    public override func validate(_ value: String?) -> Bool {
        guard let s = value else {return false}
        return !s.isEmpty
    }
}

public class ValueValidator<T: Comparable>: Validator<T>{
    public var value: T
    public var comparer: (T,T)->Bool
    public init(_ value: T, comparer: @escaping (T,T)->Bool) {
        self.value = value
        self.comparer = comparer
    }
    
    public override func validate(_ value: T) -> Bool {
        return comparer(value,self.value)
    }
}

public class GreaterThanValidator<T: Comparable>: Validator<T>{
    public var value: T
    
    public init(_ value: T) {
        self.value = value
    }
    
    public override var message: String{
        return "must greater than \(value)"
    }
    
    public override func validate(_ value: T) -> Bool {
        return value > self.value
    }
}

public class GreaterThanOrEqualToValidator<T: Comparable>: Validator<T>{
    public var value: T
    
    public init(_ value: T) {
        self.value = value
    }
    
    public override var message: String{
        return "must greater than or equal to\(value)"
    }
    
    public override func validate(_ value: T) -> Bool {
        return value >= self.value
    }
}

public class LessThanValidator<T: Comparable>: Validator<T>{
    public var value: T
    
    public init(_ value: T) {
        self.value = value
    }
    
    public override var message: String{
        return "must less than \(value)"
    }
    
    public override func validate(_ value: T) -> Bool {
        return value < self.value
    }
}

public class LessThanOrEqualToValidator<T: Comparable>: Validator<T>{
    public var value: T
    
    public init(_ value: T) {
        self.value = value
    }
    
    public override var message: String{
        return "must less than or equal to\(value)"
    }
    
    public override func validate(_ value: T) -> Bool {
        return value <= self.value
    }
}

public let phoneRegex = "^((13[0-9])|(14[5,7,9])|(15[^4,\\D])|(18[0,0-9])|(17[0,1,3,5,6,7,8]))\\d{8}$"
public let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"

public class RegexValidator: Validator<String?>{
    public var regex: String
    
    public init(_ value: String) {
        self.regex = value
    }
    
    public override var message: String{
        return "incorrect format"
    }
    
    public override func validate(_ value: String?) -> Bool {
        guard let s = value else {return false}
        let regex = NSPredicate(format: "SELF MATCHES %@", self.regex)
        return regex.evaluate(with: s)
    }
}


