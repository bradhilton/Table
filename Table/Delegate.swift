
class Delegate : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    weak var tableView: UITableView?
    
    var movingRow: Row?
    var moving = false

    var table: Table {
        didSet {
            setUpTable(&table, oldValue: oldValue)
            guard movingRow == nil else { return }
            let tableAnimations = TableAnimations(old: oldValue, new: table)
            let defaultAnimation = UITableViewRowAnimation.fade
            tableView?.beginUpdates()
            tableView?.deleteSections(tableAnimations.sectionDeletes, with: defaultAnimation)
            tableView?.insertSections(tableAnimations.sectionInserts, with: defaultAnimation)
            tableAnimations.sectionMoves.forEach { tableView?.moveSection($0, toSection: $1) }
            tableView?.deleteRows(at: tableAnimations.rowDeletes, with: defaultAnimation)
            tableView?.insertRows(at: tableAnimations.rowInserts, with: defaultAnimation)
            tableAnimations.rowMoves.forEach { tableView?.moveRow(at: $0, to: $1) }
            tableView?.endUpdates()
            if (table._indexTitles ?? []) != (oldValue._indexTitles ?? []) {
                tableView?.reloadSectionIndexTitles()
            }
        }
    }
    
    func setUpTable(_ table: inout Table, oldValue: Table? = nil) {
        setIdentifiers(table: &table)
        ensureIdentifiersAreUnique(table: table)
        if let oldValue = oldValue {
            identifySectionReloads(new: &table, old: oldValue)
            identifyRowReloads(new: &table, old: oldValue)
        }
    }
    
    private func setIdentifiers(table: inout Table) {
        var sectionNumber = 0
        table.sections.mutatingEach { (section: inout Section) in
            if section.identifier.isEmpty {
                section.identifier = "Section: \(sectionNumber)"
                defer {
                    sectionNumber += 1
                }
            }
            var rowNumber = 0
            section.rows.mutatingEach { (row: inout Row) in
                if row.identifier.isEmpty {
                    row.identifier = "\(section.identifier) - Row: \(rowNumber)"
                    rowNumber += 1
                }
            }
        }
    }
    
    private func ensureIdentifiersAreUnique(table: Table) {
        let message = "Table sections and rows identifiers must be unique."
        var sections = Set<String>()
        for section in table.sections {
            if case (false, _) = sections.insert(section.identifier) {
                fatalError(message)
            }
        }
        var rows = Set<String>()
        for row in table.sections.flatMap({ $0.rows }) {
            if case (false, _) = rows.insert(row.identifier) {
                fatalError(message)
            }
        }
    }
    
    private func identifySectionReloads(new: inout Table, old: Table) {
        let reloadKey: (Section) -> String = { "\($0.headerTitle) \($0.footerTitle)" }
        let reloadLookup = Dictionary(old.sections.lazy.map { ($0.identifier, reloadKey($0)) })
        new.sections.mutatingEach { (section: inout Section) in
            if let previousReloadKey = reloadLookup[section.identifier], previousReloadKey != reloadKey(section) {
                section.reload = true
            }
        }
    }
    
    private func identifyRowReloads(new: inout Table, old: Table) {
        let reloadKeyLookup = Dictionary(
            old.sections.flatMap { $0.rows }.map { ($0.identifier, $0.cell.reloadKey) }
        )
        new.sections.mutatingEach { (section: inout Section) in
            section.rows.mutatingEach { (row: inout Row) in
                guard let reloadKey = reloadKeyLookup[row.identifier] else { return }
                row.reload = row.cell.reloadKey != reloadKey
            }
        }
    }
    
    init(tableView: UITableView, table: Table) {
        self.tableView = tableView
        self.table = table
        super.init()
        setUpTable(&self.table)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return table.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return table[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return table[indexPath].cell.cell(for: indexPath, in: tableView)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return table[section].headerTitle
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return table[section].footerTitle
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return table[indexPath].canEdit
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return table[indexPath].commitMove != nil
    }
    
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return table._indexTitles
//    }
//    
//    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        var indexLookup: [String: Int] = [:]
//        for (index, section) in table.sections.enumerated() {
//            guard let indexTitle = section.indexTitle else { continue }
//            if indexTitle == title {
//                return index
//            }
//            indexLookup[indexTitle] = index
//        }
//        let indexTitles = table._indexTitles ?? []
//        for title in indexTitles[index..<indexTitles.endIndex] {
//            guard let index = indexLookup[title] else { continue }
//            return index
//        }
//        return max(table.sections.endIndex - 1, 0)
//    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: table[indexPath].commitDelete?()
        case .insert: table[indexPath].commitInsert?()
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        movingRow = nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return table[indexPath].height ?? tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return table[indexPath].estimatedHeight ?? tableView.estimatedRowHeight
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return table[indexPath].shouldSelect ? indexPath : nil
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return table[indexPath].shouldHighlight
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        table[indexPath].didHighlight?()
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        table[indexPath].didUnhighlight?()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let didTap = table[indexPath].didTap {
            didTap()
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            table[indexPath].didSelect?()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        table[indexPath].didDeselect?()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return table[indexPath].editingStyle
    }
    
//    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
//        return table[indexPath].deleteConfirmationButtonTitle
//    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return table[indexPath].editingStyle != .none
    }

    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return table[indexPath].indentation
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let movingRow = self.movingRow ?? { self.movingRow = table[sourceIndexPath]; return self.movingRow! }()
        movingRow.commitMove?(
            table[proposedDestinationIndexPath.section].identifier,
            proposedDestinationIndexPath.row
        )
        for (s, section) in table.sections.enumerated() {
            for (r, row) in section.rows.enumerated() {
                if row.identifier == movingRow.identifier {
                    return IndexPath(row: r, section: s)
                }
            }
        }
        return sourceIndexPath
    }
    
}
