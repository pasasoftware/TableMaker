//
//  ImageItem.swift
//  TableMaker
//
//  Created by pasasoft_mini on 2018/5/10.
//  Copyright © 2018年 Andrew Chai. All rights reserved.
//

import UIKit
import Foundation

public class ImageCell: UITableViewCell{
    
    public init(reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        imageView?.layer.masksToBounds = true
        imageView?.layer.cornerRadius = 5.0
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let height = contentView.layoutMarginsGuide.layoutFrame.height
        //iphone x lanscape frame.right != frame.width
        imageView!.frame = CGRect(x: contentView.frame.width - height, y: contentView.layoutMarginsGuide.layoutFrame.y, width: height, height: height)
        textLabel!.frame = CGRect(x: contentView.layoutMarginsGuide.layoutFrame.x, y: 0, width: imageView!.frame.left - viewSpacing - contentView.layoutMarginsGuide.layoutFrame.x, height: contentView.frame.height)
        separatorInset = UIEdgeInsets.init(top: 0, left: contentView.layoutMarginsGuide.layoutFrame.x, bottom: 0, right: 0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
}

public class ImageItem<T, U: Equatable>: DataTableItem<T,U,UIImage>{
//    public var image:UIImage!

    public override var identifier: String {
        return "ImageCellReuseId"
    }
    
    public override var accessoryType: UITableViewCell.AccessoryType {
        return .disclosureIndicator
    }
    
    public override var autoReload: Bool{
        return true
    }
    
    public override func createCell() -> UITableViewCell {
        let cell = ImageCell(reuseIdentifier: identifier)
        return cell
    }
    
    public override func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath) {
        super.setup(tableView, cell: cell, at: indexPath)
        let cell = cell as! ImageCell
        cell.imageView?.image = convertValue()
        cell.textLabel?.setLabelWithRequiredMark(title, isRequire: isRequire)
    }
    
    public override func select(_ tableView: UITableView, at indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ImageViewController()
        vc.title = title
        vc.image = convertValue()
        vc.chooseAction = {
            self.setValue(withConverted: $0)
        }
        guard let host = host else {
            return
        }
        if let nav = host.viewController.navigationController {
            nav.pushViewController(vc, animated: true)
        }else{
            let nav = UINavigationController.init(rootViewController: vc)
            host.viewController.present(nav, animated: true, completion: nil)
        }
        
    }
    
}
