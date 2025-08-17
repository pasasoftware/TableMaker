//
//  MultiSelectorItem.swift
//  TableMaker
//
//  Created by GitHub Copilot on 2025/8/17.
//  Copyright © 2025 Andrew Chai. All rights reserved.
//

import Foundation
import UIKit

// A default converter for arrays of CustomStringConvertible to String
open class ArrayStringConverter<U: CustomStringConvertible>: Converter<[U], String> {
    public var separator: String
    
    public init(separator: String = ", ") {
        self.separator = separator
        super.init()
    }
    
    open override func convert(_ value: [U]) -> String {
        return value.map { $0.description }.joined(separator: separator)
    }
    
    open override func convertBack(_ value: String) -> [U]? {
        // This is typically not needed for display-only converters
        return nil
    }
}

open class MultiSelectorItem<T, U: Equatable & CustomStringConvertible, V: CustomStringConvertible & Equatable>: DataTableItem<T, [U], V> {

    // MARK: - Property
    open override var identifier: String {
        return "multiSelectorCellReuseId"
    }
    
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
    public init(_ data: T, host: TableItemHost, values: [U], getter: @escaping (T) -> [U]) {
        self.values = values
        super.init(data, getter: getter)
        self.host = host
        
        // Set up default converter if V is String
//        if V.self == String.self {
//            self.converter = ArrayStringConverter<U>() as? Converter<[U], V>
//        }
    }

    // MARK: - Override
    open override func createCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        cell.selectionStyle = .default
        cell.accessoryType = accessoryType
        return cell
    }
    
    open override func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath) {
        super.setup(tableView, cell: cell, at: indexPath)
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = getDescription()
    }
    
    open override func select(_ tableView: UITableView, at indexPath: IndexPath) {
        // For MultiSelector, we always push to a new view controller
        // to handle multiple selections.
        if let vc = createMultiSelectorViewController() {
            showPush(vc)
        }
    }
    
    private func createMultiSelectorViewController() -> UIViewController? {
        let vc = MultiSelectorViewController<T, U, V>(style: .grouped)
        vc.item = self
        return vc
    }
    
    private func showPush(_ controller: UIViewController) {
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
}

//Todo MultiSelectorItem2 should be MultiSelectorItem, but swift don't support it
public typealias MultiSelectorItem2<T, U: Equatable & CustomStringConvertible> = MultiSelectorItem<T, U, String>
