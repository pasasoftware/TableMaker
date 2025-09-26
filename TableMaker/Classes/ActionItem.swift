//
//  ActionItem.swift
//  TableMaker
//
//  Created by Andrew Tsai on 2018/4/26.
//  Copyright © 2018 Pasasoft. All rights reserved.
//

import Foundation
import UIKit

//action should weak reference
public class ActionItem: TableItem {
    public var action: ((ActionItem, IndexPath) -> Void)?
    public var image: UIImage?
    public override var identifier: String {
        return "actionCellReuseId"
    }
    
    public override var accessoryType: UITableViewCell.AccessoryType {
        return .disclosureIndicator
    }

    // MARK: - Constructor
    public convenience init(title: String?, action: @escaping () -> Void) {
        self.init(title: title, image: nil, action: { _,_ in action()})
    }

    public init(title: String?, image: UIImage?, action: @escaping (ActionItem, IndexPath) -> Void) {
        super.init()
        self.title = title
        self.image = image
        self.action = action
    }

    // MARK: - Override
    public override func createCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        return cell
    }

    public override func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath) {
        super.setup(tableView, cell: cell, at: indexPath)
        cell.textLabel?.text = title
        cell.imageView?.image = image
    }

    public override func select(_ tableView: UITableView, at indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        action?(self, indexPath)
    }
}
