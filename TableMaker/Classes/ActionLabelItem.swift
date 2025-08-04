//
//  ActionLabelItem.swift
//  TableMaker
//
//  Created by YongJie Zhang on 2019/3/15.
//  Copyright © 2019年 Pasasoft. All rights reserved.
//

import Foundation
import UIKit

open class ActionLabelItem<T, U: Equatable & CustomStringConvertible, V: CustomStringConvertible>: LabelItem<T,U,V>
{
    open override var identifier: String {
        return "actionLabelCellReuseId"
    }
    public var action:((ActionLabelItem<T, U, V>)->Void)?
    
    open override var accessoryType: UITableViewCell.AccessoryType {
        set{
            customAccessoryType = newValue
        }
        get{
            return customAccessoryType
        }
    }
    
    private var customAccessoryType: UITableViewCell.AccessoryType = .none
    
    open override func select(_ tableView: UITableView, at indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        action?(self)
    }
    
}

public typealias ActionLabelItem2<T,U: Equatable & CustomStringConvertible> = ActionLabelItem<T,U,U>
