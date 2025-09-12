//
//  TextViewItem.swift
//  TableMaker
//
//  Created by pasasoft_mini on 2018/5/7.
//  Copyright © 2018年 Andrew Chai. All rights reserved.
//

import UIKit
import Foundation

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
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.font = .preferredFont(forTextStyle: .body)
        textView.isEditable = true
        return textView
    }()
    
    public init(reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textView)
        
        textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        
        textView.setPlaceholder()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    public override func prepareForReuse() {
        textView.delegate = nil
    }
    
}

open class TextViewItem<T, U: Equatable>: DataTableItem<T,U,String?>, UITextViewDelegate {
    public var placeholder: String?
    
    public var minHeight: CGFloat = 44.0
    public var enlargedHeight: CGFloat? = 120.0
    public var maxHeight: CGFloat? // 当非 nil 时，优先使用
    public var numberOfLines: Int = 3 { // 默认 3 行，0 表示无限高，仅在 maxHeight 为 nil 时生效
        didSet {
            numberOfLines = max(0, numberOfLines)
        }
    }
    private var isTextViewEditing: Bool = false
    
    open override var identifier: String {
        return "textViewCellReuseId"
    }
    
    var tableView: UITableView? {
        guard let host else {
            return nil
        }
        return host.tableView
    }
    
    public override init(_ data: T, getter: @escaping (T) -> U) {
        super.init(data, getter: getter)
        height = minHeight
    }
    
    open override var autoReload: Bool {
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
            print("Error: Cell is not TextViewCell")
            return
        }
        let label = cell.textView.value(forKey: "_placeholderLabel") as! UILabel
        label.text = placeholder
        cell.textView.text = convertValue()
        cell.textView.delegate = self

        if maxHeight == nil {
            maxHeight = numberOfLines > 0 ? calculateMaxHeight(for: cell.textView, numberOfLines: numberOfLines) : nil
        }
        
        textViewHeight(for: cell, at: indexPath)
    }
    
    open override func endEdit() {
        if let cell = host?.getCell(self) as? TextViewCell {
            cell.textView.resignFirstResponder()
        }
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        guard let tableView else { return }
        guard let cell = textView.superview?.superview as? TextViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        
        isTextViewEditing = true
        textViewHeight(for: cell, at: indexPath)
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        guard let tableView else { return }
        guard let cell = textView.superview?.superview as? TextViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        
        isTextViewEditing = false
        textViewHeight(for: cell, at: indexPath)
        tableView.beginUpdates()
        tableView.endUpdates()
        
        setValue(withConverted: textView.text)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        guard let tableView else { return }
        guard let cell = textView.superview?.superview as? TextViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        
        if let placeholderLabel = textView.subviews.first(where: { $0 is UILabel }) as? UILabel {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
        
        if maxHeight == nil {
            maxHeight = numberOfLines > 0 ? calculateMaxHeight(for: textView, numberOfLines: numberOfLines) : nil
        }
        textViewHeight(for: cell, at: indexPath)
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" { return true }
        return true
    }
    
    private func calculateMaxHeight(for textView: UITextView, numberOfLines: Int) -> CGFloat {
        let font = textView.font ?? UIFont.preferredFont(forTextStyle: .body)
        let lineHeight = font.lineHeight
        var lineSpacing: CGFloat = 0
        if let attributedText = textView.attributedText, attributedText.length > 0,
           let paragraphStyle = attributedText.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
            lineSpacing = paragraphStyle.lineSpacing
        }
        
        let textContainerInset = textView.textContainerInset
        let verticalInset = textContainerInset.top + textContainerInset.bottom
        let cellVerticalPadding: CGFloat = 16.0 // 与 TextViewCell 约束一致
        let extraBuffer: CGFloat = 4.0
        return (lineHeight + lineSpacing) * CGFloat(numberOfLines) + verticalInset + cellVerticalPadding + extraBuffer
    }
    
    public func textViewHeight(for cell: TextViewCell, at indexPath: IndexPath) {
        guard let tableView else { return }
        
        let width = tableView.bounds.width - 16
        let contentHeight = cell.textView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height
        cell.textView.isScrollEnabled = maxHeight != nil && contentHeight > maxHeight! - 16
        
        let targetHeight = isTextViewEditing ? max(contentHeight + 16, enlargedHeight ?? contentHeight + 16) : contentHeight + 16
        height = maxHeight != nil ? min(maxHeight!, max(minHeight, targetHeight)) : max(minHeight, targetHeight)
    }
}
