//
//  SteppeItem.swift
//  TableMaker
//
//  Created by pasasoft_mini on 2018/5/4.
//  Copyright © 2018年 Andrew Chai. All rights reserved.
//

import UIKit
import Foundation

public class StepperCell: UITableViewCell{
    let stepper: UIStepper!
    
    public init(reuseIdentifier: String?) {
        stepper = UIStepper()
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryView = stepper
        detailTextLabel?.textColor = stepper.tintColor
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if textLabel!.frame.width > contentView.frame.width / 2 {
            textLabel!.frame.width = contentView.frame.width / 2
        }
        detailTextLabel!.frame.x = detailTextLabel!.frame.x - contentView.layoutMargins.right
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    public override func prepareForReuse() {
        stepper.removeTarget(nil, action: nil, for: .allEvents)
    }
}

public class StepperItem<T, U: Equatable>: DataTableItem<T,U,Double>{
    public var maxValue: Double = 1
    public var minValue: Double = 0
    public var stepValue: Double = 0.1
    public override var identifier: String {
        return "stepperCellReuseId"
    }
    
    public override var autoReload: Bool{
        return false
    }
    
    public override func createCell() -> UITableViewCell {
        return StepperCell(reuseIdentifier: identifier)
    }
    
    public override func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath) {
        super.setup(tableView, cell: cell, at: indexPath)
        let cell = cell as! StepperCell
        cell.textLabel?.text = title
        let stepper = cell.stepper!
        stepper.maximumValue = maxValue
        stepper.minimumValue = minValue
        stepper.stepValue = stepValue
        stepper.value = convertValue()
        cell.detailTextLabel?.text = getDescription()
        stepper.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    
    @objc func sliderValueChanged(_ obj: Any?){
        guard let stepper = obj as? UIStepper else {
            return
        }
        setValue(withConverted: stepper.value)
        guard let host = host else {
            return
        }
        let cell = host.getCell(self) as! StepperCell
        cell.detailTextLabel?.text = getDescription()
    }
    
}
