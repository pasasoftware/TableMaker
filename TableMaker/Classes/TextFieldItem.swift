//
//  TextFieldItem.swift
//  TableMaker
//
//  Created by Andrew Chai on 4/27/18.
//  Copyright © 2018 Andrew Chai. All rights reserved.
//

import UIKit
import Foundation

public class TextFieldCell: UITableViewCell {
    let textField: UITextField!
    
    private var textLeadingEmptyTitle: NSLayoutConstraint!
    private var textLeading: NSLayoutConstraint!
    
    private var textYEmptyTitle: NSLayoutConstraint!
    private var textY: NSLayoutConstraint!
    
    private var textFieldMinWidth: NSLayoutConstraint!
    
    public init(reuseIdentifier: String?) {
        textField = UITextField()
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        let margin = contentView.layoutMarginsGuide
        
        textLeadingEmptyTitle = textField.leadingAnchor.constraint(equalTo: margin.leadingAnchor)
        textLeading = textField.leadingAnchor.constraint(greaterThanOrEqualTo: textLabel!.trailingAnchor, constant: 5) // 修改 constant 为 5
        
        textY = textField.lastBaselineAnchor.constraint(equalTo: textLabel!.lastBaselineAnchor)
        textYEmptyTitle = textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        
        textFieldMinWidth = textField.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        
        contentView.addSubview(textField)
        
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        margin.trailingAnchor.constraint(equalTo: textField.trailingAnchor).isActive = true
        
        textFieldMinWidth.isActive = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    public override func prepareForReuse() {
        textField.delegate = nil
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        if let _ = textLabel?.text {
            NSLayoutConstraint.deactivate([textLeadingEmptyTitle, textYEmptyTitle])
            NSLayoutConstraint.activate([textLeading, textY])
        } else {
            NSLayoutConstraint.deactivate([textLeading, textY])
            NSLayoutConstraint.activate([textLeadingEmptyTitle, textYEmptyTitle])
        }
    }
}

//formatter won't work on TextFieldItem
//todo should set Converter directly when u is primitive types such as Int or Float
open class TextFieldItem<T, U: Equatable>: DataTableItem<T,U,String?>, UITextFieldDelegate{
    public var placeholder: String?
    
    open override var identifier: String {
        return "textFieldCellReuseId"
    }
    
    open override var autoReload: Bool{
        return false
    }
    
    public var textAlignment: NSTextAlignment = .right
    public var keyboardType: UIKeyboardType = .default
    
    public var leftView: UIView?
    public var rightView: UIView?
    
    private enum ErrorViewSide {
            case none, left, right
        }
    private var errorViewSide: ErrorViewSide = .none
    
    public override var status: DataItemStatus<String?>{
        didSet{
            switch status {
            case .normal:
                clearError()
            default:
                showError()
            }
        }
    }
    
    public init(_ data: T, host: TableItemHost, getter: @escaping (T) -> U) {
        super.init(data, getter: getter)
        self.host = host
    }
    
    open override func createCell() -> UITableViewCell {
        let cell = TextFieldCell(reuseIdentifier: identifier)
        cell.textField.textAlignment = .right
        cell.textField.keyboardType = keyboardType
        cell.selectionStyle = .none
        
        return cell
    }
    
    open override func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath) {
        super.setup(tableView, cell: cell, at: indexPath)
        guard let cell = cell as? TextFieldCell else {
            fatalError("textField cell is not set correctly")
        }
        cell.textLabel?.text = title
        cell.textField.textAlignment = textAlignment
        cell.textField.placeholder = placeholder
        cell.textField.text = convertValue()
        cell.textField.delegate = self
        cell.textField.returnKeyType = .done
        cell.textField.leftView = leftView ?? nil
        cell.textField.leftViewMode = leftView != nil ? .always : .never
        
        cell.textField.rightView = rightView ?? nil
        cell.textField.rightViewMode = rightView != nil ? .always : .never
        
        cell.setNeedsUpdateConstraints()
    }
    
    open override func endEdit() {
        if let cell = host?.getCell(self) as? TextFieldCell{
            cell.textField.resignFirstResponder()
        }
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        status = .normal
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        setValue(withConverted: textField.text)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEdit()
        return true
    }
    
    func showError() {
        if let cell = host?.getCell(self) as? TextFieldCell {
            let label = UILabel()
            label.text = "❗️"
            label.sizeToFit()
            
            if rightView == nil || leftView != nil {
                cell.textField.rightViewMode = .always
                cell.textField.rightView = label
                errorViewSide = .right
            } else {
                cell.textField.leftViewMode = .always
                cell.textField.leftView = label
                errorViewSide = .left
            }
        }
    }
    
    private func clearError() {
        guard let cell = host?.getCell(self) as? TextFieldCell else { return }
        cell.textField.leftViewMode = leftView != nil ? .always : .never
        cell.textField.rightViewMode = rightView != nil ? .always : .never
        cell.textField.leftView = leftView
        cell.textField.rightView = rightView
    }
    
    override func willSetValue() {
        super.willSetValue()
        clearError()
    }
    
    open override func select(_ tableView: UITableView, at indexPath: IndexPath) {
        super.select(tableView, at: indexPath)
        
        if let cell = tableView.cellForRow(at: indexPath) as? TextFieldCell {
            cell.textField.becomeFirstResponder()
        }
    }
}
