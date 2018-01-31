//
//  ScheduleController.swift
//  Table
//
//  Created by Bradley Hilton on 1/20/17.
//  Copyright © 2017 Brad Hilton. All rights reserved.
//

import Table

func random(_ maxRepeat: UInt32, block: () -> ()) {
    for _ in 0..<arc4random_uniform(maxRepeat) {
        block()
    }
}

func random<T>(_ source: [T]) -> T {
    return source[Int(arc4random_uniform(UInt32(source.count)))]
}

extension Dictionary {
    
    var randomKey: Key {
        return random(Array(keys))
    }
    
}

extension Bool {
    
    static var random: Bool {
        return arc4random_uniform(2) == 0
    }
    
}

extension Array {
    
    var random: Element {
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
    
}

enum Period : String {
    case A1, A2, A3, A4, B1, B2, B3, B4
    static let all = [Period.A1, .A2, .A3, .A4, .B1, .B2, .B3, .B4]
}

struct Class {
    var period: Period
    var active: Bool
}

enum Grade : String {
    case A, B, C, D, F
    static let all = [Grade.A, .B, .C, .D, .F]
}

struct Student {
    var `class`: String
    var grade: Grade
}

class ScheduleController : UITableViewController {
    
    var classes: [String: Class] = [
        "Physics": Class(period: .A1, active: true),
        "Chemistry": Class(period: .A2, active: false),
        "English": Class(period: .A3, active: true),
        "Humanities": Class(period: .A4, active: false),
        "Orchestra": Class(period: .B1, active: true),
        "Seminary": Class(period: .B2, active: false),
        "Calculus": Class(period: .B3, active: true),
        "Russian": Class(period: .B4, active: false)
    ]
    
    var students: [String: Student] = [
        "Brad": Student(class: "Physics", grade: .A),
        "David": Student(class: "English", grade: .A),
        "Lorraine": Student(class: "Orchestra", grade: .B),
        "Natalie": Student(class: "Orchestra", grade: .C),
        "Ivonne": Student(class: "Humanities", grade: .D),
        "Sarah": Student(class: "Seminary", grade: .C),
        "Nathan": Student(class: "Calculus", grade: .D),
        "Eric": Student(class: "Calculus", grade: .F),
        "Joey": Student(class: "Russian", grade: .A),
        "Kendra": Student(class: "Chemistry", grade: .A),
        "Joshua": Student(class: "Russian", grade: .B),
        "Emily": Student(class: "Calculus", grade: .C),
        "Patrick": Student(class: "Chemistry", grade: .D),
        "Louis": Student(class: "Calculus", grade: .F),
        "Larry": Student(class: "English", grade: .C),
        "Max": Student(class: "Seminary", grade: .F)
    ]
    
    var schedule: [(String, Class, [(String, Student)])] = [] {
        didSet {
            print("\n")
            for (className, `class`, students) in schedule {
                print("\n\(className): \(`class`.period)")
                for (studentName, student) in students {
                    print("\(studentName): \(student.grade)")
                }
            }
            tableView.sections = schedule.map { (className, `class`, students) in
                Section { section in
                    section.key = className
                    section.sortKey = `class`.period
                    section.headerTitle = "\(className): \(`class`.period)"
                    section.rows = students.map { (studentName, student) in
                        Row { row in
                            row.key = studentName
                            row.sortKey = student.grade
                            row.cell = Cell { cell in
                                cell.textLabel?.text = "\(studentName): \(student.grade)"
                            }
                            row.deleteConfirmationButtonTitle = "Remove"
                            row.commitDelete = { [unowned self] in
                                self.students[studentName]?.class = ""
                                self.updateSchedule()
                            }
                            row.commitMove = { [unowned self] `class`, _ in
                                self.students[studentName]?.class = (`class`.base as? String) ?? ""
                                self.updateSchedule()
                            }
                        }
                    }
                }
            }
        }
    }
    
    init() {
        super.init(style: .plain)
        title = "Schedule"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 44
        tableView.estimatedRowHeight = 44
        tableView.estimatedSectionHeaderHeight = 0
        navigationItem.rightBarButtonItems = [editButtonItem, UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))]
    }
    
    @objc func refresh() {
        randomize()
        updateSchedule()
    }
    
    func randomize() {
        random(4) { classes[classes.randomKey]!.active = .random }
        random(4) { classes[classes.randomKey]!.period = Period.all.random }
        random(12) { students[students.randomKey]!.class = Array(classes.keys).random }
        random(12) { students[students.randomKey]!.grade = Grade.all.random }
    }
    
    func updateSchedule() {
        schedule = (classes.filter { $1.active } as [(String, Class)])
            .sorted { $0.1.period.rawValue < $1.1.period.rawValue }
            .map { className, `class` in
            var students = [(String, Student)]()
            for (studentName, student) in self.students.sorted(by: { lhs, rhs in
                lhs.value.grade.rawValue < rhs.value.grade.rawValue
            }) {
                if student.class == className {
                    students.append((studentName, student))
                }
            }
            return (className, `class`, students)
        }
    }
    
}
