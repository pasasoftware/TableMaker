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

extension Optional : CustomStringConvertible {
    public var description: String {
        switch self {
        case .some(let value):
            var result = ""
            print(value, terminator: "", to: &result)
            return result
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
//            return (V)value
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



open class TweakLabelItem<T, U: Equatable & CustomStringConvertible, V: CustomStringConvertible>: DataTableItem<T, U, V> {
    open override var identifier: String {
        return "TweakLabelCellReuseId"
    }

    public override init(_ data: T, getter: @escaping (T) -> U) {
        super.init(data, getter: getter)
        height = UITableView.automaticDimension
    }

    open override func createCell() -> UITableViewCell {
        let cell = TweakLabelCell(style: .value1, reuseIdentifier: identifier)
        cell.selectionStyle = .none
        return cell
    }

    open override func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath) {
        super.setup(tableView, cell: cell, at: indexPath)

        // Set text
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = getDescription()
        cell.setNeedsUpdateConstraints()
    }
}

//todo TweakLabelItem2 should be TweakLabelItem, but swift don't support it
public typealias TweakLabelItem2<T, U: Equatable & CustomStringConvertible> = TweakLabelItem<T, U, U>


open class CheckItem<T, U: Equatable & CustomStringConvertible>: DataTableItem<T,U,Bool> {
    
    open override var identifier: String {
        return "CheckCellReuseId"
    }
    
    open override var autoReload: Bool{
        return true
    }
    
    public init(_ data: T, host: TableItemHost, getter: @escaping (T) -> U) {
        super.init(data, getter: getter)
        self.host = host
    }
    
    // MARK: - Override
    open override func createCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        cell.accessoryType = .none
        return cell
    }
    
    open override func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath) {
        super.setup(tableView, cell: cell, at: indexPath)
        cell.textLabel?.text = title
        if convertValue() {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
    }
    
    open override func select(_ tableView: UITableView, at indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        setValue(withConverted: !convertValue())
    }
}

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



public class TextFieldCell: UITableViewCell {
    let textField: UITextField!
    
    private var textLeadingEmptyTitle: NSLayoutConstraint!
    private var textLeading: NSLayoutConstraint!
    
    private var textYEmptyTitle: NSLayoutConstraint!
    private var textY: NSLayoutConstraint!
    
    
    public init(reuseIdentifier: String?) {
        textField = UITextField()
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        let margin = contentView.layoutMarginsGuide
        
        textLeadingEmptyTitle = textField.leadingAnchor.constraint(equalTo: margin.leadingAnchor)
        textLeading = textField.leadingAnchor.constraint(equalTo: textLabel!.trailingAnchor, constant: 8)
        
        textY = textField.lastBaselineAnchor.constraint(equalTo: textLabel!.lastBaselineAnchor)
        textYEmptyTitle = textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        
        contentView.addSubview(textField)
        
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        margin.trailingAnchor.constraint(equalTo: textField.trailingAnchor).isActive = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    public override func prepareForReuse() {
        textField.delegate = nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override public func updateConstraints() {
        super.updateConstraints()
        if let _ = textLabel?.text {
            NSLayoutConstraint.deactivate([textLeadingEmptyTitle, textYEmptyTitle])
            NSLayoutConstraint.activate([textLeading,textY])
        } else {
            NSLayoutConstraint.deactivate([textLeading,textY])
            NSLayoutConstraint.activate([textLeadingEmptyTitle, textYEmptyTitle])
        }
    }
}

//formatter won't work on TextFieldItem
//todo should set Converter directly when u is primitive types such as Int or Float
open class TextFieldItem<T, U: Equatable & CustomStringConvertible>: DataTableItem<T,U,String?>, UITextFieldDelegate{
    public var placeholder: String?
    
    open override var identifier: String {
        return "textFieldCellReuseId"
    }
    
    open override var autoReload: Bool{
        return false
    }
    
    public var textAlignment: NSTextAlignment = .right
    
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
            cell.textField.rightViewMode = .always
            let label = UILabel()
            label.text = "❗️"
            label.sizeToFit()
            cell.textField.rightView = label
        }
    }
    
