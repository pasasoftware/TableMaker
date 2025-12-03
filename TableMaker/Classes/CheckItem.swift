//
//  CheckItem.swift
//  TableMaker
//
//  Created by pasasoft_mini on 2018/5/3.
//  Copyright © 2018年 Andrew Chai. All rights reserved.
//

import UIKit
import Foundation

open class CheckItem<T, U: Equatable>: DataTableItem<T,U,Bool> {
    
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
        cell.textLabel?.setLabelWithRequiredMark(title, isRequire: isRequire)
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



