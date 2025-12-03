//
//  TweakLabelItem.swift
//  TableMaker
//
//  Created by pasasoft on 2018/5/9.
//  Copyright © 2018年 Andrew Chai. All rights reserved.
//

import Foundation
import UIKit

//let TweakLabelMargin: CGFloat = 5.0

open class TweakLabelItem<T, U: Equatable, V>: DataTableItem<T, U, V> {
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

        guard let cell = cell as? TweakLabelCell else { return }
        cell.configData(title, detail: getDescription(), isRequire: isRequire)
    }
}

//todo TweakLabelItem2 should be TweakLabelItem, but swift don't support it
public typealias TweakLabelItem2<T, U: Equatable> = TweakLabelItem<T, U, U>

open class TweakLabelCell: UITableViewCell {

    // MARK: - Property
    // Constraints
    private var textLeadingEmptyTitle: NSLayoutConstraint!
    private var textLeading: NSLayoutConstraint!

    private var textYEmptyTitle: NSLayoutConstraint!
    private var textY: NSLayoutConstraint!

    // MARK: - Constructor
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Set multiple line
        detailTextLabel?.lineBreakMode = .byWordWrapping
        detailTextLabel?.numberOfLines = 0
        detailTextLabel?.textAlignment = .left

        // Set autolayout and textLabel CHCR
        textLabel!.translatesAutoresizingMaskIntoConstraints = false
        detailTextLabel!.translatesAutoresizingMaskIntoConstraints = false
        textLabel!.setContentHuggingPriority(UILayoutPriority(rawValue: 300), for: .horizontal)
        textLabel!.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 999), for: .horizontal)

        // Add constraint
        let margin = contentView.layoutMarginsGuide

        NSLayoutConstraint.activate([
            textLabel!.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            textLabel!.topAnchor.constraint(equalTo: margin.topAnchor)
            ])

        textLeadingEmptyTitle = detailTextLabel!.leadingAnchor.constraint(equalTo: margin.leadingAnchor)
        textLeading = detailTextLabel!.leadingAnchor.constraint(equalTo: textLabel!.trailingAnchor, constant: 8)

        textYEmptyTitle = detailTextLabel!.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        textY = detailTextLabel!.firstBaselineAnchor.constraint(equalTo: textLabel!.firstBaselineAnchor)

        NSLayoutConstraint.activate([
            detailTextLabel!.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            detailTextLabel!.bottomAnchor.constraint(equalTo: margin.bottomAnchor),
            ])
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configData(_ title: String?, detail: String?, isRequire: Bool = false) {
        textLabel?.setLabelWithRequiredMark(title, isRequire: isRequire)
        detailTextLabel?.text = detail
        if title?.isEmpty == false {
            textLabel?.isHidden = false
            NSLayoutConstraint.deactivate([textLeadingEmptyTitle, textYEmptyTitle])
            NSLayoutConstraint.activate([textLeading,textY])
        } else {
            textLabel?.isHidden = true
            NSLayoutConstraint.deactivate([textLeading,textY])
            NSLayoutConstraint.activate([textLeadingEmptyTitle, textYEmptyTitle])
        }
    }
}

