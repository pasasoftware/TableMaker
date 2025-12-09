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
        super.prepareForReuse()
        textView.delegate = nil
        textView.text = ""
        textView.isScrollEnabled = true
        textView.setContentOffset(CGPoint.zero, animated: false)
        
        // 重置 placeholder 状态
        if let placeholderLabel = textView.subviews.first(where: { $0 is UILabel }) as? UILabel {
            placeholderLabel.isHidden = false
        }
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
        label.setLabelWithRequiredMark(placeholder, isRequire: isRequire)
        cell.textView.text = convertValue()
        cell.textView.delegate = self
        
        // 先设置高度，再检查是否需要滚动
        textViewHeight(for: cell, at: indexPath)
        
        // 修复刷新后滚动问题：确保在下一个 runloop 中更新滚动状态
        DispatchQueue.main.async {
            // 重置 TextView 的内部状态
            cell.textView.setNeedsLayout()
            cell.textView.layoutIfNeeded()
            
            // 更新滚动状态
            self.updateScrollState(for: cell)
            
            // 确保 contentOffset 正确
            if cell.textView.isScrollEnabled && cell.textView.contentSize.height > cell.textView.bounds.height {
                cell.textView.setContentOffset(CGPoint.zero, animated: false)
            }
        }
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
        
        // 保存当前光标位置
        let selectedRange = textView.selectedRange
        
        textViewHeight(for: cell, at: indexPath)
        tableView.beginUpdates()
        tableView.endUpdates()
        
        // 恢复光标位置
        textView.selectedRange = selectedRange
        
        // 滚动到光标位置，确保光标可见
        DispatchQueue.main.async {
            if textView.isFirstResponder {
                textView.scrollRangeToVisible(selectedRange)
            }
        }
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
        
        // 更精确的高度计算，确保不会有内容漏出
        let totalLineHeight = lineHeight * CGFloat(numberOfLines)
        let totalLineSpacing = lineSpacing * max(0, CGFloat(numberOfLines - 1))
        
        return totalLineHeight + totalLineSpacing + verticalInset + cellVerticalPadding
    }
    
    public func textViewHeight(for cell: TextViewCell, at indexPath: IndexPath) {
        guard let tableView else { return }
        
        let width = tableView.bounds.width - 16
        let contentHeight = cell.textView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height
        let cellVerticalPadding: CGFloat = 16.0
        
        // 确定实际使用的最大高度
        var effectiveMaxHeight: CGFloat?
        if let userMaxHeight = maxHeight {
            // 优先使用外部设置的 maxHeight
            effectiveMaxHeight = userMaxHeight
        } else if numberOfLines > 0 {
            // 当 maxHeight 为 nil 且 numberOfLines > 0 时，计算最大高度
            effectiveMaxHeight = calculateMaxHeight(for: cell.textView, numberOfLines: numberOfLines)
        }
        // 如果 maxHeight 为 nil 且 numberOfLines = 0，则不限制高度
        
        // 临时启用滚动以确保 contentSize 正确计算
        cell.textView.isScrollEnabled = true
        
        let targetHeight = isTextViewEditing ? max(contentHeight + cellVerticalPadding, enlargedHeight ?? contentHeight + cellVerticalPadding) : contentHeight + cellVerticalPadding
        height = effectiveMaxHeight != nil ? min(effectiveMaxHeight!, max(minHeight, targetHeight)) : max(minHeight, targetHeight)
        
        // 立即更新滚动状态，避免延迟
        updateScrollState(for: cell)
    }
    
    private func updateScrollState(for cell: TextViewCell) {
        // 确定实际使用的最大高度
        var effectiveMaxHeight: CGFloat?
        if let userMaxHeight = maxHeight {
            // 优先使用外部设置的 maxHeight
            effectiveMaxHeight = userMaxHeight
        } else if numberOfLines > 0 {
            // 当 maxHeight 为 nil 且 numberOfLines > 0 时，计算最大高度
            effectiveMaxHeight = calculateMaxHeight(for: cell.textView, numberOfLines: numberOfLines)
        }
        
        guard let effectiveMaxHeight = effectiveMaxHeight else {
            cell.textView.isScrollEnabled = false
            return
        }
        
        let cellVerticalPadding: CGFloat = 16.0
        let width = cell.textView.bounds.width
        let contentHeight = cell.textView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height
        let maxContentHeight = effectiveMaxHeight - cellVerticalPadding
        
        // 判断是否需要滚动
        let needsScrolling = contentHeight > maxContentHeight
        cell.textView.isScrollEnabled = needsScrolling
        
        if needsScrolling {
            // 强制刷新 TextView 的布局和 contentSize
            cell.textView.setNeedsLayout()
            cell.textView.layoutIfNeeded()
            
            // 确保 contentSize 被正确计算
            let textContainer = cell.textView.textContainer
            let layoutManager = cell.textView.layoutManager
            
            // 强制重新计算文本布局
            let textRange = NSRange(location: 0, length: cell.textView.text.count)
            layoutManager.invalidateLayout(forCharacterRange: textRange, actualCharacterRange: nil)
            layoutManager.ensureLayout(for: textContainer)
            
            // 重新计算 contentSize
            let usedRect = layoutManager.usedRect(for: textContainer)
            let insets = cell.textView.textContainerInset
            let newContentSize = CGSize(width: usedRect.width + insets.left + insets.right,
                                      height: usedRect.height + insets.top + insets.bottom)
            
            // 手动设置 contentSize 确保滚动正常工作
            if newContentSize.height != cell.textView.contentSize.height {
                cell.textView.contentSize = newContentSize
            }
            
            // 只在非编辑状态或初始化时滚动到顶部
            if !cell.textView.isFirstResponder && cell.textView.contentSize.height > cell.textView.bounds.height {
                cell.textView.setContentOffset(CGPoint.zero, animated: false)
            }
        } else {
            // 不需要滚动时，确保 contentOffset 为零（仅在非编辑状态）
            if !cell.textView.isFirstResponder {
                cell.textView.setContentOffset(CGPoint.zero, animated: false)
            }
        }
    }
}