    func clearError() {
        if let cell = host?.getCell(self) as? TextFieldCell {
            cell.textField.rightViewMode = .never
            cell.textField.rightView = nil
        }
    }
    
    override func willSetValue() {
        super.willSetValue()
        clearError()
    }
    
}


open class ComboItem<T, U: Equatable & CustomStringConvertible>: TextFieldItem<T,U> {
    
    public typealias V = String?
    
    // MARK: - Property
    override open var accessoryType: UITableViewCell.AccessoryType {
        return .detailButton
    }
    
    /// As datasource of options.
    public var values: [U]
    
    /// Determine the style of options, default is "Push".
    public var style = SelectorItemStyle.push
    
    // MARK: - Constructor
    public init(_ data: T, host: TableItemHost, values: [U], getter: @escaping (T) -> U) {
        self.values = values
        super.init(data, host: host, getter: getter)
    }
    
    // MARK: - Override
    open override func accessoryButtonTapped(_ tableView: UITableView, at indexPath: IndexPath) {
        // Different behaviors based on style
        switch style {
        case .actionSheet:
            showActionSheetWith(sourceView: getSourceView(tableView: tableView, indexPath: indexPath))
//            showActionSheetWith(sourceView: getSourceView(tableView: tableView, indexPath: indexPath), dataTableItem: self)
        case .push:
            if let vc = createSelectorViewControlelr() {
                showPush(vc)
            }
        case .popover:
            if let vc = createSelectorViewControlelr() {
                showPopover(vc, sourceView: getSourceView(tableView: tableView, indexPath: indexPath))
            }
        }
    }
}

extension ComboItem {
    // MARK: - Show Selector

    // Show as action sheet
    public func showActionSheetWith(sourceView: UIView?) {
        // Options are nil or host not 'UIViewController' and return directly
        guard let vc = host?.viewController else {
            return
        }

        // Create alert
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)

        // Adapt iPad.
        // AlertController need to set popoverPresentationController's souceview and source rect.
        if let sourceView = sourceView {
            alert.popoverPresentationController?.sourceView = sourceView
            alert.popoverPresentationController?.sourceRect = sourceView.bounds
        }

        // Add action to alert
        alert.addAction(UIAlertAction(title: Localizable.Cancel.localized, style: .cancel, handler: nil))
        for item in values {
            alert.addAction(UIAlertAction(title: getDescription(with: item), style: .default){[weak self] _ in
                self?.setValue(with: item)
            })
        }

        // Present alert controller
        vc.present(alert, animated: true, completion: nil)
    }

    public func showPush(_ controller: UIViewController) {
        // Get source controlelr
        let sourceVC = host?.viewController

        // SourceVC and sourceVC.navigationController is not nil and push directly
        if  let sourceVC = sourceVC,
            let nav = sourceVC.navigationController {
            nav.pushViewController(controller, animated: true)
        } else if let sourceVC = sourceVC { // If sourceVC is not nil then try present controller

            // Create done button
            let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissController))

            // Set navigationItem
            controller.navigationItem.rightBarButtonItem = doneBarButton

            // Create navigationController
            let naviController = UINavigationController(rootViewController: controller)

            // Present
            sourceVC.present(naviController, animated: true, completion: nil)
        }
    }

    public func showPopover(_ controller: UIViewController, sourceView: UIView?) {

        // Sorce controlelr is nil then return directly
        guard let source =  host?.viewController else { return }

        // Create navigationController
        let nav = UINavigationController(rootViewController: controller)

        // Set navigationController popover related
        nav.modalPresentationStyle = .popover
        let popover = nav.popoverPresentationController
        popover?.delegate = self
        if let sourceView = sourceView {
            // Set sourceView and source rect
            popover?.sourceView = sourceView
            popover?.sourceRect = sourceView.bounds

            // Present
            source.present(nav, animated: true, completion: nil)
        }
    }


    public func createSelectorViewControlelr() -> SelectorViewController<U>? {

        // Create selector view controller
        let selectorVC = SelectorViewController<U>()

        // Set title
        selectorVC.title = title

        // Set datasource
        selectorVC.datas = values

        // Set formatter
        selectorVC.formatter = getDescription(with:)

        // Set selectedValue
        selectorVC.selectedValue = getValue()

        // Set call back: Set value to 'T' when selctor VC disappear
        selectorVC.disappearing = {[weak self] (value) in
            if let value = value {
                self?.setValue(with: value)
            }
        }
        return selectorVC
    }
    
}

