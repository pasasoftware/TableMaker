//
//  PeopleViewController.swift
//  TableMaker
//
//  Created by Andrew Chai on 4/28/18.
//  Copyright © 2018 Andrew Chai. All rights reserved.
//

import UIKit
import Foundation

import TableMaker

class HobbyImageConverter: Converter<Int?, UIImage?>{
    //    let images = [#imageLiteral(resourceName: "football"),#imageLiteral(resourceName: "rocket")]
    
    let images = [UIImage.init(named: "football")?.withRenderingMode(.alwaysOriginal),
                  UIImage.init(named: "rocket")?.withRenderingMode(.alwaysOriginal)]
    
    override func convert(_ value: Int?) -> UIImage? {
        value != nil ? images[value!] : nil
    }
    
    override func convertBack(_ value: UIImage?) -> Int?? {
        return images.firstIndex(of: value!)
    }
//    public override func convert(_ value: Int?) -> UIImage? {
//        return images[value]
//    }
//    
//    public override func convertBack(_ value: UIImage?) -> Int? {
//        return images.firstIndex(of: value!)
//    }
}

class PeopleViewController: DetailViewController {
    let people: People
    
    var petItem: StringSegmentItem2<People,String>!
    
    public init(_ people: People) {
        self.people = people
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func customView(title: String) -> UIView{
        let view = UIView()
        view.backgroundColor = UIColor.gray
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textColor = UIColor.white
        label.textAlignment = .center
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        return view
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = "Table Maker Demo"
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = doneButton
                
        if #available(iOS 15.0, *) {
            let langItem = MenusItem(
                people,
                groups: [
                    MenuGroup(title: "levels", values: [1, 2, 3,4])
                ],
                host: self,
                getter: { $0.level }
            )
            
            langItem.title = "level"
            langItem.setter = { $0.level = $1! }
            langItem.formatter = { "\($0!)" }
//            langItem.addValidator(RequiredValidator())
            
            let nationItem = MenusItem(
                people,
                groups: [
                    MenuGroup(title: "North America", values: [Country.usa, Country.canada]),
                    MenuGroup(title: "Europe", values: [Country.uk]),
                    MenuGroup(title: "Asia", values: [Country.china, Country.japan, Country.korea])
                ],
                host: self,
                getter: { $0.nationality }
            )
            nationItem.title = "Nationality"
            nationItem.emptyDescription = "Select Nation"
            nationItem.clearOptionTitle = "UnSelect"
            nationItem.setter = {
                $0.nationality = $1
            }
            nationItem.formatter = {
                $0?.title
            }
            nationItem.clearOptionTitle = "clear"
//            nationItem.addValidator(RequiredValidator(), isNeeded: true)
            
            let section0 = TableSection([langItem, nationItem])
            section0.headerView = customView(title: "Section0 Header")
            section0.headerHeight = 80
            section0.footerView = customView(title: "Section0 Footer")
            section0.footerHeight = 40
            sections.append(section0)
        }
        
        let item1 = LabelItem2(people){$0.fullName}
        item1.title = "Name"
        item1.textFont = UIFont.boldSystemFont(ofSize: 20)
        item1.detailTextFont = UIFont.boldSystemFont(ofSize: 15)
//        item1.addValidator(RequiredValidator())
        
        let item2 = ActionLabelItem2(people){$0.fullName}
        item2.title = "Action Label"
        item2.accessoryType = .disclosureIndicator
        item2.action = { item in
            print("action label tap")
            
            let c = UIViewController()
            c.view.backgroundColor = .systemGreen
            
            self.navigationController?.pushViewController(c, animated: true)
        }
        
        let firstNameItem = TextFieldItem(people, host: self){$0.firstName}
        firstNameItem.title = "first Name"
        firstNameItem.setter = {
            $0.firstName = $1
        }
        firstNameItem.didChange = {[weak self] ti in
            self?.reloadItem(item1)
        }
        firstNameItem.addValidator(OptionalStringRequiredValidator())
        firstNameItem.addValidator(FunStringValidator())
        
        let lastNameItem = TextFieldItem(people, host: self){$0.lastName}
        lastNameItem.title = "Last Name"
        lastNameItem.setter = {
            $0.lastName = $1
        }
        lastNameItem.didChange = {[weak self] ti in
            self?.reloadItem(item1)
        }
        
        let rightLabel = UILabel()
        rightLabel.text = "%"
        rightLabel.sizeToFit()
        
        let ageItem = TextFieldItem(people, host: self){$0.age}
        ageItem.title = "Age"
        ageItem.keyboardType = .numberPad
        ageItem.setter = {
            $0.age = $1
        }
        ageItem.converter = IntStringConverter()
        ageItem.addValidator(GreaterThanValidator(0))
        ageItem.rightView = rightLabel
        
        petItem = StringSegmentItem2(people){$0.pet}
        petItem.host = self
        petItem.title = "Pet"
        petItem.items = ["🐶","🐷","🐻", "🐔"]
        petItem.setter = {
            $0.pet = $1
        }
//        petItem.addValidator(StringRequiredValidator())
        
        let hobbyItem = ImageSegmentItem(people){$0.hobby}
        hobbyItem.title = "Hobby"
        hobbyItem.converter = HobbyImageConverter()
        hobbyItem.items = [0,1]
        hobbyItem.setter = {
            $0.hobby = $1
        }
        hobbyItem.addValidator(RequiredValidator())
        
        let phoneItem = TextFieldItem(people, host: self){
            $0.phone
        }
        phoneItem.title = "Phone"
        phoneItem.setter = {
            $0.phone = $1
        }
//        phoneItem.addValidator(RegexValidator(phoneRegex))
        
        let emailItem = TextFieldItem(people, host: self){
            $0.email
        }
        emailItem.keyboardType = .emailAddress
        if #available(iOS 13.0, *) {
            emailItem.rightView = UIImageView(image: UIImage(systemName: "square.and.arrow.up.circle.fill")!)
            emailItem.leftView = UIImageView(image: UIImage(systemName: "square.and.arrow.up.circle.fill")!)
        }
        emailItem.title = "Email"
        emailItem.setter = {
            $0.email = $1
        }
        emailItem.addValidator(RegexValidator(emailRegex))
        
