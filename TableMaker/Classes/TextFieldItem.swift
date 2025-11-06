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
    
    private enum Layout {
        static let textFieldMinWidth: CGFloat = 80
        static let labelToTextFieldSpacing: CGFloat = 5
    }
    
    public let textField: UITextField = {
        let field = UITextField()
        field.clearButtonMode = .whileEditing
        field.translatesAutoresizingMaskIntoConstraints = false
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return field
    }()
    
    private var isShowingTitleLayout: Bool = false
    
    private lazy var textLeadingEmptyTitle: NSLayoutConstraint = {
        let margin = contentView.layoutMarginsGuide
        return textField.leadingAnchor.constraint(equalTo: margin.leadingAnchor)
    }()
    
    private lazy var textLeading: NSLayoutConstraint = {
        return textField.leadingAnchor.constraint(
            greaterThanOrEqualTo: textLabel!.trailingAnchor,
            constant: Layout.labelToTextFieldSpacing
        )
    }()
    
    private lazy var textYEmptyTitle: NSLayoutConstraint = {
        textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    }()
    
    private lazy var textY: NSLayoutConstraint = {
        textField.lastBaselineAnchor.constraint(equalTo: textLabel!.lastBaselineAnchor)
    }()
    
    private lazy var textFieldMinWidth: NSLayoutConstraint = {
        textField.widthAnchor.constraint(
            greaterThanOrEqualToConstant: Layout.textFieldMinWidth
        )
    }()
    
    public init(reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        contentView.addSubview(textField)
        textLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func setupConstraints() {
        let margin = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            margin.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            textFieldMinWidth
        ])
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        
        let shouldShowTitle = textLabel?.text?.isEmpty == false
        
        guard shouldShowTitle != isShowingTitleLayout else {
            return
        }
        
        if shouldShowTitle {
            NSLayoutConstraint.deactivate([textLeadingEmptyTitle, textYEmptyTitle])
            NSLayoutConstraint.activate([textLeading, textY])
            isShowingTitleLayout = true
        } else {
            NSLayoutConstraint.deactivate([textLeading, textY])
            NSLayoutConstraint.activate([textLeadingEmptyTitle, textYEmptyTitle])
            isShowingTitleLayout = false
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        textField.delegate = nil
        
        textField.text = nil
        textField.placeholder = nil
        
        textField.leftView = nil
        textField.leftViewMode = .never
        textField.rightView = nil
        textField.rightViewMode = .never
        
        textField.textAlignment = .natural
        textField.returnKeyType = .default
    }
    
    public func configure(title: String?, placeholder: String? = nil, text: String? = nil) {
        textLabel?.text = title
        textField.placeholder = placeholder
        textField.text = text
        setNeedsUpdateConstraints()
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
        
        cell.textField.textAlignment = textAlignment
        cell.textField.delegate = self
        cell.textField.returnKeyType = .done
        if let leftView = leftView {
            cell.textField.leftView = leftView
            cell.textField.leftViewMode = .always
        }
        
        if let rightView = rightView {
            cell.textField.rightView = rightView
            cell.textField.rightViewMode = .always
        }
        
        cell.configure(title: title, placeholder: placeholder, text: convertValue())
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
