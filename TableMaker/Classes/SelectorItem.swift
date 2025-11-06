//
//  SelectorItem.swift
//  TableMaker
//
//  Created by pasasoft on 2018/5/14.
//  Copyright © 2018年 Andrew Chai. All rights reserved.
//

import Foundation
import UIKit

// An enumeration type about the SelectorItem style
public enum SelectorItemStyle {
    case push
    case actionSheet
    case popover
}

open class SelectorItem<T, U: Equatable, V>: LabelItem<T, U, V>, Selectable {

    // MARK: - Property
    open override var accessoryType: UITableViewCell.AccessoryType {
        return .disclosureIndicator
    }

    open override var autoReload: Bool {
        return true
    }

    /// As datasource of options.
    public var values: [U]

    /// Determine the style of options, default is "Push".
    public var style = SelectorItemStyle.push
    
    /// UITableView.Style the style of options, default is "plain".
    public var tableViewStyle: UITableView.Style = .plain

    // MARK: - Constructor
    public init(_ data: T, host: TableItemHost, values: [U], getter: @escaping (T) -> U) {
        self.values = values
        super.init(data, getter: getter)
        self.host = host
    }

    // MARK: - Override
    open override func select(_ tableView: UITableView, at indexPath: IndexPath) {

        // Different behaviors based on style
        switch style {
        case .actionSheet:
            if let (sourceView, bounds) = getSourceView(tableView: tableView, indexPath: indexPath) {
                showActionSheetWith(sourceView: sourceView, rect: bounds, dataTableItem: self)
            }
//
        case .push:
            if let vc = createSelectorViewControlelr(dataTableItem: self) {
                showPush(vc, dataTableItem: self)
            }
        case .popover:
            if let vc = createSelectorViewControlelr(dataTableItem: self), let (sourceView, bounds) = getSourceView(tableView: tableView, indexPath: indexPath) {
                showPopover(vc, sourceView: sourceView, rect: bounds, dataTableItem: self)
            }
        }
    }
}

extension SelectorItem {

    // MARK: - Utils
    private func getSourceView(tableView: UITableView, indexPath: IndexPath) -> (UIView, CGRect)? {
        guard let cell = tableView.cellForRow(at: indexPath), let label = cell.detailTextLabel else { return nil }

        if let text = label.text, !text.isEmpty {
            return (label, label.bounds)
        } else {
            let rect = CGRect(x: cell.contentView.bounds.maxX - 10,
                                   y: cell.contentView.bounds.midY - 8,
                                   width: 16, height: 16)
            return (cell, rect)
        }
    }
}

//Todo SelectorItem2 should be SelectorItem, but swift don't support it
public typealias SelectorItem2<T, U: Equatable> = SelectorItem<T, U, U>
