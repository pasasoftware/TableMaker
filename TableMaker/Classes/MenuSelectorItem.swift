//
//  MenuSelectorItem.swift
//  TableMaker
//
//  Created by qiming xiao on 2025/11/5.
//

import Foundation
import UIKit

// MARK: - MenuGroup
@available(iOS 15.0, *)
public struct MenuGroup<U: Equatable> {
    public let title: String?
    public let values: [U]
    
    public init(title: String? = nil, values: [U]) {
        self.title = title
        self.values = values
    }
}

// MARK: - MenusItem
@available(iOS 15.0, *)
open class MenusItem<T, U: Equatable>: DataTableItem<T, U?, U?> {

    open override var autoReload: Bool {
        return true
    }
    
    override open var identifier: String {
        "IndicatorMenuCell"
    }
    
    public var groups: [MenuGroup<U>] = []
    
    public var menuTitle: String?
    public var emptyDescription: String?
    public var clearOptionTitle: String?

    public convenience init(
        _ data: T,
        groups: [MenuGroup<U>],
        host: TableItemHost,
        getter: @escaping (T) -> U?)
    {
        self.init(data, getter: getter)
        self.host = host
        self.groups = groups
    }
    
    public override func createCell() -> UITableViewCell {
        let cell = IndicatorMenuCell(reuseIdentifier: identifier)
        return cell
    }

    override open func setup(_ tableView: UITableView, cell: UITableViewCell, at indexPath: IndexPath) {
        super.setup(tableView, cell: cell, at: indexPath)

        guard let menuCell = cell as? IndicatorMenuCell else { return }
        
        let description = getDescription()
        let displayText = description ?? emptyDescription
        let isEmptyState = (description == nil && emptyDescription != nil)
                
        menuCell.configData(
            title ?? "",
            content: displayText,
            isEmptyState: isEmptyState,
            menu: { [weak self] in
                return self?.buildMenu()
            })
    }

    private func buildMenu() -> UIMenu {
        let currentValue = getValue()
        
        var allSubmenus: [UIMenu] = []
        
        let normalSubmenus = groups.map { group -> UIMenu in
            let actions = group.values.map { value -> UIAction in
                let title = getDescription(with: value) ?? "\(value)"
                let state: UIMenuElement.State = (currentValue == value) ? .on : .off
                
                return UIAction(title: title,
                                identifier: UIAction.Identifier(title),
                                state: state) { [weak self] _ in
                    self?.setValue(withConverted: value)
                }
            }
            
            return UIMenu(
                title: group.title ?? "",
                options: .displayInline,
                children: actions
            )
        }
        
        allSubmenus.append(contentsOf: normalSubmenus)
        
        if let clearOptionTitle {
            let clearAction = UIAction(
                title: clearOptionTitle,
                attributes: .destructive
            ) { [weak self] _ in
                self?.setValue(withConverted: nil)
            }
            
            let clearMenu = UIMenu(
                options: .displayInline,
                children: [clearAction]
            )
            
            allSubmenus.append(clearMenu)
        }
        
        return UIMenu(title: menuTitle ?? "", children: allSubmenus)
    }
    
    open override func select(_ tableView: UITableView, at indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

@available(iOS 15.0, *)
class IndicatorMenuCell: UITableViewCell {
    var tapAction: (() -> Void)?

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true

        var configuration = UIButton.Configuration.plain()
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
            outgoing.foregroundColor = UIColor.secondaryLabel
            return outgoing
        }
        configuration.image = UIImage(systemName: "chevron.up.chevron.down")
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8
        configuration.contentInsets = .zero
        
        button.configuration = configuration
        button.contentHorizontalAlignment = .right
        return button
    }()
    
    public init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        button.setTitle(nil, for: .normal)
        button.menu = nil
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configData(_ title: String, content: String?, isEmptyState: Bool = false, menu: (() -> UIMenu?)?) {
        titleLabel.text = title
        button.setTitle(content, for: .normal)
        
        var config = button.configuration
        config?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
            outgoing.foregroundColor = isEmptyState ? UIColor.tertiaryLabel : UIColor.secondaryLabel
            return outgoing
        }
        button.configuration = config
        
        if let menu {
            button.menu = menu()
        }
    }

    override func becomeFirstResponder() -> Bool {
        tapAction?()
        return true
    }
}

@available(iOS 15.0, *)
extension IndicatorMenuCell {
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(button)

        titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor).isActive = true

        button.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 33).isActive = true
    }
}