        let genderItem = TextFieldItem(people, host: self){$0.gender}
        genderItem.title = "Gender"
        genderItem.setter = {
            $0.gender = $1
        }
        
        let item3 = ButtonItem(title: "Button item"){ [weak self] in
            self?.reloadItem((self?.petItem)!)
        }
        
        // Action item demo
        let item4 = ActionItem(title: "Action item with image", image: UIImage(named: "bulb")){ _,_ in }
        let item5 = ActionItem(title: "Action item"){}
        
        let section1 = TableSection([ firstNameItem, lastNameItem,item1, item2, ageItem, petItem, hobbyItem, phoneItem, emailItem, genderItem])
        section1.headerView = customView(title: "Section1 Header")
        section1.headerHeight = 80
        section1.footerView = customView(title: "Section1 Footer")
        section1.footerHeight = 40
        
        let section2 = TableSection([item3])
        
        let section3 = TableSection([item4, item5])
        
        let item6 = SwitchItem(people){$0.isTeenager}
        item6.host = self
        item6.title = "IsTeenage！"
        item6.setter = {
            $0.isTeenager = $1
        }
        
        let section4 = TableSection([item6])
        
        
        //        let checkItem = CheckItem<People,Bool>(people, host: self, getter: {(p) -> Bool in
        //            true
        //        })
        
        //        let checkItem = CheckItem<People,Bool>(people, host: self, getter: {(p: People) -> Bool in
        //            p.isGirl
        //        })
        //        let checkItem = CheckItem<People, Bool>(people, getter: {(p: People) -> Bool in
        //            p.isGirl
        //        })
        
        //        let checkItem = CheckItem<String, String>("Blah Blah"){ $0
        //        }
        let checkItem = CheckItem(people, host: self){$0.isGirl}
        checkItem.title = "IsAGirl！"
        checkItem.setter = {
            $0.isGirl = $1
        }
        
        let section5 = TableSection([checkItem])
        
        let item8 = SliderItem(people){
            $0.percent
        }
        item8.maxValue = 3
        item8.minValue = 0.2
        item8.host = self
        item8.title = "Slider"
        item8.setter = {
            $0.percent = $1
        }
        
        let section6 = TableSection([item8])
        
        
        let item9 = StepperItem(people){
            $0.stepValue
        }
        item9.formatter = {
            return String(format: "%.1f", $0)
        }
        item9.host = self
        item9.maxValue = 10
        item9.minValue = 0
        item9.stepValue = 0.5
        item9.title = "Stepper"
        item9.setter = {
            $0.stepValue = $1
        }
        
        let section7 = TableSection([item9])
        
        let ageWithoutTitleItem = TextFieldItem(people, host: self){$0.age}
        ageWithoutTitleItem.setter = {
            $0.age = $1
        }
        ageWithoutTitleItem.placeholder = "Enter the age"
        ageWithoutTitleItem.textAlignment = .left
        ageWithoutTitleItem.converter = IntStringConverter()
        ageWithoutTitleItem.addValidator(GreaterThanValidator(0))
        
        let section8 = TableSection([ageWithoutTitleItem])
        section8.header = "Age without title"
        
        // DateItem
        let dateItem = DateItem(people, host: self){$0.birthday}
        dateItem.setter = {
            $0.birthday = $1
        }
        dateItem.datePickerMode = .dateAndTime
        dateItem.timeZome = TimeZone(identifier: "UTC")
        dateItem.title = "Birthday"
//        dateItem.addValidator(RequiredValidator())

        let section9 = TableSection([dateItem])
        
