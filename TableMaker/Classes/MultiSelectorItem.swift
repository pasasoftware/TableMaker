//
//  MultiSelectorItem.swift
//  TableMaker
//
//  Created by GitHub Copilot on 2025/8/17.
//  Copyright © 2025 Andrew Chai. All rights reserved.
//

import Foundation
import UIKit

open class MultiSelectorItem<T, U: Equatable & CustomStringConvertible, V: CustomStringConvertible & Equatable>: LabelItem<T, [U], V>, Selectable {

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
    public init(_ data: T, host: TableItemHost, values: [U], getter: @escaping (T) -> [U]) {
        self.values = values
        super.init(data, getter: getter)
        self.host = host
    }

    // MARK: - Override
    open override func select(_ tableView: UITableView, at indexPath: IndexPath) {
        // For MultiSelector, we always push to a new view controller
        // to handle multiple selections.
        
        let sourceVC = self.host?.viewController

        if let vc = createMultiSelectorViewController() {
            if  let sourceVC = sourceVC,
                let nav = sourceVC.navigationController {
                nav.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func createMultiSelectorViewController() -> UIViewController? {
        let vc = MultiSelectorViewController<T, U, V>(style: .grouped)
        vc.item = self
        return vc
    }
    
        return value.map { $0.description }.joined(separator: ", ")
    }
}

// Conforming Array to CustomStringConvertible for display purposes
//extension Array: CustomStringConvertible where Element: CustomStringConvertible {
//    public var description: String {
//        return self.map { $0.description }.joined(separator: ", ")
//    }
//}
