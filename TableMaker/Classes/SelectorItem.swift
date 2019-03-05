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

open class SelectorItem<T, U: Equatable & CustomStringConvertible, V: CustomStringConvertible & Equatable>: LabelItem<T, U, V>, Selectable {

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
            showActionSheetWith(sourceView: getSourceView(tableView: tableView, indexPath: indexPath), dataTableItem: self)
        case .push:
            if let vc = createSelectorViewControlelr(dataTableItem: self) {
                showPush(vc, dataTableItem: self)
            }
        case .popover:
            if let vc = createSelectorViewControlelr(dataTableItem: self) {
                showPopover(vc, sourceView: getSourceView(tableView: tableView, indexPath: indexPath), dataTableItem: self)
            }
        }
    }
}

extension SelectorItem {

    // MARK: - Utils
    private func getSourceView(tableView: UITableView, indexPath: IndexPath) -> UIView? {
        let cell = tableView.cellForRow(at: indexPath)
        return cell?.detailTextLabel
    }
}

//Todo SelectorItem2 should be SelectorItem, but swift don't support it
public typealias SelectorItem2<T, U: Equatable & CustomStringConvertible> = SelectorItem<T, U, U>
