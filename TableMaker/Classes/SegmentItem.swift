//
//  SegmentItem.swift
//  TableMaker
//
//  Created by Andrew Chai on 4/28/18.
//  Copyright © 2018 Andrew Chai. All rights reserved.
//

import UIKit
import Foundation

public class SegmentCell: UITableViewCell {
    let segment: UISegmentedControl!
    
    public init(reuseIdentifier: String?) {
        segment = UISegmentedControl(items: nil)
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        accessoryView = segment
        selectionStyle = .none
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    public override func prepareForReuse() {
        segment.removeTarget(nil, action: nil, for: .allEvents)
        segment.removeAllSegments()
    }
}

public class SegmentItem<T, U: Equatable, V>: DataTableItem<T,U,V> {
    public var items: [U]?
    
    public override var identifier: String {
        return "segmentCellReuseId"
    }
    
    public override var autoReload: Bool{
        return false
    }
    
    public override func createCell() -> UITableViewCell {
        return SegmentCell(reuseIdentifier: identifier)
    }
    
    public override func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath) {
        super.setup(tableView, cell: cell, at: indexPath)
        
        let cell = cell as! SegmentCell
        cell.textLabel?.setLabelWithRequiredMark(title, isRequire: isRequire)
        
        guard let items = items else {
            return
        }
        
        let segment = cell.segment!
        for i in 0...items.count-1{
            insertSegment(segment, at: i, item: items[i])
        }
        
        if let index = items.firstIndex(of: getValue()){
            segment.selectedSegmentIndex = index
        }
        
        segment.addTarget(self, action: #selector(segmentSelectionChanged), for: .valueChanged)
    }
    
    func insertSegment(_ segment: UISegmentedControl, at index: Int, item: U){
    }
    
    @objc func segmentSelectionChanged(_ obj: Any?){
        guard
            let segment = obj as? UISegmentedControl,
            let items = items else{
                return
        }
        
        setValue(with: items[segment.selectedSegmentIndex])
    }
}


public class StringSegmentItem<T, U: Equatable, V>: SegmentItem<T,U,V> {
   
    override func insertSegment(_ segment: UISegmentedControl, at index: Int, item: U) {
        let title = getDescription(with: item)
        segment.insertSegment(withTitle: title, at: index, animated: false)
    }
}

public typealias StringSegmentItem2<T, U: Equatable> = StringSegmentItem<T,U,U>

public class ImageSegmentItem<T, U: Equatable>: SegmentItem<T,U,UIImage?> {
    
    override func insertSegment(_ segment: UISegmentedControl, at index: Int, item: U) {
        let image = convertValue(with: item)
        segment.insertSegment(with: image, at: index, animated: false)
    }
}
