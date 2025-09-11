//
//  MultiSelectorItem.swift
//  TableMaker
//
//  Created by ZhangTeng on 2025/8/27.
//

import UIKit

// An enumeration type about the SelectorItem style
public enum MultiSelectorItemStyle {
    case push
    case popover
}

open class MultiSelectorItem<T, U: Equatable, V>: LabelItem<T, [U], [V]> {

    // MARK: - Property
    open override var accessoryType: UITableViewCell.AccessoryType {
        return .disclosureIndicator
    }

    open override var autoReload: Bool {
        return true
    }

    /// As datasource of options.
    public var values: [U]
    
    /// As formatter of options.
    public var optionFormatter: ((U) -> String?)?

    /// Determine the style of options, default is "Push".
    public var style = MultiSelectorItemStyle.push
    
    /// UITableView.Style the style of options, default is "plain".
    public var tableViewStyle: UITableView.Style = .plain

    // MARK: - Constructor
    public init(_ data: T, host: TableItemHost, values: [U], getter: @escaping (T) -> [U]) {
        self.values = values
        super.init(data, getter: getter)
        self.host = host
    }

    // MARK: - Override
    open override func select(_ tableView: UITableView, at indexPath: IndexPath) {

        // Different behaviors based on style
        switch style {
        case .push:
            if let vc = createSelectorViewControlelr(dataTableItem: self) {
                showPush(vc, dataTableItem: self)
            }
        case .popover:
            if let vc = createSelectorViewControlelr(dataTableItem: self) {
                showPopover(vc, sourceView: getSourceView(tableView: tableView, indexPath: indexPath), dataTableItem: self)
            }
        }
    }
}

extension MultiSelectorItem {

    // MARK: - Utils
    private func getSourceView(tableView: UITableView, indexPath: IndexPath) -> UIView? {
        let cell = tableView.cellForRow(at: indexPath)
        return cell?.detailTextLabel
    }
}

extension MultiSelectorItem {
    
    public func showPush(_ controller: UIViewController, dataTableItem: DataTableItem<T, [U], [V]>) {
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

    public func showPopover(_ controller: UIViewController, sourceView: UIView?, dataTableItem: DataTableItem<T, [U], [V]>) {

        // Sorce controlelr is nil then return directly
        guard let source =  dataTableItem.host?.viewController else { return }

        // Create navigationController
        let nav = UINavigationController(rootViewController: controller)

        // Set navigationController popover related
        nav.modalPresentationStyle = .popover
        let popover = nav.popoverPresentationController
        popover?.delegate = dataTableItem
        if let sourceView = sourceView {
            // Set sourceView and source rect
            popover?.sourceView = sourceView
            popover?.sourceRect = sourceView.bounds

            // Present
            source.present(nav, animated: true, completion: nil)
        }
    }


    public func createSelectorViewControlelr(dataTableItem: DataTableItem<T, [U], [V]>) -> SelectorViewController<U>? {

        // Create selector view controller
        let selectorVC = SelectorViewController<U>(style: tableViewStyle)

        // Set title
        selectorVC.title = title
        
        selectorVC.isMulSelect = true

        // Set datasource
        selectorVC.datas = values

        // Set formatter
        selectorVC.formatter = optionFormatter

        // Set selectedValue
        selectorVC.selectedValues = dataTableItem.getValue()

        // Set call back: Set value to 'T' when selctor VC disappear
        selectorVC.disappearing = { (value) in
            dataTableItem.setValue(with: value ?? [])
        }
        return selectorVC
    }
    
}

//Todo SelectorItem2 should be SelectorItem, but swift don't support it
public typealias MultiSelectorItem2<T, U: Equatable> = MultiSelectorItem<T, U, U>
