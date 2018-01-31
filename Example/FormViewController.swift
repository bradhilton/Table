//
//  FormViewController.swift
//  Table
//
//  Created by Bradley Hilton on 3/16/17.
//  Copyright © 2017 Brad Hilton. All rights reserved.
//

import UIKit
import Table

class FieldCell : UITableViewCell {
    
    let textField = UITextField()
    var editingDidEnd: (String) -> () = { _ in }
    var primaryActionTriggered: (UITextField) -> () = { _ in  }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        textField.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30).isActive = true
        textField.addTarget(self, action: #selector(editingDidEnd(textField:)), for: [.editingDidEnd])
        textField.addTarget(self, action: #selector(primaryActionTriggered(textField:)), for: [.primaryActionTriggered])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func editingDidEnd(textField: UITextField) {
        editingDidEnd(textField.text ?? "")
    }
    
    @objc func primaryActionTriggered(textField: UITextField) {
        primaryActionTriggered(textField)
    }
    
}

struct Field {
    let placeholder: String
    var text: String = ""
    
    init(placeholder: String) {
        self.placeholder = placeholder
        self.text = ""
    }
    
}

class FormViewController : UITableViewController {
    
    var fields = [
        Field(placeholder: "First Name"),
        Field(placeholder: "Last Name"),
        Field(placeholder: "Email Address"),
        Field(placeholder: "Phone Number"),
        Field(placeholder: "Street"),
        Field(placeholder: "Street 2"),
        Field(placeholder: "City"),
        Field(placeholder: "State"),
        Field(placeholder: "Zip Code"),
        Field(placeholder: "Country")
    ] {
        didSet {
            tableView.sections = sections
        }
    }
    
    init() {
        super.init(style: .grouped)
        title = "Form"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.sections = sections
    }
    
    var sections: [Section] {
        return [
            Section { (section: inout Section) in
                section.rows = fields.enumerated().map { (index, field) in
                    return Row { row in
                        row.height = 44
                        row.key = field.placeholder
                        row.cell = Cell { [unowned self] (cell: FieldCell) in
                            cell.textField.placeholder = field.placeholder
                            cell.textField.enablesReturnKeyAutomatically = true
                            cell.textField.returnKeyType = index + 1 == self.fields.endIndex ? .done : .next
                            cell.textField.text = field.text
                            cell.editingDidEnd = { [unowned self] text in
                                self.fields[index].text = text
                            }
                            cell.primaryActionTriggered = { textField in
                                textField.tabToNextResponder()
                            }
                        }
                    }
                }
            }
        ]
    }
    
}

extension UIView {
    
    private var rootView: UIView {
        return superview?.rootView ?? self
    }
    
    private var descendents: [UIView] {
        return subviews + subviews.flatMap { $0.descendents }
    }
    
    private var descendentResponders: [UIView] {
        return descendents.filter { $0.canBecomeFirstResponder }
    }
    
    private var sortedDescendentResponders: [UIView] {
        return descendentResponders.sorted { lhs, rhs in
            let lhs = convert(lhs.frame.origin, from: lhs)
            let rhs = convert(rhs.frame.origin, from: rhs)
            return lhs.y == rhs.y ? lhs.x < rhs.x : lhs.y < rhs.y
        }
    }
    
    private var subsequentResponder: UIView? {
        let sortedResponders = rootView.sortedDescendentResponders
        guard let index = sortedResponders.index(of: self) else { return nil }
        return sortedResponders[(index + 1)...].first
    }
    
    func tabToNextResponder() {
        if let subsequentResponder = subsequentResponder {
            subsequentResponder.becomeFirstResponder()
        } else {
            resignFirstResponder()
        }
    }
    
}