        let textItem = TextViewItem(people){$0.leaveMessage}
        textItem.numberOfLines = 3
//        textItem.maxHeight = 250
        textItem.host = self
        textItem.placeholder = "Pelase enter the leave message"
        textItem.setter = {
            $0.leaveMessage = $1
        }
        
        let section10 = TableSection([textItem])
        
        //        let timeItem = TimeItem(people){$0.leaveTime}
        //        timeItem.host = self
        //        timeItem.title = "LeaveTime"
        //        timeItem.setter = {
        //            $0.leaveTime = $1
        //        }
        //
        //        let section11 = TableSection([timeItem])
        
        // TweakLabelItem
        people.introduction = "My name is \(people.fullName!) and i'm \(people.age) years old.My cellphone is \(people.phone!). My gender is \(people.gender). I'm \(people.isTeenager ? "" : "not ")a teenager.My pet is \(people.pet)."
        let introduction1 = TweakLabelItem2(people){$0.introduction}
        introduction1.title = "Introduction"
        let introduction2 = TweakLabelItem2(people){$0.introduction}
        let section12 = TableSection([introduction1, introduction2])
        
        let imageItem = ImageItem(people) { (p: People) -> UIImage in
            p.iconImage!
        }
        imageItem.host = self
        imageItem.title = "Icon"
        imageItem.height = 60
        imageItem.setter = {
            $0.iconImage = $1
        }
        let section13 = TableSection([imageItem])
        
        let selectorItem = SelectorItem2(people, host: self, values: ["🐶","🐷","🐻"]){$0.secondpet}
        selectorItem.title = "Pet 2"
        selectorItem.setter = { $0.secondpet = $1 }
        selectorItem.host = self
//        selectorItem.style = .popover
                selectorItem.style = .actionSheet
        if #available(iOS 13.0, *) {
            selectorItem.tableViewStyle = .insetGrouped
        }
//        selectorItem.addValidator(RequiredValidator())
        
        let comoboItem = ComboItem(people, host: self, values: ["🐶","🐷","🐻"]){$0.pet}
        comoboItem.title = "Pet"
        comoboItem.setter = { $0.pet = $1 }
        //        comoboItem.style = .actionSheet
        comoboItem.style = .popover
        comoboItem.fetchValues = { _ in
            ["222","444","666"]
        }
        
        if #available(iOS 13.0, *) {
            comoboItem.tableViewStyle = .insetGrouped
        } else {
            comoboItem.tableViewStyle = .plain
        }
        
        let multiValues: [Int] = [1111, 2222, 3333, 4444, 5555]
        let multiSelectorItem = MultiSelectorItem2(people, host: self, values: multiValues, getter: { $0.multiSelector })
        multiSelectorItem.title = "Multi"
        multiSelectorItem.setter = { $0.multiSelector = $1 }
        // option：定制里面选项的显示格式
        multiSelectorItem.optionFormatter = {
            "Number: " + String($0)
        }
        // formatter定制当前行的显示格式
        multiSelectorItem.formatter = {
            $0.compactMap({ String($0) }).joined(separator: ", ")
        }
        if #available(iOS 13.0, *) {
            multiSelectorItem.tableViewStyle = .insetGrouped
        } else {
            multiSelectorItem.tableViewStyle = .plain
        }
        
        let rightLabel2 = UILabel()
        rightLabel2.text = "%%"
        rightLabel2.sizeToFit()
        
        let ageItem2 = TextFieldItem(people, host: self){$0.age}
        ageItem2.title = "Agsdasdase"
        ageItem2.keyboardType = .numberPad
        ageItem2.setter = {
            $0.age = $1
        }
        ageItem2.converter = IntStringConverter()
        ageItem2.addValidator(GreaterThanValidator(0))
        ageItem2.rightView = rightLabel2
        
        
        let section14 = TableSection([ageItem2, selectorItem, comoboItem, multiSelectorItem])
        
        sections.append(contentsOf: [
            section1,
                        section2,
                        section3,
                        section4,
                        section5,
                        section6,
                        section7,
                        section8,
                        section9,
                        section10,
                        //                    section11,
                section12,
                section13,
                section14
        ])
    }
    
    override func valueDidChange(_ tableItem: TableItem) {
        people.introduction = "My name is \(people.fullName!) and i'm \(people.age) years old.My cellphone is \(people.phone!). My gender is \(people.gender). I'm \(people.isTeenager ? "" : "not ")a teenager.My pet is \(people.pet)."
//        tableView.reloadData()
    }
    
    @objc func doneTapped(){
//        let items = sections[1].items
//        insertItems(items: items, after: indexPath(for: sections.first!.items.first!)!)
        
        endEdit()
        
        checkValidators()
        
        if let failedItem = firstFailedItem(){
            let alert = UIAlertController(title: "Error", message: failedItem.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }else {
            dismiss(animated: true, completion: nil)
        }
    }
}

public class FunStringValidator: Validator<String?> {
    public override var message: String {
        return "is required"
    }

    public override func validate(_ value: String?) -> Bool {
        guard let string = value else { return false }
        return string == "fun"
    }
}
