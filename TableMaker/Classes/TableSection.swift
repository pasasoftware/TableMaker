//
//  DetailSection.swift
//  TableMaker
//
//  Created by Andrew Chai on 4/25/18.
//  Copyright © 2018 Andrew Chai. All rights reserved.
//

import Foundation
import UIKit

open class TableSection {
    public var header: String?
    public var footer: String?
    public var headerView: UIView?
    public var footerView: UIView?
    public var headerHeight: CGFloat?
    public var footerHeight: CGFloat?
    
    public var items = [TableItem]()
    
    public init(_ items: [TableItem]){
        self.items = items
    }
    
    public func firstFailedItem() -> Failable?{
        return items.first(where: { (tableItem) -> Bool in
            if let failable = tableItem as? Failable{
                return failable.isFailed
            }
            return false
            }) as? Failable
    }
    
    public func removeItem(item: TableItem){
        if let index = items.firstIndex(where: {$0 === item}) {
            items.remove(at: index)
        }
    }
}
