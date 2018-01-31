//
//  PerformanceTests.swift
//  Table
//
//  Created by Bradley Hilton on 1/19/17.
//  Copyright © 2017 Brad Hilton. All rights reserved.
//

import XCTest
import Table

class Controller : UITableViewController {
    
    func refresh() {
        tableView.beginUpdates()
//        tableView.moveRow(at: IndexPath(row: 1, section: 0), to: IndexPath(row: 0, section: 0))
//        tableView.moveRow(at: IndexPath(row: 2, section: 0), to: IndexPath(row: 1, section: 0))
//        tableView.moveRow(at: IndexPath(row: 3, section: 0), to: IndexPath(row: 2, section: 0))
        tableView.moveRow(at: IndexPath(row: 0, section: 0), to: IndexPath(row: 3, section: 0))
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
}

class PerformanceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        let tables = randomlyEvolvingTables(sections: 10, evolutions: 10)
        let tableView = UITableView()
        self.measure {
            for table in tables {
                tableView.table = table
            }
        }
    }
    
    func testPerform() {
        let controller = Controller()
        self.measure {
            for _ in 0..<100 {
                controller.refresh()
            }
        }
    }
    
}

func times() -> Int {
    return 9 - Int(log(Double(arc4random_uniform(UInt32(pow(2.7, 10))))))
}

func evolve(evolve: () -> ()) {
    (0..<times()).forEach { _ in evolve() }
}

extension String {
    
    static var random: String {
        return UUID().uuidString
    }
    
}

extension UInt32 {
    
    static var random: UInt32 {
        return arc4random()
    }
    
}

extension Array {
    
    var randomIndex: Int {
        return Int(arc4random_uniform(UInt32(count)))
    }
    
}

func randomlyEvolvingTables(sections: Int, evolutions: Int) -> [Table] {
    let randomSection = { (identifier: String.random, headerTitle: String.random, rank: UInt32.random) }
    var sections = (0..<sections).map { _ in randomSection() }
    let randomRow = { (identifier: String.random, reloadKey: String.random, section: sections[sections.randomIndex].identifier, rank: UInt32.random) }
    var rows = (0..<(sections.count * sections.count)).map { _ in randomRow() }
    var tables = [Table]()
    for _ in 0..<evolutions {
        evolve { sections.remove(at: sections.randomIndex) }
        evolve { sections.insert(randomSection(), at: sections.randomIndex) }
        evolve { sections[sections.randomIndex].headerTitle = String.random }
        evolve { sections[sections.randomIndex].rank = UInt32.random }
        for _ in sections {
            evolve { rows.remove(at: sections.randomIndex) }
            evolve { rows.insert(randomRow(), at: rows.randomIndex) }
            evolve { rows[rows.randomIndex].reloadKey = String.random }
            evolve { rows[rows.randomIndex].rank = UInt32.random }
        }
        tables.append(
            Table(
                sections.sorted { $0.rank < $1.rank }.map { description in
                    Section { section in
                        section.key = description.identifier
                        section.headerTitle = description.headerTitle
                        section.children = rows.filter { $0.section == description.identifier }.sorted { $0.rank < $1.rank }.map { description in
                            Row { row in
                                row.key = description.identifier
                                row.cell = Cell(reloadKey: description.reloadKey)
                            }
                        }
                    }
                }
            )
        )
    }
    return tables
}
