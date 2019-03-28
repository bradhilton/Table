//
//  Data.swift
//  Table
//
//  Created by Bradley Hilton on 1/24/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

struct SectionKey : Hashable, CustomStringConvertible {
    let section: Int
    var description: String {
        return "Section: \(section)"
    }
}

struct RowKey : Hashable, CustomStringConvertible {
    let sectionKey: AnyHashable
    let row: Int
    var description: String {
        return "\(sectionKey) - Row: \(row)"
    }
}

private func setIdentifiers(_ sections: inout [Section]) {
    var sectionNumber = 0
    sections.mutatingEach { (section: inout Section) in
        if section.key == .auto {
            section.key = SectionKey(section: sectionNumber)
            sectionNumber += 1
        }
        var rowNumber = 0
        section.rows.mutatingEach { (row: inout Row) in
            if row.key == .auto {
                row.key = RowKey(sectionKey: section.key, row: rowNumber)
                rowNumber += 1
            }
        }
    }
}

struct Data {
    var sections: [Section]
    let sectionsByKey: [AnyHashable: Int]
    let rowsByKey: [AnyHashable: IndexPath]
    
    init(sections: [Section]) {
        var sections = sections
        setIdentifiers(&sections)
        self.sections = sections
        self.sectionsByKey = Dictionary(uniqueKeysWithValues: zip(sections, sections.indices).map { ($0.key, $1) })
        self.rowsByKey = Dictionary(
            uniqueKeysWithValues: zip(sections, sections.indices).flatMap { section, sectionIndex in
                return zip(section.rows, section.rows.indices).map { row, rowIndex in
                    return (row.key, IndexPath(row: rowIndex, section: sectionIndex))
                }
            }
        )
    }
    
    subscript(section: Int) -> Section {
        return sections[section]
    }
    
    subscript(indexPath: IndexPath) -> Row {
        return sections[indexPath.section].rows[indexPath.row]
    }
    
}
