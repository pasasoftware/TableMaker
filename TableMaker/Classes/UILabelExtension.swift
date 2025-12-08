//
//  UILabelExtension.swift
//  TableMaker
//
//  Created by ZhangTeng on 2025/12/3.
//

import UIKit

extension UILabel {
    
    /// 设置label的文本，当isRequire为true时，在title前添加红色星号
    public func setLabelWithRequiredMark(_ title: String?, isRequire: Bool = false) {
        guard let title = title else {
            self.text = nil
            self.attributedText = nil
            return
        }
        
        if isRequire {
            let attributedString = NSMutableAttributedString()
            let starString = "* "
            attributedString.append(NSAttributedString(string: starString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed]))
            attributedString.append(NSAttributedString(string: title))
            
            self.text = nil
            self.attributedText = attributedString
        } else {
            self.attributedText = nil
            self.text = title
        }
    }
}
