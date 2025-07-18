//
//  DateItem.swift
//  TableMaker
//
//  Created by pasasoft on 2018/4/28.
//  Copyright © 2018年 Andrew Chai. All rights reserved.
//

import Foundation
import UIKit

open class DateCell: UITableViewCell {
    // MARK: - Property
    public var doneAction: ((Date) -> Void)?
    
    public lazy var datePicker: UIDatePicker = {
        return UIDatePicker()
    }()
    
    public lazy var dateAccessoryView: UIToolbar = {
        let accessoryView = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        let seperateButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        accessoryView.setItems([seperateButton, doneButton], animated: false)
        accessoryView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44)
        return accessoryView
    }()
    
    // MARK: - Constructor
    public required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Overide: Return inputView and inputAccessoryView
    override open var inputView: UIView? {
        return datePicker
    }
    
    override open var inputAccessoryView: UIView? {
        return dateAccessoryView
    }
    
    open override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Done clicked CallBack
    @objc func doneTapped() {
        guard let doneAction = doneAction else { return }
        doneAction(datePicker.date)
    }
}

open class DateItem<T, U: Equatable & CustomStringConvertible> : LabelItem<T, U, Date> {
    // MARK: - Property
    open override var identifier: String {
        return "dateCellReuseId"
    }
    
    public var datePickerMode: UIDatePicker.Mode = .date
    
    open override var autoReload: Bool {
        return true
    }
    
    open override var accessoryType: UITableViewCell.AccessoryType {
        return .disclosureIndicator
    }
    
    // MARK: - Constructor
    public init(_ data: T, host: TableItemHost, getter: @escaping (T) -> U) {
        super.init(data, getter: getter)
        self.host = host
    }
    
    // MARK: - Override
    open override func createCell() -> UITableViewCell {
        let cell = DateCell(style: .value1, reuseIdentifier: identifier)
        return cell
    }
    
    open override func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath) {
        super.setup(tableView, cell: cell, at: indexPath)
        let cell = cell as! DateCell
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = getDescription(withConverted: convertValue())
    }
    
    open override func select(_ tableView: UITableView, at indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! DateCell
        let date = convertValue()
        cell.datePicker.date = date
        cell.datePicker.datePickerMode = datePickerMode
        cell.doneAction = {[weak self] (date) in
            self?.setValue(withConverted: date)
            cell.resignFirstResponder()
        }
        cell.becomeFirstResponder()
    }
    
    open override func getDescription(withConverted value: Date) -> String? {
        guard let formatter = formatter else {
            switch datePickerMode {
            case .date:
                return DateFormatter.localizedString(from: value, dateStyle: .short, timeStyle: .none)
            case .time:
                return DateFormatter.localizedString(from: value, dateStyle: .none, timeStyle: .short)
            case .dateAndTime:
                return DateFormatter.localizedString(from: value, dateStyle: .short, timeStyle: .short)
            default :
                return DateFormatter.localizedString(from: value, dateStyle: .short, timeStyle: .none)
            }
        }
        
        return formatter(value)
    }
    
    open override func endEdit() {
        if let cell = host?.getCell(self) as? DateCell {
            cell.resignFirstResponder()
        }
    }
}
