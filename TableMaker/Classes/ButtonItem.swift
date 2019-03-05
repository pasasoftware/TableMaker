//
//  ButtonItem.swift
//  TableMaker
//
//  Created by Andrew on 2018/4/25.
//  Copyright © 2018 Andrew Chai. All rights reserved.
//

import UIKit
import Foundation

public class ButtonCell: UITableViewCell {
    let button: UIButton!
    
    public init(reuseIdentifier: String?) {
        button = UIButton(type: .custom)
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(button)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    public override func layoutSubviews() {
        button.frame = contentView.bounds
    }
    
    public override func prepareForReuse() {
        button.removeTarget(nil, action: nil, for: .allEvents)
    }
}

//action should weak reference
public class ButtonItem: TableItem {
    public var titleColor = UIColor.darkText
    
    public var action: (() -> Void)?
    
    public init(title: String?, action: @escaping () -> Void) {
        super.init()
        self.title = title
        self.action = action
    }
    
    public override var identifier: String {
        return "buttonCellReuseId"
    }
    
    public override func createCell() -> UITableViewCell {
        let cell = ButtonCell(reuseIdentifier: identifier)
        cell.selectionStyle = .none
        return cell
    }
    
    public override func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath) {
        super.setup(tableView, cell: cell, at: indexPath)
        let cell = cell as! ButtonCell
        
        let button = cell.button!
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    
    @objc func buttonTapped() {
        if let action = action {
            action()
        }
    }
}
