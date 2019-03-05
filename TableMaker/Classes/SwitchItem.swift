//
//  SwitchItem.swift
//  TableMaker
//
//  Created by pasasoft_mini on 2018/5/2.
//  Copyright © 2018年 Andrew Chai. All rights reserved.
//

import UIKit
import Foundation

public class SwitchCell: UITableViewCell{
    let switchControl: UISwitch!
    public init(reuseIdentifier: String?) {
        switchControl = UISwitch()
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        accessoryView = switchControl
        selectionStyle = .none
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    public override func prepareForReuse() {
        switchControl.removeTarget(nil, action: nil, for: .allEvents)
    }
}

public class SwitchItem<T, U: Equatable & CustomStringConvertible>: DataTableItem<T,U,Bool> {
    
    public override var identifier: String {
        return "switchCellReuseId"
    }
    
    public override var autoReload: Bool{
        return false
    }
    
    public override func createCell() -> UITableViewCell {
        return SwitchCell(reuseIdentifier: identifier)
    }
    
    public override func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath) {
        super.setup(tableView, cell: cell, at: indexPath)
        let cell = cell as! SwitchCell
        cell.textLabel?.text = title
        let switchControl = cell.switchControl!
        switchControl.isOn = convertValue()
        switchControl.addTarget(self, action: #selector(switchSelectionChanged), for: .valueChanged)
    }
    
    @objc func switchSelectionChanged(_ obj: Any?){
        guard let switchControl = obj as? UISwitch else {
            return
        }
        setValue(withConverted: switchControl.isOn)
    }
}


