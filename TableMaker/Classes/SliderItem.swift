//
//  SliderItem.swift
//  TableMaker
//
//  Created by pasasoft_mini on 2018/5/3.
//  Copyright © 2018年 Andrew Chai. All rights reserved.
//

import UIKit
import Foundation

let viewSpacing = CGFloat(8)

public class SliderCell: UITableViewCell {
    let slider: UISlider!

    public init(reuseIdentifier: String?) {
        slider = UISlider()
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(slider)
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if textLabel!.frame.width > contentView.frame.width / 2 {
            textLabel!.frame.width = contentView.frame.width / 2
        }
        let spacing = textLabel!.frame.isEmpty ? CGFloat(0) : viewSpacing
        slider.frame = CGRect(x: textLabel!.frame.right + spacing,
                              y: 0,
                              width: contentView.frame.width - textLabel!.frame.right - textLabel!.frame.left - spacing,
                              height: contentView.frame.size.height)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    public override func prepareForReuse() {
        slider.removeTarget(nil, action: nil, for: .allEvents)
    }
    
}

public class SliderItem<T, U: Equatable & CustomStringConvertible>: DataTableItem<T,U,Float> {
    public var maxValue: Float = 1
    public var minValue: Float = 0
    public var minimumValueImage: UIImage?
    public var maximumValueImage: UIImage?
    public override var identifier: String {
        return "sliderCellReuseId"
    }
        
    public override var autoReload: Bool{
        return false
    }
    
    public override func createCell() -> UITableViewCell {
        return SliderCell(reuseIdentifier: identifier)
    }
    
    public override func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath) {
        super.setup(tableView, cell: cell, at: indexPath)
        let cell = cell as! SliderCell
        cell.textLabel?.text = title
        let slider = cell.slider!
        slider.maximumValue = maxValue
        slider.minimumValue = minValue
        slider.value = convertValue()
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.minimumValueImage = minimumValueImage
        slider.maximumValueImage = maximumValueImage
    }
    
    @objc func sliderValueChanged(_ obj: Any?){
        guard let slider = obj as? UISlider else {
            return
        }
        setValue(withConverted: slider.value)
    }
    
}
