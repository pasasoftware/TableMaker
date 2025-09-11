//
//  ComboItem.swift
//  TableMaker
//
//  Created by pasasoft on 2018/5/22.
//  Copyright © 2018年 Andrew Chai. All rights reserved.
//

import Foundation
import UIKit

open class ComboItem<T, U: Equatable>: TextFieldItem<T,U> {
    
    public typealias V = String?
    
    // MARK: - Property
    override open var accessoryType: UITableViewCell.AccessoryType {
        return .detailButton
    }
    
    /// As datasource of options.
    public var values: [U]
    
    /// Determine the style of options, default is "Push".
    public var style = SelectorItemStyle.push
    
    /// UITableView.Style the style of options, default is "plain".
    public var tableViewStyle: UITableView.Style = .plain
    
    // MARK: - Constructor
    public init(_ data: T, host: TableItemHost, values: [U], getter: @escaping (T) -> U) {
        self.values = values
        super.init(data, host: host, getter: getter)
    }
    
    // MARK: - Override
    open override func accessoryButtonTapped(_ tableView: UITableView, at indexPath: IndexPath) {
        // Different behaviors based on style
        switch style {
        case .actionSheet:
            showActionSheetWith(sourceView: getSourceView(tableView: tableView, indexPath: indexPath))
//            showActionSheetWith(sourceView: getSourceView(tableView: tableView, indexPath: indexPath), dataTableItem: self)
        case .push:
            if let vc = createSelectorViewControlelr() {
                showPush(vc)
            }
        case .popover:
            if let vc = createSelectorViewControlelr() {
                showPopover(vc, sourceView: getSourceView(tableView: tableView, indexPath: indexPath))
            }
        }
    }
}

extension ComboItem {
    // MARK: - Show Selector

    // Show as action sheet
    public func showActionSheetWith(sourceView: UIView?) {
        // Options are nil or host not 'UIViewController' and return directly
        guard let vc = host?.viewController else {
            return
        }

        // Create alert
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)

        // Adapt iPad.
        // AlertController need to set popoverPresentationController's souceview and source rect.
        if let sourceView = sourceView {
            alert.popoverPresentationController?.sourceView = sourceView
            alert.popoverPresentationController?.sourceRect = sourceView.bounds
        }

        // Add action to alert
        alert.addAction(UIAlertAction(title: Localizable.Cancel.localized, style: .cancel, handler: nil))
        for item in values {
            alert.addAction(UIAlertAction(title: getDescription(with: item), style: .default){[weak self] _ in
                self?.setValue(with: item)
            })
        }

        // Present alert controller
        vc.present(alert, animated: true, completion: nil)
    }

    public func showPush(_ controller: UIViewController) {
        // Get source controlelr
        let sourceVC = host?.viewController

        // SourceVC and sourceVC.navigationController is not nil and push directly
        if  let sourceVC = sourceVC,
            let nav = sourceVC.navigationController {
            nav.pushViewController(controller, animated: true)
        } else if let sourceVC = sourceVC { // If sourceVC is not nil then try present controller

            // Create done button
            let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissController))

            // Set navigationItem
            controller.navigationItem.rightBarButtonItem = doneBarButton

            // Create navigationController
            let naviController = UINavigationController(rootViewController: controller)

            // Present
            sourceVC.present(naviController, animated: true, completion: nil)
        }
    }

    public func showPopover(_ controller: UIViewController, sourceView: UIView?) {

        // Sorce controlelr is nil then return directly
        guard let source =  host?.viewController else { return }

        // Create navigationController
        let nav = UINavigationController(rootViewController: controller)

        // Set navigationController popover related
        nav.modalPresentationStyle = .popover
        let popover = nav.popoverPresentationController
        popover?.delegate = self
        if let sourceView = sourceView {
            // Set sourceView and source rect
            popover?.sourceView = sourceView
            popover?.sourceRect = sourceView.bounds

            // Present
            source.present(nav, animated: true, completion: nil)
        }
    }


    public func createSelectorViewControlelr() -> SelectorViewController<U>? {

        // Create selector view controller
        let selectorVC = SelectorViewController<U>(style: tableViewStyle)

        // Set title
        selectorVC.title = title

        // Set datasource
        selectorVC.datas = values

        // Set formatter
        selectorVC.formatter = getDescription(with:)

        // Set selectedValue
        selectorVC.selectedValues = [getValue()]

        // Set call back: Set value to 'T' when selctor VC disappear
        selectorVC.disappearing = {[weak self] (value) in
            if let value = value?.first {
                self?.setValue(with: value)
            }
        }
        return selectorVC
    }
    
}

extension ComboItem {
    
    // MARK: - Util
    
    private func getSourceView(tableView: UITableView, indexPath: IndexPath) -> UIView? {
        if let cell = tableView.cellForRow(at: indexPath) {
            return getSystemDetailButtonWith(cell)
        }
        return nil
    }
    
    private func getSystemDetailButtonWith(_ cell: UITableViewCell) -> UIView? {
        return  cell.subviews.first(){ $0 is UIButton }
    }
}



