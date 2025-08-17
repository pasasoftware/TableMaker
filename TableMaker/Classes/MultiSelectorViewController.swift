//
//  MultiSelectorViewController.swift
//  TableMaker
//
//  Created by GitHub Copilot on 2025/8/17.
//  Copyright © 2025 Andrew Chai. All rights reserved.
//

import Foundation
import UIKit

class MultiSelectorViewController<T, U: Equatable & CustomStringConvertible, V: CustomStringConvertible & Equatable>: UITableViewController {

    var item: MultiSelectorItem<T, U, V>!
    private var selectedValues: [U]!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = item.title
        selectedValues = item.getValue()
        
        tableView.allowsMultipleSelection = true
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = doneButton
    }

    @objc private func doneTapped() {
        item.setValue(with: selectedValues)
        navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return item.values.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "MultiSelectorCell")
        let value = item.values[indexPath.row]
        cell.textLabel?.text = value.description
        
        if selectedValues.contains(value) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let value = item.values[indexPath.row]
        if let index = selectedValues.firstIndex(of: value) {
            selectedValues.remove(at: index)
        } else {
            selectedValues.append(value)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
