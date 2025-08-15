//
//  MultiSelectorItemExample.swift
//  TableMaker
//
//  Created by pasasoft on 2025/8/15.
//  Copyright © 2025年 Andrew Chai. All rights reserved.
//

import Foundation
import UIKit

// 示例数据模型
class UserPreferences {
    var selectedHobbies: Set<String> = []
    var selectedColors: Set<String> = []
}

// 使用示例
class ExampleViewController: UIViewController, TableItemHost {
    var tableView: UITableView!
    var viewController: UIViewController { return self }
    
    let preferences = UserPreferences()
    let hobbies = ["阅读", "游泳", "跑步", "音乐", "绘画", "编程"]
    let colors = ["红色", "蓝色", "绿色", "黄色", "紫色"]
    
    var multiSelectorItem: MultiSelectorItem2<UserPreferences, String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMultiSelectorItem()
    }
    
    func setupMultiSelectorItem() {
        // 创建多选项
        multiSelectorItem = MultiSelectorItem2(
            preferences,
            host: self,
            values: hobbies,
            getter: { $0.selectedHobbies },
            setter: { $0.selectedHobbies = $1 }
        )
        
        multiSelectorItem.title = "选择爱好"
        multiSelectorItem.maxSelections = 3  // 最多选3个
        multiSelectorItem.minSelections = 1  // 最少选1个
        multiSelectorItem.style = .push
        
        // 演示各种 setValue 兼容的用法
        demonstrateSetValueCompatibility()
    }
    
    func demonstrateSetValueCompatibility() {
        // 1. 直接使用继承的 setValue 方法设置 Set<String>
        multiSelectorItem.setValue(with: Set(["阅读", "音乐"]))
        
        // 2. 使用便捷方法设置选中值
        multiSelectorItem.setSelectedValues(["游泳", "编程"])
        
        // 3. 使用数组设置选中值
        multiSelectorItem.setSelectedValues(["阅读", "绘画", "音乐"])
        
        // 4. 添加单个值
        let success = multiSelectorItem.addValue("跑步")
        print("添加跑步: \(success)")
        
        // 5. 移除单个值
        let removed = multiSelectorItem.removeValue("绘画")
        print("移除绘画: \(removed)")
        
        // 6. 切换选择状态
        let toggled = multiSelectorItem.toggleSelection(for: "游泳")
        print("切换游泳: \(toggled)")
        
        // 7. 检查是否选中
        let isSelected = multiSelectorItem.isSelected("阅读")
        print("阅读是否选中: \(isSelected)")
        
        // 8. 获取选中值
        let selectedSet = multiSelectorItem.getValue()  // 继承的方法
        let selectedArray = multiSelectorItem.getSelectedValuesArray()  // 便捷方法
        
        print("选中的值 (Set): \(selectedSet)")
        print("选中的值 (Array): \(selectedArray)")
    }
    
    // MARK: - TableItemHost协议实现
    func valueWillChange(_ tableItem: TableItem) {
        print("值即将改变")
    }
    
    func valueDidChange(_ tableItem: TableItem) {
        print("值已改变: \(multiSelectorItem.getValue())")
        // 可以在这里更新UI或保存数据
    }
    
    func getCell(_ tableItem: TableItem) -> UITableViewCell? {
        return nil
    }
    
    func indexPath(for tableItem: TableItem) -> IndexPath? {
        return IndexPath(row: 0, section: 0)
    }
    
    func reloadItem(_ tableItem: TableItem) {
        // 重新加载对应的 cell
        DispatchQueue.main.async {
            // 这里可以重新加载tableView的特定cell
        }
    }
}

// MARK: - 验证器示例
extension ExampleViewController {
    func setupWithValidation() {
        // 添加验证器
        let validator = Validator<Set<String>> { selectedValues in
            // 验证至少选择一个包含"运动"相关的爱好
            let sportsHobbies = Set(["游泳", "跑步"])
            return !selectedValues.intersection(sportsHobbies).isEmpty
        }
        validator.message = "至少选择一个运动项目"
        
        multiSelectorItem.validators.append(validator)
        
        // 设置验证失败回调
        multiSelectorItem.validateFailed = { validator in
            print("验证失败: \(validator.message)")
        }
    }
}
