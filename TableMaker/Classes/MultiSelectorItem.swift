//
//  MultiSelectorItem.swift
//  TableMaker
//
//  Created by pasasoft on 2025/8/15.
//  Copyright © 2025年 Andrew Chai. All rights reserved.
//

import Foundation
import UIKit

open class MultiSelectorItem<T, U: Equatable & CustomStringConvertible & Hashable, V: CustomStringConvertible & Equatable>: DataTableItem<T, Set<U>, V> {

    // MARK: - Property
    open override var accessoryType: UITableViewCell.AccessoryType {
        return .disclosureIndicator
    }

    open override var autoReload: Bool {
        return true
    }

    open override var identifier: String {
        return "multiSelectorCellReuseId"
    }

    /// As datasource of options.
    public var values: [U]

    /// Determine the style of options, default is "Push".
    public var style = SelectorItemStyle.push

    /// Maximum number of selections allowed (nil = unlimited)
    public var maxSelections: Int?

    /// Minimum number of selections required
    public var minSelections: Int = 0

    /// Custom detail text for display
    public var detailText: V? {
        let selectedValues = getValue()
        let selectedCount = selectedValues.count
        if selectedCount == 0 {
            return "未选择" as? V
        } else if selectedCount <= 3 {
            let selectedDescriptions = selectedValues.map { $0.description }
            return selectedDescriptions.joined(separator: ", ") as? V
        } else {
            return "已选择 \(selectedCount) 项" as? V
        }
    }

    // MARK: - Constructor
    public init(_ data: T, 
                host: TableItemHost, 
                values: [U], 
                getter: @escaping (T) -> Set<U>,
                setter: @escaping (T, Set<U>) -> Void) {
        self.values = values
        super.init(data, getter: getter)
        self.setter = setter
        self.host = host
    }

    // MARK: - Override TableItem methods
    open override func createCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        cell.selectionStyle = .none
        cell.accessoryType = accessoryType
        return cell
    }
    
    open override func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath) {
        super.setup(tableView, cell: cell, at: indexPath)
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = detailText?.description
    }

    open override func select(_ tableView: UITableView, at indexPath: IndexPath) {
        // Different behaviors based on style
        switch style {
        case .actionSheet:
            showMultiSelectionActionSheet(sourceView: getSourceView(tableView: tableView, indexPath: indexPath))
        case .push:
            if let vc = createMultiSelectorViewController() {
                showPush(vc, dataTableItem: self)
            }
        case .popover:
            if let vc = createMultiSelectorViewController() {
                showPopover(vc, sourceView: getSourceView(tableView: tableView, indexPath: indexPath), dataTableItem: self)
            }
        }
    }

    
    public func showPush(_ controller: UIViewController, dataTableItem: DataTableItem<T, Set<U>, V>) {
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

    public func showPopover(_ controller: UIViewController, sourceView: UIView?, dataTableItem: DataTableItem<T, Set<U>, V>) {

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

    
    // MARK: - Multi-selection methods
    
    /// Toggle selection for a value
    public func toggleSelection(for value: U) -> Bool {
        var currentSelected = getValue()
        
        if currentSelected.contains(value) {
            // Check minimum selections
            if currentSelected.count <= minSelections {
                return false // Cannot deselect
            }
            currentSelected.remove(value)
        } else {
            // Check maximum selections
            if let max = maxSelections, currentSelected.count >= max {
                return false // Cannot select more
            }
            currentSelected.insert(value)
        }
        
        // Use the inherited setValue method
        setValue(with: currentSelected)
        return true
    }

    /// Check if a value is selected
    public func isSelected(_ value: U) -> Bool {
        return getValue().contains(value)
    }

    /// Select all values
    public func selectAll() {
        var newSelected: Set<U>
        if let max = maxSelections {
            newSelected = Set(values.prefix(max))
        } else {
            newSelected = Set(values)
        }
        setValue(with: newSelected)
    }

    /// Clear all selections (respecting minimum)
    public func clearAll() {
        if minSelections == 0 {
            setValue(with: Set<U>())
        }
    }

    /// Set selected values directly (compatible with setValue pattern)
    public func setSelectedValues(_ selectedValues: Set<U>) {
        setValue(with: selectedValues)
    }

    /// Get selected values (compatible with getValue pattern)
    public func getSelectedValues() -> Set<U> {
        return getValue()
    }

    /// Convenience method to set selected values from array
    public func setSelectedValues(_ selectedValues: [U]) {
        setValue(with: Set(selectedValues))
    }

    /// Convenience method to get selected values as array
    public func getSelectedValuesArray() -> [U] {
        return Array(getValue())
    }

    // MARK: - setValue compatibility methods
    
    /// Set a single value (adds to selection if not present, replaces all if present)
    public func setSingleValue(_ value: U) {
        var currentSelected = getValue()
        if currentSelected.contains(value) {
            currentSelected = [value]
        } else {
            currentSelected.insert(value)
        }
        setValue(with: currentSelected)
    }

    /// Add a value to the selection
    public func addValue(_ value: U) -> Bool {
        var currentSelected = getValue()
        if currentSelected.contains(value) {
            return false // Already selected
        }
        
        if let max = maxSelections, currentSelected.count >= max {
            return false // Cannot select more
        }
        
        currentSelected.insert(value)
        setValue(with: currentSelected)
        return true
    }

    /// Remove a value from the selection
    public func removeValue(_ value: U) -> Bool {
        var currentSelected = getValue()
        if !currentSelected.contains(value) {
            return false // Not selected
        }
        
        if currentSelected.count <= minSelections {
            return false // Cannot deselect due to minimum requirement
        }
        
        currentSelected.remove(value)
        setValue(with: currentSelected)
        return true
    }
}

extension MultiSelectorItem {

    // MARK: - Utils
    private func getSourceView(tableView: UITableView, indexPath: IndexPath) -> UIView? {
        let cell = tableView.cellForRow(at: indexPath)
        return cell?.detailTextLabel
    }

    private func createMultiSelectorViewController() -> UIViewController? {
        let vc = MultiSelectorViewController<U>()
        
        vc.values = values
        vc.selectedValues = getValue()
        vc.maxSelections = maxSelections
        vc.minSelections = minSelections
        vc.onSelectionChanged = { [weak self] newSelectedValues in
            self?.setValue(with: newSelectedValues)
        }
        
        return vc
    }

    private func showMultiSelectionActionSheet(sourceView: UIView?) {
        let alertController = UIAlertController(title: "选择选项", message: nil, preferredStyle: .actionSheet)
        
        for value in values {
            let isSelected = getValue().contains(value)
            let title = isSelected ? "✓ \(value.description)" : value.description
            
            let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
                let _ = self?.toggleSelection(for: value)
            }
            
            alertController.addAction(action)
        }
        
        // Add "Select All" and "Clear All" options
        if maxSelections == nil || maxSelections! > 1 {
            alertController.addAction(UIAlertAction(title: "全选", style: .default) { [weak self] _ in
                self?.selectAll()
            })
        }
        
        if minSelections == 0 {
            alertController.addAction(UIAlertAction(title: "清除", style: .destructive) { [weak self] _ in
                self?.clearAll()
            })
        }
        
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let sourceView = sourceView {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
        }
        
        host?.viewController.present(alertController, animated: true)
    }
}

// Convenience typealias
public typealias MultiSelectorItem2<T, U: Equatable & CustomStringConvertible & Hashable> = MultiSelectorItem<T, U, String>
