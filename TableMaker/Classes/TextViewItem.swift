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

open class TextViewItem<T, U: Equatable>: DataTableItem<T,U,String?>, UITextViewDelegate{
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

