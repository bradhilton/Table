//
//  UIPickerView.swift
//  Table
//
//  Created by Bradley Hilton on 8/4/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public struct PickerComponent : Equatable {
    public let rows: [PickerRow]
    public let selectedRow: Int
    public init(rows: [PickerRow], selectedRow: Int) {
        self.rows = rows
        self.selectedRow = selectedRow
    }
}

public struct PickerRow : Equatable {
    public let content: PickerRowContent
    public let didSelect: (() -> ())?
    
    public init(title: String, didSelect: (() -> ())?) {
        self.content = .title(title)
        self.didSelect = didSelect
    }
    
    public init(attributedTitle: NSAttributedString, didSelect: (() -> ())?) {
        self.content = .attributedTitle(attributedTitle)
        self.didSelect = didSelect
    }
    
    public init(content: PickerRowContent, didSelect: (() -> ())?) {
        self.content = content
        self.didSelect = didSelect
    }
    
    public static func ==(lhs: PickerRow, rhs: PickerRow) -> Bool {
        return lhs.content == rhs.content
    }
}

public enum PickerRowContent : Equatable {
    case title(String)
    case attributedTitle(NSAttributedString)
    
    var title: String? {
        guard case let .title(title) = self else { return nil }
        return title
    }
    
    var attributedTitle: NSAttributedString? {
        guard case let .attributedTitle(attributedTitle) = self else { return nil }
        return attributedTitle
    }
    
}

extension UIPickerView {
    
    public var components: [PickerComponent] {
        get {
            return storage[\.components, default: []]
        }
        set {
            let oldValue = components
            storage[\.components] = newValue
            if (dataSource !== defaultDataSource) {
                dataSource = defaultDataSource
            }
            if (delegate !== defaultDelegate) {
                delegate = defaultDelegate
            }
            if oldValue != newValue {
                for (index, newComponent) in newValue.enumerated() {
                    if selectedRow(inComponent: index) > newComponent.rows.count {
                        selectRow(newComponent.rows.endIndex - 1, inComponent: index, animated: false)
                    }
                }
                reloadAllComponents()
                for (index, newComponent) in newValue.enumerated() {
                    if selectedRow(inComponent: index) != newComponent.selectedRow {
                        selectRow(newComponent.selectedRow, inComponent: index, animated: true)
                    }
                }
            }
        }
    }
    
    fileprivate var defaultDataSource: DataSource {
        return storage[\.defaultDataSource, default: DataSource()]
    }
    
    fileprivate var defaultDelegate: Delegate {
        return storage[\.defaultDelegate, default: Delegate()]
    }
    
}

private class DataSource : NSObject, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerView.components.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.components[component].rows.count
    }
    
}

extension Array {
    
    /* A safe helper because UIPickerView seems to make out-of-range requests */
    fileprivate func get(_ index: Int) -> Element? {
        guard index < endIndex else { return nil }
        return self[index]
    }
    
}

private class Delegate : NSObject, UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView.components[component].rows.get(row)?.content.title
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return pickerView.components[component].rows.get(row)?.content.attributedTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.components[component].rows[row].didSelect?()
    }
    
}
