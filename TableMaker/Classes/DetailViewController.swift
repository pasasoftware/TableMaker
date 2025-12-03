//
//  DetailViewController.swift
//  TableMaker
//
//  Created by Andrew Chai on 4/25/18.
//  Copyright © 2018 Andrew Chai. All rights reserved.
//

import Foundation
import UIKit


open class DetailViewController: UITableViewController {
    public var sections = [TableSection]()

    // MARK: Constructor
    public init(){
        super.init(style: .grouped)
    }
    
    public override init(style: UITableView.Style){
        super.init(style: style)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        //resolve the tableview waver,iOS11 Self-Sizing
        tableView.estimatedRowHeight = 44
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.cellLayoutMarginsFollowReadableWidth = false
    }
    
    public func checkValidators() {
        sections
            .flatMap { $0.items }
            .compactMap { $0 as? any Validatable }
            .forEach { $0.validate() }
    }
    
    public func addSections(sections: [TableSection], indexSet: IndexSet) {
        for (i, row) in indexSet.enumerated() {
            self.sections.insert(sections[i], at: row)
        }
        tableView.insertSections(indexSet, with: .automatic)
    }
    
    public func deleteSection(sections: [TableSection]) {
        var indexSet = IndexSet()
        for section in sections {
            if let index = self.sections.firstIndex(where: {$0 === section}){
                indexSet.insert(index)
            }
        }
        
        for i in indexSet.sorted(by: >) {
            self.sections.remove(at: i)
        }
        tableView.deleteSections(indexSet, with: .automatic)
    }
    
    public func insertSection(section: TableSection, after index:Int){
        let indexSet = IndexSet(integer:index + 1)
        addSections(sections: [section], indexSet: indexSet)
    }
    
    public func insertSection(section: TableSection, before index:Int){
        let indexSet = IndexSet(integer:index)
        addSections(sections: [section], indexSet: indexSet)
    }
    
    public func addItems(items: [TableItem], indexPaths: [IndexPath]) {
        for (i,indexPath) in indexPaths.enumerated() {
            sections[indexPath.section].items.insert(items[i], at: indexPath.row)
        }
        tableView.insertRows(at: indexPaths, with: .automatic)
    }
    
    public func deleteItems(items: [TableItem]) {
        let existItems = items.filter({(isItemExisted(item: $0)) == true})
        let indexPaths = existItems.map({indexPath(for: $0)!})
        for indexPath in indexPaths.sorted(by: >) {
            sections[indexPath.section].items.remove(at: indexPath.row)
        }
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    public func insertItems(items: [TableItem], after indexPath: IndexPath){
        var indexPaths = [IndexPath]()
        for (i,_) in items.enumerated() {
            let path = IndexPath(row: indexPath.row + i + 1, section: indexPath.section)
            indexPaths.append(path)
        }
        addItems(items: items, indexPaths: indexPaths)
    }
    
    public func insertItems(items: [TableItem], before indexPath: IndexPath){
        var indexPaths = [IndexPath]()
        for (i,_) in items.enumerated() {
            let path = IndexPath(row: indexPath.row + i, section: indexPath.section)
            indexPaths.append(path)
        }
        addItems(items: items, indexPaths:indexPaths)
    }
    
    // MARK: Utils
    func getDetailItem(indexPath: IndexPath) -> TableItem {
        return sections[indexPath.section].items[indexPath.row]
    }
    
    public func firstFailedItem() -> Failable?{
        for section in sections {
            if let failedItem = section.firstFailedItem(){
                return failedItem
            }
        }
        return nil
    }
    
    public func endEdit(){
        for section in sections{
            for item in section.items{
                item.endEdit()
            }
        }
    }
}

extension DetailViewController {
    // MARK: DataSource
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let ds = sections[section]
        return ds.items.count
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = getDetailItem(indexPath: indexPath)

        if let cell = tableView.dequeueReusableCell(withIdentifier: item.identifier){
            item.setup(tableView, cell: cell, at: indexPath)
            return cell
        } else {
            let cell = item.createCell()
            item.setup(tableView, cell: cell, at: indexPath)
            return cell
        }
    }

    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let ds = sections[section]
        return ds.header
    }

    open override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let ds = sections[section]
        return ds.footer
    }
}

extension DetailViewController {
    // MARK: Delegate
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = getDetailItem(indexPath: indexPath)
        item.select(tableView, at: indexPath)
    }

    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = getDetailItem(indexPath: indexPath)
        if let height = item.height {
            return height
        } else {
            return tableView.estimatedRowHeight
        }
    }

    open override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let item = getDetailItem(indexPath: indexPath)
        item.accessoryButtonTapped(tableView, at: indexPath)
    }
    
    open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let ds = sections[section]
        return ds.headerView
    }
    
    open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let ds = sections[section]
        return ds.footerView
    }


    open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let ds = sections[section]
        if let height = ds.headerHeight {
            return height
        }
        return tableView.estimatedSectionHeaderHeight
    }

    open override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let ds = sections[section]
        if let height = ds.footerHeight {
            return height
        }
        return tableView.estimatedSectionFooterHeight
    }
}

extension DetailViewController: TableItemHost{
    public var viewController: UIViewController{
        return self
    }
    
    @objc open func valueWillChange(_ tableItem: TableItem) {
        
    }
    
    @objc open func valueDidChange(_ tableItem: TableItem) {
        
    }
    
    public func indexPath(for tableItem: TableItem) -> IndexPath? {
        for i in 0..<sections.count {
            for j in 0..<sections[i].items.count{
                if tableItem === sections[i].items[j] {
                    return IndexPath(row: j, section: i)
                }
            }
        }
        return nil
    }
    
    public func isItemExisted(item: TableItem) -> Bool {
        if indexPath(for: item) != nil {
            return true
        }
        return false
    }
    
    public func getCell(_ tableItem: TableItem) -> UITableViewCell? {
        if let indexPath = indexPath(for: tableItem) {
            return tableView.cellForRow(at: indexPath)
        }
        return nil
    }
    
    public func reloadItem(_ tableItem: TableItem) {
        guard let indexPath = indexPath(for: tableItem) else {
            return
        }
        return tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    public func reloadItems(_ items: [TableItem]) {
        let indexPaths = items.filter{isItemExisted(item: $0)}
                                .map{indexPath(for: $0)!}
        
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
}
