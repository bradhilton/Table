
func costEstimate(old: Data, new: Data) -> Int {
    let diffCost = old.rowsByKey.count + new.rowsByKey.count
    let minimumDeletes = max(old.rowsByKey.count - new.rowsByKey.count, 0)
    let minimumInserts = max(new.rowsByKey.count - old.rowsByKey.count, 0)
    let animationCost = max(minimumDeletes * 13, minimumInserts * 3)
    return (diffCost + animationCost) / 4
}

func animationCost(_ delta: SectionsDelta) -> Int {
    return (delta.rowDeletes.count * 13 + delta.rowInserts.count * 3) / 4
}

class Source : NSObject, UITableViewDelegate, UITableViewDataSource {
    
//    var movingRow: Row?
//    var moving = false
    
    func setData(_ newValue: Data, tableView: UITableView, animated: Bool) {
//        guard movingRow == nil else {
//            return data = newValue
//        }
        guard let indexPaths = tableView.indexPathsForVisibleRows, animated, costEstimate(old: data, new: newValue) < deviceBenchmark else {
            data = newValue
            return tableView.reloadData()
        }
        let delta = SectionsDelta(from: data.sections, to: newValue.sections)
        guard animationCost(delta) < deviceBenchmark else {
            data = newValue
            return tableView.reloadData()
        }
        let rowReloads: [IndexPath] = indexPaths
            .map { indexPath in
                (indexPath, data.sections[indexPath.section].rows[indexPath.row])
            }.compactMap { indexPath, row in
                newValue.rowsByKey[row.key].map { (indexPath, row, newValue.sections[$0.section].rows[$0.row]) }
            }.compactMap { indexPath, oldRow, newRow in
                if (oldRow.cell.reuseIdentifier == newRow.cell.reuseIdentifier) {
                    tableView.cellForRow(at: indexPath).map { newRow.cell.update($0) }
                    return nil
                } else {
                    data.sections[indexPath.section].rows[indexPath.row] = newRow
                    return indexPath
                }
            }
        if rowReloads.count > 0 || delta.isEmpty {
            tableView.reloadRows(at: rowReloads, with: .fade)
        }
        zip(data.sections, data.sections.indices)
            .compactMap { (section, index) -> (Section, Int)? in
                return newValue.sectionsByKey[section.key].map { (sectionIndex) -> (Section, Int) in
                    return (newValue.sections[sectionIndex], index)
                }
            }.forEach { section, index in
                func updateHeaderFooterView(_ view: UITableViewHeaderFooterView?, title: String?) {
                    if let view = view, let title = title {
                        view.textLabel?.numberOfLines = 1
                        view.textLabel?.text = tableView.style == .grouped ? title.uppercased() : title
                        view.textLabel?.sizeToFit()
                    }
                }
                updateHeaderFooterView(tableView.headerView(forSection: index), title: section.headerTitle)
                updateHeaderFooterView(tableView.footerView(forSection: index), title: section.footerTitle)
            }
        guard !delta.isEmpty else { return }
        if #available(iOS 11.0, *) {
            tableView.performBatchUpdates({
                update(tableView: tableView, delta: delta, newValue: newValue)
            })
        } else {
            tableView.beginUpdates()
            update(tableView: tableView, delta: delta, newValue: newValue)
            tableView.endUpdates()
        }
    }
    
    func update(tableView: UITableView, delta: SectionsDelta, newValue: Data) {
        let animation = UITableView.RowAnimation.fade
        data = newValue
        tableView.deleteSections(delta.sectionDeletes, with: animation)
        tableView.insertSections(delta.sectionInserts, with: animation)
        delta.sectionMoves.forEach { tableView.moveSection($0, toSection: $1) }
        tableView.deleteRows(at: delta.rowDeletes, with: animation)
        tableView.insertRows(at: delta.rowInserts, with: animation)
        delta.rowMoves.forEach { tableView.moveRow(at: $0, to: $1) }
    }
    
    internal private(set) var data: Data
    
    init(tableView: UITableView, data: Data) {
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
        let row = data[indexPath]
        return row.cell.cell(for: indexPath, in: tableView, with: row.key)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].headerTitle.map { tableView.style == .grouped ? $0.uppercased() : $0 }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return data[section].footerTitle.map { tableView.style == .grouped ? $0.uppercased() : $0 }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return data[indexPath].canEdit
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return data[indexPath].commitMove != nil
    }
    
    #if os(iOS)
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return tableView.sectionIndexTitles
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        var indices: [String: Int] = [:]
        for (index, section) in data.sections.enumerated() {
            guard let indexTitle = section.indexTitle else { continue }
            if indexTitle == title {
                return index
            }
            indices[indexTitle] = index
        }
        let indexTitles = tableView.sectionIndexTitles ?? []
        for title in indexTitles[index..<indexTitles.endIndex] {
            guard let index = indices[title] else { continue }
            return index
        }
        return max(data.sections.endIndex - 1, 0)
    }
    #endif
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: data[indexPath].commitDelete?()
        case .insert: data[indexPath].commitInsert?()
        default: break
        }
    }
    
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        movingRow = nil
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch data[indexPath].height {
        case .constant(let height):
            return height
        case .automatic:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch data[indexPath].height {
        case .constant(let height):
            return height
        case .automatic(estimated: let estimatedHeight):
            return estimatedHeight
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return data[section].headerTitle != nil
            ? tableView.style == .grouped ? 45 : 28
            : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return data[section].headerTitle != nil
            ? tableView.style == .grouped ? 45 : 28
            : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return data[section].footerTitle != nil ? 28 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return data[section].footerTitle != nil ? 28 : UITableView.automaticDimension
    }

    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        data[indexPath].cell.willDisplay(cell)
        cell.didEndDisplaying = data[indexPath].cell.didEndDisplaying
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.didEndDisplaying(cell)
        cell.didEndDisplaying = { _ in }
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
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

//    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
//        let movingRow = self.movingRow ?? { self.movingRow = data[sourceIndexPath]; return self.movingRow! }()
//        movingRow.commitMove?(
//            data[proposedDestinationIndexPath.section].key,
//            proposedDestinationIndexPath.row
//        )
//        for (s, section) in data.sections.enumerated() {
//            for (r, row) in section.rows.enumerated() {
//                if row.key == movingRow.key {
//                    return IndexPath(row: r, section: s)
//                }
//            }
//        }
//        return sourceIndexPath
//    }
    
}
