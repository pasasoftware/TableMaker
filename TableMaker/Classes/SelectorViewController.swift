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
    
    public var isMulSelect = false

    public var selectedValues: [T]?

    public var disappearing: (([T]?) -> Void)?

    // MARK: UIViewController lifecycle

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let disappearing = disappearing {
            disappearing(selectedValues)
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
        let row = indexPath.row
        if row < datas.count {
            let item = datas[row]

            cell.textLabel?.text = getDescription(value: datas[indexPath.row])
            cell.accessoryType = selectedValues?.contains(item) == true ? .checkmark : .none
        }
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
        let row = indexPath.row
        if row < datas.count {
            let model = datas[row]
            if isMulSelect == false { // 单选
                selectedValues = [model]
                cancelEvent()
                return
            }
            if selectedValues?.contains(model) == true {
                selectedValues?.removeAll(where: { $0 == model })
            } else {
                selectedValues?.append(model)
            }
            tableView.reloadData()
        }
    }
    
    private func cancelEvent(_ animated: Bool = true) {
        guard let nav = navigationController else {
            dismiss(animated: animated)
            return
        }
        if nav.viewControllers.count >= 2 {
            nav.popViewController(animated: animated)
        } else {
            nav.dismiss(animated: animated)
        }
    }
}
