//
//  TableItem.swift
//  TableMaker
//
//  Created by Andrew Chai on 4/25/18.
//  Copyright © 2018 Andrew Chai. All rights reserved.
//

import UIKit
import Foundation

public class IntStringConverter: Converter<Int,String?>{
    public override func convert(_ value: Int) -> String? {
        return value.description
    }

    public override func convertBack(_ value: String?) -> Int? {
        if let s = value {
            return Int(s)
        }
        return nil
    }
}

extension Optional: @retroactive CustomStringConvertible where Wrapped: CustomStringConvertible {
    public var description: String {
        switch self {
        case .some(let value):
            return value.description
        case .none:
            return ""
        }
    }
}

public protocol Failable{
    var isFailed: Bool {get}
    var message: String? {get}
}

open class Converter<T, U> {
    open func convert(_ value: T) -> U {
        return value as! U
    }

    open func convertBack(_ value: U) -> T? {
        return nil
    }

    public init(){

    }
}

public protocol TableItemHost : AnyObject {
    var viewController: UIViewController {get}
    var tableView: UITableView! {get}
    func valueWillChange(_ tableItem: TableItem)
    func valueDidChange(_ tableItem: TableItem)
    func getCell(_ tableItem: TableItem) -> UITableViewCell?
    func indexPath(for tableItem: TableItem) -> IndexPath?
    func reloadItem(_ tableItem: TableItem)
}

public enum DataItemStatus<U> {
    case normal
    case convertFailed(U)
    case validateFailed(String)
}

open class TableItem: NSObject {
    public var height: CGFloat?
    public var title: String?
    open var accessoryType: UITableViewCell.AccessoryType {
        return .none
    }

    open var identifier: String {
        fatalError("provide a valid identifier")
    }

    open func createCell() -> UITableViewCell{
        fatalError("should override createCell on subclass")
    }

    open func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath){
        cell.accessoryType = accessoryType
    }

    open func select(_ tableView: UITableView, at indexPath: IndexPath){
    }

    open func endEdit() {
    }

    open func accessoryButtonTapped(_ tableView: UITableView, at indexPath: IndexPath) {
    }
}


open class DataTableItem<T, U: Equatable & CustomStringConvertible, V: CustomStringConvertible>: TableItem, UIPopoverPresentationControllerDelegate{

    public weak var host: TableItemHost?

    public var data: T
    public var getter: ((T) -> U)
    public var setter: ((T,U) -> Void)?

    public var converter: Converter<U,V>?
    public var formatter: ((V)-> String?)?

    public var willChange: ((TableItem) -> Void)?
    public var didChange: ((TableItem) -> Void)?

    public var status = DataItemStatus<V>.normal
    public var convertFailed: ((V) -> Void)?

    public var validateFailed: ((Validator<U>) -> Void)?

    public var validators = [Validator<U>]()

    open var autoReload: Bool {
        return false
    }

    public init(_ data: T, getter: @escaping (T) -> U) {
        self.data = data
        self.getter = getter
    }

    public func getValue() -> U {
        return getter(data)
    }

    public func setValue(withConverted value: V) {
        if let converter = converter{
            if let cbv = converter.convertBack(value) {
                setValue(with: cbv)
            } else {
                onConvertFailed(value)
            }
        } else {
            setValue(with: value as! U)
        }
    }

    func setValue(with value: U) {
        guard let setter = setter else {
            return
        }

        if getValue() == value {
            status = .normal
            return
        }

        if let failedValidator = validate(value) {
            onValidateFailed(failedValidator)
            return
        }

        willSetValue()
        setter(data, value)
        didSetValue()
    }

    func onConvertFailed(_ value: V) {
        status = .convertFailed(value)
        if let convertFailed = convertFailed{
            convertFailed(value)
        }
    }

    func onValidateFailed(_ validator: Validator<U>){
        status = .validateFailed(validator.message)
        if let validateFailed = validateFailed {
            validateFailed(validator)
        }
    }

    func willSetValue() {
        status = .normal
        host?.valueWillChange(self)
        willChange?(self)
    }

    func didSetValue() {
        if autoReload {
            host?.reloadItem(self)
        }

        didChange?(self)
        host?.valueDidChange(self)
    }

    public func convertValue() -> V {
        return convertValue(with: getValue())
    }

    public func convertValue(with value: U)-> V {
        guard let converter = converter else {
            return value as! V
        }

        return converter.convert(value)
    }


    public func getDescription() -> String? {
        return getDescription(with: getValue())
    }

    public func getDescription(withConverted value: V) -> String? {
        guard let formatter = formatter else {
            return value.description
        }

        return formatter(value)
    }

    public func getDescription(with value: U) -> String? {
        return getDescription(withConverted: convertValue(with: value))
    }

    // MARK: - UIPopoverPresentationControllerDelegate
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    // MARK: - Call back
    @objc public func dismissController() {
        guard let vc = host?.viewController else { return }
        vc.dismiss(animated: true)
    }
}

extension DataTableItem : Validatable{
    public func getValidateMessage(_ validator: Validator<U>) -> String?{
        return "\(title.description) \(validator.message)"
    }

    public func getMessage() -> String?{
        switch status {
        case .convertFailed(let value):
            return "\(title.description) can't be \(value)"
        case .validateFailed(let message):
            return "\(title.description) \(message)"
        default:
            return nil
        }
    }
}

extension DataTableItem: Failable {
    public var message: String? {
        return getMessage()
    }

    public var isFailed: Bool {
        switch status {
        case .normal:
            return false
        default:
            return true
        }
    }
}
