
class Source : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    unowned let tableView: UITableView
    
    var movingRow: Row?
    var moving = false
    
    func setData(_ newValue: Data, animated: Bool) {
        guard movingRow == nil else {
            return data = newValue
        }
        guard animated else {
            data = newValue
            return tableView.reloadData()
        }
        if let indexPaths = tableView.indexPathsForVisibleRows {
            let rowReloads: [IndexPath] = indexPaths
                .map { indexPath in
                    (indexPath, data.sections[indexPath.section].rows[indexPath.row])
                }.flatMap { indexPath, row in
                    newValue.rowsByKey[row.key].map { (indexPath, row, newValue.sections[$0.section].rows[$0.row]) }
                }.flatMap { indexPath, oldRow, newRow in
                    if (oldRow.cell.reuseIdentifier == newRow.cell.reuseIdentifier) {
                        tableView.cellForRow(at: indexPath).map { newRow.cell.configure($0) }
                        return nil
                    } else {
                        data.sections[indexPath.section].rows[indexPath.row] = newRow
                        return indexPath
                    }
                }
            tableView.reloadRows(at: rowReloads, with: .fade)
        }
        zip(data.sections, data.sections.indices)
            .flatMap { (section, index) -> (Section, Int)? in
                return newValue.sectionsByKey[section.key].map { (sectionIndex) -> (Section, Int) in
                    return (newValue.sections[sectionIndex], index)
                }
            }.forEach { section, index in
                func updateHeaderFooterView(_ view: UITableViewHeaderFooterView?, title: String?) {
                    if let view = view, let title = title {
                        view.textLabel?.text = title
                        view.textLabel?.sizeToFit()
                    }
                }
                updateHeaderFooterView(tableView.headerView(forSection: index), title: section.headerTitle)
                updateHeaderFooterView(tableView.footerView(forSection: index), title: section.footerTitle)
            }
        let delta = SectionsDelta(from: data.sections, to: newValue.sections)
        let animation = UITableViewRowAnimation.fade
        tableView.beginUpdates()
        data = newValue
        print("")
        print(delta.sectionDeletes.map { $0 })
        print(delta.sectionInserts.map { $0 })
        print(delta.sectionMoves)
        print(delta.rowDeletes)
        print(delta.rowInserts)
        print(delta.rowMoves)
        tableView.deleteSections(delta.sectionDeletes, with: animation)
        tableView.insertSections(delta.sectionInserts, with: animation)
        delta.sectionMoves.forEach { tableView.moveSection($0, toSection: $1) }
        tableView.deleteRows(at: delta.rowDeletes, with: animation)
        tableView.insertRows(at: delta.rowInserts, with: animation)
        delta.rowMoves.forEach { tableView.moveRow(at: $0, to: $1) }
        tableView.endUpdates()
    }
    
    internal private(set) var data: Data
    
    init(tableView: UITableView, data: Data) {
        self.tableView = tableView
        self.data = data
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return data[indexPath].cell.cell(for: indexPath, in: tableView)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].headerTitle
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return data[section].footerTitle
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return data[indexPath].canEdit
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return data[indexPath].commitMove != nil
    }
    
//    #if os(iOS)
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return data.indexTitles
//    }
//
//    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        var indexLookup: [String: Int] = [:]
//        for (index, section) in data.sections.enumerated() {
//            guard let indexTitle = section.indexTitle else { continue }
//            if indexTitle == title {
//                return index
//            }
//            indexLookup[indexTitle] = index
//        }
//        let indexTitles = data.indexTitles ?? []
//        for title in indexTitles[index..<indexTitles.endIndex] {
//            guard let index = indexLookup[title] else { continue }
//            return index
//        }
//        return max(data.sections.endIndex - 1, 0)
//    }
//    #endif

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: data[indexPath].commitDelete?()
        case .insert: data[indexPath].commitInsert?()
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        movingRow = nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return data[indexPath].height ?? tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return data[indexPath].estimatedHeight ?? tableView.estimatedRowHeight != 0 ? tableView.estimatedRowHeight : 44
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return data[indexPath].shouldSelect ? indexPath : nil
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return data[indexPath].shouldHighlight
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        data[indexPath].didHighlight?()
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        data[indexPath].didUnhighlight?()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let didTap = data[indexPath].didTap {
            didTap()
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            data[indexPath].didSelect?()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        data[indexPath].didDeselect?()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return data[indexPath].editingStyle
    }
    
    #if os(iOS)
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return data[indexPath].deleteConfirmationButtonTitle
    }
    #endif

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return data[indexPath].editingStyle != .none
    }

    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return data[indexPath].indentation
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let movingRow = self.movingRow ?? { self.movingRow = data[sourceIndexPath]; return self.movingRow! }()
        movingRow.commitMove?(
            data[proposedDestinationIndexPath.section].key,
            proposedDestinationIndexPath.row
        )
        for (s, section) in data.sections.enumerated() {
            for (r, row) in section.rows.enumerated() {
                if row.key == movingRow.key {
                    return IndexPath(row: r, section: s)
                }
            }
        }
        return sourceIndexPath
    }
    
}
