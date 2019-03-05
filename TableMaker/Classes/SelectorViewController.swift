//
//  SelectorItemViewController.swift
//  TableMaker
//
//  Created by pasasoft on 2018/5/11.
//  Copyright © 2018年 Andrew Chai. All rights reserved.
//

import Foundation
import UIKit

open class SelectorViewController<T: CustomStringConvertible & Equatable>: UITableViewController {

    // MARK: - Property

    let identifier = "labelReuseId"

    public var datas: [T] = []

    public var formatter: ((T) -> String?)?

    public var selectedIndex = -1

    public var selectedValue: T? {
        didSet {
            guard   let value = selectedValue,
                    let index = datas.index(of: value) else {
                return
            }
            selectedIndex = index
        }
    }

    public var disappearing: ((T?) -> Void)?

    // MARK: UIViewController lifecycle

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let disappearing = disappearing {
            disappearing(getSelectedValue())
        }
    }

    // MARK: UITableViewDataSource

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let tempCell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            cell = tempCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        configureCell(cell: cell, forRowAt: indexPath)
        return cell
    }

    func configureCell(cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if indexPath.row == selectedIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        cell.textLabel?.text = getDescription(value: datas[indexPath.row])
    }

    // MARK: UITableViewDelegate
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectItem(tableView, indexPath: indexPath)
    }

}

extension SelectorViewController {

    private func getDescription(value: T) -> String? {
        guard let formatter = formatter else {
            return value.description
        }
        return formatter(value)
    }

    private func selectItem(_ tableView: UITableView, indexPath: IndexPath) {
        let preSelectedIndex = selectedIndex
        selectedIndex = indexPath.row

        var indices: [IndexPath] = []
        if indexPath.row >= 0 && indexPath.row < datas.count {
            indices.append(indexPath)
        }

        if  preSelectedIndex >= 0 &&
            preSelectedIndex < datas.count &&
            preSelectedIndex != selectedIndex {
            indices.append(IndexPath(row: preSelectedIndex, section: 0))
        }

        if (indices.count > 0) {
            tableView.reloadRows(at: indices, with: .automatic)
        }
    }

    private func getSelectedValue() -> T? {
        if (datas.count == 0) {
            return nil
        }

        if (selectedIndex >= 0 && selectedIndex < datas.count) {
            return datas[selectedIndex]
        }
        return nil
    }
}
