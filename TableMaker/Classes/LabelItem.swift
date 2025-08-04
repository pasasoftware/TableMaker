//
//  LabelItem.swift
//  TableMaker
//
//  Created by Andrew Chai on 4/25/18.
//  Copyright © 2018 Andrew Chai. All rights reserved.
//

import UIKit
import Foundation

open class LabelItem<T, U: Equatable & CustomStringConvertible, V: CustomStringConvertible>: DataTableItem<T,U,V>{
    
    public var textFont: UIFont?
    public var detailTextFont: UIFont?
    
    open override var identifier: String {
        return "labelCellReuseId"
    }
    
//    public override init(_ data: T, getter: @escaping (T) -> U) {
//        super.init(data, getter: getter)
//    }
    
    open override func createCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        cell.selectionStyle = .none
        cell.accessoryType = accessoryType
        if let textFont = textFont {
            cell.textLabel?.font = textFont
        }
        
        if let detailTextFont = detailTextFont {
            cell.detailTextLabel?.font = detailTextFont
        }
        return cell
    }
    
    open override func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath) {
        super.setup(tableView, cell: cell, at: indexPath)
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = getDescription()
    }
}

//todo LabelItem2 should be LabelItem, but swift don't support it
public typealias LabelItem2<T,U: Equatable & CustomStringConvertible> = LabelItem<T,U,U>

