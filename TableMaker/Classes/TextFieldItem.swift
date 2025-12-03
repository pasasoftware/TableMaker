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
        static let stackSpacing: CGFloat = 8
        static let textFieldMinWidth: CGFloat = 80
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    public let textField: UITextField = {
        let field = UITextField()
        field.clearButtonMode = .whileEditing
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return field
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, textField])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = Layout.stackSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var textFieldMinWidth: NSLayoutConstraint = {
        textField.widthAnchor.constraint(
            greaterThanOrEqualToConstant: Layout.textFieldMinWidth
        )
    }()
    
    // 新增：记录左右视图
    private weak var leftView: UIView?
    private weak var rightView: UIView?
    
    public init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(stackView)
        
        let margin = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: margin.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: margin.bottomAnchor),
            textFieldMinWidth
        ])
    }
    
    fileprivate func clearRightViewLeftView() {
        // 移除所有非 titleLabel 和 textField 的子视图
        if let leftView = leftView {
            stackView.removeArrangedSubview(leftView)
            leftView.removeFromSuperview()
            self.leftView = nil
        }
        
        if let rightView = rightView {
            stackView.removeArrangedSubview(rightView)
            rightView.removeFromSuperview()
            self.rightView = nil
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        textField.delegate = nil
        textField.text = nil
        textField.placeholder = nil
        titleLabel.text = nil
        
        clearRightViewLeftView()
        
        textField.textAlignment = .natural
        textField.returnKeyType = .default
    }
    
    public func configure(title: String?, placeholder: String? = nil, text: String? = nil, isRequire: Bool = false) {
        titleLabel.setLabelWithRequiredMark(title, isRequire: isRequire)
        titleLabel.isHidden = title?.isEmpty ?? true
        textField.placeholder = placeholder
        textField.text = text
    }
    
    public func setLeftView(_ view: UIView) {
        if let oldLeftView = leftView {
            stackView.removeArrangedSubview(oldLeftView)
            oldLeftView.removeFromSuperview()
        }
        
        view.setContentHuggingPriority(.required, for: . horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // 找到 titleLabel 的位置，在其后插入
        if let titleIndex = stackView.arrangedSubviews.firstIndex(of: titleLabel) {
            stackView.insertArrangedSubview(view, at: titleIndex + 1)
        } else {
            stackView.insertArrangedSubview(view, at: 0)
        }
        
        self.leftView = view
    }
    
    public func setRightView(_ view: UIView) {
        if let oldRightView = rightView {
            stackView.removeArrangedSubview(oldRightView)
            oldRightView.removeFromSuperview()
        }
        
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.addArrangedSubview(view)
        
        self.rightView = view
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
        
        // 只在有值时才设置 leftView 和 rightView
        if let leftView = leftView {
            cell.setLeftView(leftView)
        }
        
        if let rightView = rightView {
            cell.setRightView(rightView)
        }
        
        cell.configure(title: title, placeholder: placeholder, text: convertValue(), isRequire: isRequire)
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
                cell.setRightView(label)
                errorViewSide = .right
            } else {
                cell.setLeftView(label)
                errorViewSide = .left
            }
        }
    }
    
    private func clearError() {
        guard let cell = host?.getCell(self) as? TextFieldCell else { return }
        
        // 移除所有非 titleLabel 和 textField 的子视图，重新设置
        cell.clearRightViewLeftView()
        
        // 重新设置原始的 leftView 和 rightView
        if let leftView = leftView {
            cell.setLeftView(leftView)
        }
        
        if let rightView = rightView {
            cell.setRightView(rightView)
        }
        
        errorViewSide = .none
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
