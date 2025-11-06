//
//  SelectableExtension.swift
//  TableMaker
//
//  Created by pasasoft on 2018/6/1.
//  Copyright © 2018年 Andrew Chai. All rights reserved.
//

import Foundation
import UIKit

public protocol Selectable where Self: TableItem {

    associatedtype T
    associatedtype U: Equatable
    associatedtype V

    var values: [U] { get }
    var tableViewStyle: UITableView.Style { get }

    // Show as action sheet
    func showActionSheetWith(sourceView: UIView?, rect: CGRect, dataTableItem: DataTableItem<T, U, V>)
    func showPush(_ controller: UIViewController, dataTableItem: DataTableItem<T, U, V>)
    func showPopover(_ controller: UIViewController, sourceView: UIView, rect: CGRect, dataTableItem: DataTableItem<T, U, V>)
    func createSelectorViewControlelr(dataTableItem: DataTableItem<T, U, V>) -> SelectorViewController<U>?
}

extension Selectable {

    // MARK: - Show Selector

    // Show as action sheet
    public func showActionSheetWith(sourceView: UIView?, rect: CGRect, dataTableItem: DataTableItem<T, U, V>) {
        // Options are nil or host not 'UIViewController' and return directly
        guard let vc = dataTableItem.host?.viewController else {
                return
        }

        // Create alert
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)

        // Adapt iPad.
        // AlertController need to set popoverPresentationController's souceview and source rect.
        if let sourceView = sourceView {
            alert.popoverPresentationController?.sourceView = sourceView
            alert.popoverPresentationController?.sourceRect = rect
        }

        // Add action to alert
        alert.addAction(UIAlertAction(title: Localizable.Cancel.localized, style: .cancel, handler: nil))
        for item in values {
            alert.addAction(UIAlertAction(title: dataTableItem.getDescription(with: item), style: .default){ _ in
                dataTableItem.setValue(with: item)
            })
        }

        // Present alert controller
        vc.present(alert, animated: true, completion: nil)
    }

    public func showPush(_ controller: UIViewController, dataTableItem: DataTableItem<T, U, V>) {
        // Get source controlelr
        let sourceVC = dataTableItem.host?.viewController

        // SourceVC and sourceVC.navigationController is not nil and push directly
        if  let sourceVC = sourceVC,
            let nav = sourceVC.navigationController {
            nav.pushViewController(controller, animated: true)
        } else if let sourceVC = sourceVC { // If sourceVC is not nil then try present controller

            // Create done button
            let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dataTableItem.dismissController))

            // Set navigationItem
            controller.navigationItem.rightBarButtonItem = doneBarButton

            // Create navigationController
            let naviController = UINavigationController(rootViewController: controller)

            // Present
            sourceVC.present(naviController, animated: true, completion: nil)
        }
    }

    public func showPopover(_ controller: UIViewController, sourceView: UIView, rect: CGRect, dataTableItem: DataTableItem<T, U, V>) {

        // Sorce controlelr is nil then return directly
        guard let source =  dataTableItem.host?.viewController else { return }

        // Create navigationController
        let nav = UINavigationController(rootViewController: controller)

        // Set navigationController popover related
        nav.modalPresentationStyle = .popover
        if let popover = nav.popoverPresentationController {
            popover.delegate = dataTableItem

            popover.sourceView = sourceView
            popover.sourceRect = rect
            popover.permittedArrowDirections = .any
        }
        // Present
        source.present(nav, animated: true, completion: nil)
    }


    public func createSelectorViewControlelr(dataTableItem: DataTableItem<T, U, V>) -> SelectorViewController<U>? {

        // Create selector view controller
        let selectorVC = SelectorViewController<U>(style: tableViewStyle)

        // Set title
        selectorVC.title = title

        // Set datasource
        selectorVC.datas = values

        // Set formatter
        selectorVC.formatter = dataTableItem.getDescription(with:)

        // Set selectedValue
        selectorVC.selectedValues = [dataTableItem.getValue()]

        // Set call back: Set value to 'T' when selctor VC disappear
        selectorVC.disappearing = { (value) in
            if let value = value?.first {
                dataTableItem.setValue(with: value)
            }
        }
        return selectorVC
    }
}
