//
//  CollectionCell.swift
//  Table
//
//  Created by Bradley Hilton on 6/18/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

private var reuseIdentifiers: [UniqueDeclaration: String] = [:]

public struct CollectionCell {
    
    let uniqueDeclaration: UniqueDeclaration
    let cellClass: UICollectionViewCell.Type
    let update: (UICollectionViewCell) -> ()
    
    public init<Cell : UICollectionViewCell>(
        file: String = #file,
        line: Int = #line,
        column: Int = #column,
        class: Cell.Type = Cell.self,
        update: @escaping (Cell) -> () = { _ in }
    ) {
        self.uniqueDeclaration = UniqueDeclaration(file: file, line: line, column: column)
        self.cellClass = `class`
        self.update = { cell in
            guard let cell = cell as? Cell else { return }
            update(cell)
        }
    }
    
    var reuseIdentifier: String {
        guard let reuseIdentifier = reuseIdentifiers[uniqueDeclaration] else {
            let reuseIdentifier = "\(uniqueDeclaration.file):\(uniqueDeclaration.line):\(uniqueDeclaration.column)"
            reuseIdentifiers[uniqueDeclaration] = reuseIdentifier
            return reuseIdentifier
        }
        return reuseIdentifier
    }
    
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        registerCellIfNeeded(for: collectionView)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        UIView.performWithoutAnimation { update(cell) }
        return cell
    }
    
    func registerCellIfNeeded(for collectionView: UICollectionView) {
        if !collectionView.reuseIdentifiers.contains(reuseIdentifier) {
            let nibName = String(describing: cellClass)
            if Bundle.main.path(forResource: nibName, ofType: "nib") != nil {
                collectionView.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
            } else {
                collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
            }
            collectionView.reuseIdentifiers.insert(reuseIdentifier)
        }
    }
    
}

