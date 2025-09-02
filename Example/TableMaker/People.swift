//
//  People.swift
//  TableMaker
//
//  Created by Andrew Chai on 4/25/18.
//  Copyright © 2018 Andrew Chai. All rights reserved.
//

import Foundation
import UIKit

class People {
    var firstName: String? = "Allen"
    var lastName: String? = "Green"
    
    var fullName: String? {
        guard let firstName = firstName else {return lastName}
        guard let lastName = lastName else {return firstName}
        return "\(firstName) \(lastName)"
    }
    var phone: String? = "13654785"
    var email: String? = "10001@qq.com"
    var gender: String = "male"
    
    var age: Int = 18
    
    var pet: String = "🐶"
    
    var hobby: Int = 0

    var birthday: Date? = nil

    var isTeenager: Bool = false
    
    var isGirl: Bool = false
    
    var percent: Float = 0.6
    
    var stepValue: Double = 2.0
    
    var leaveMessage: String = ""
    
    var leaveTime: Date = Date()

    var introduction: String?
    
    var iconImage: UIImage! = UIImage(named: "headIcon")
    
    var multiSelector: [Int] = [1111, 2222, 3333]
}