extension ComboItem {
    
    // MARK: - Util
    
    private func getSourceView(tableView: UITableView, indexPath: IndexPath) -> UIView? {
        if let cell = tableView.cellForRow(at: indexPath) {
            return getSystemDetailButtonWith(cell)
        }
        return nil
    }
    
    private func getSystemDetailButtonWith(_ cell: UITableViewCell) -> UIView? {
        return  cell.subviews.first(){ $0 is UIButton }
    }
}


extension UITextView{
    func setPlaceholder(){
        let placeHolderLabel = UILabel.init()
        placeHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeHolderLabel.numberOfLines = 0
        placeHolderLabel.font = font
        placeHolderLabel.textColor = UIColor.lightGray
        self.addSubview(placeHolderLabel)
        self.setValue(placeHolderLabel, forKey: "_placeholderLabel")
        NSLayoutConstraint.activate([
            placeHolderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            placeHolderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            placeHolderLabel.topAnchor.constraint(equalTo: self.topAnchor),
            placeHolderLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ])
    }
}

public class TextViewCell: UITableViewCell{
    let textView: UITextView!
    
    public init(reuseIdentifier: String?) {
        textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.translatesAutoresizingMaskIntoConstraints = false
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            ])
        textView.setPlaceholder()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    public override func prepareForReuse() {
        textView.delegate = nil
    }
    
}

open class TextViewItem<T, U: Equatable & CustomStringConvertible>: DataTableItem<T,U,String?>, UITextViewDelegate{
    public var placeholder: String?
    private var preTextViewHeight: CGFloat?
    open override var identifier: String {
        return "textViewCellReuseId"
    }
    
    public override init(_ data: T, getter: @escaping (T) -> U) {
        super.init(data, getter: getter)
        height = UITableView.automaticDimension
    }
    
    open override var autoReload: Bool{
        return false
    }
    
    open override func createCell() -> UITableViewCell {
        let cell = TextViewCell(reuseIdentifier: identifier)
        cell.selectionStyle = .none
        return cell
    }
    
    override open func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath) {
        super.setup(tableView, cell: cell, at: indexPath)
        guard let cell = cell as? TextViewCell else {
            fatalError("textView cell is not set correctly")
        }
        let label = cell.textView.value(forKey: "_placeholderLabel") as! UILabel
        label.text = placeholder
        cell.textView.text = convertValue()
        cell.textView.delegate = self
        if height != UITableView.automaticDimension {
            cell.textView.isScrollEnabled = true
        }else{
            cell.textView.isScrollEnabled = false
        }
    }
    
    open override func endEdit() {
        if let cell = host?.getCell(self) as? TextViewCell{
            cell.textView.resignFirstResponder()
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        setValue(withConverted: textView.text)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if preTextViewHeight == 0 {
            preTextViewHeight = textViewHeight(textView)
        }else{
            //when  add line or reduce line
            if preTextViewHeight != textViewHeight(textView){
                preTextViewHeight = textViewHeight(textView)
                guard let host = host else {
                    return
                }
                let tableView = host.tableView!
                tableView.beginUpdates()
                tableView.endUpdates()
                tableView.scrollToRow(at: host.indexPath(for: self)!, at: .bottom, animated: true)
            }
        }
    }
    
    public func textViewHeight(_ textView: UITextView) -> CGFloat{
        //use textView.contentSize when newline is no right.
        let size = CGSize(width: textView.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let height = textView.sizeThatFits(size).height + textView.textContainerInset.bottom
        return height
    }
}
