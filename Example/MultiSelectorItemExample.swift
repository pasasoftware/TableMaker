//
//  MultiSelectorItemExample.swift
//  TableMaker
//
//  Created by GitHub Copilot on 2025/8/17.
//  Copyright © 2025 Andrew Chai. All rights reserved.
//

import UIKit
import Foundation
import TableMaker

class TestData {
    var selectedItems: [String] = ["Reading", "Gaming"]
}

class MultiSelectorExampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TableItemHost {
    
    var viewController: UIViewController { return self }
    var tableView: UITableView!
    
    private let testData = TestData()
    private var items: [TableItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "MultiSelector Demo"
        
        // Setup table view
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        // Create MultiSelectorItem
        let multiSelectorItem = MultiSelectorItem2(testData, host: self, values: ["Reading", "Coding", "Gaming", "Sports", "Music", "Travel"]) { $0.selectedItems }
        multiSelectorItem.title = "Select Hobbies"
        multiSelectorItem.setter = { data, newValue in
            data.selectedItems = newValue
        }
        
        items = [multiSelectorItem]
    }
    
    // MARK: - TableItemHost
    func valueWillChange(_ tableItem: TableItem) {
        // Placeholder implementation
    }
    
    func valueDidChange(_ tableItem: TableItem) {
        tableView.reloadData()
    }
    
    func getCell(_ tableItem: TableItem) -> UITableViewCell? {
        if let indexPath = indexPath(for: tableItem) {
            return tableView.cellForRow(at: indexPath)
        }
        return nil
    }
    
    func indexPath(for tableItem: TableItem) -> IndexPath? {
        if let index = items.firstIndex(where: { $0 === tableItem }) {
            return IndexPath(row: index, section: 0)
        }
        return nil
    }
    
    func reloadItem(_ tableItem: TableItem) {
        if let indexPath = indexPath(for: tableItem) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = item.createCell()
        item.setup(tableView, cell: cell, at: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.select(tableView, at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
