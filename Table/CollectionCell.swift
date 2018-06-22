//
//  CollectionCell.swift
//  Table
//
//  Created by Bradley Hilton on 6/18/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public struct CollectionCell {
    
    let file: String
    let function: String
    let line: Int
    let column: Int
    let cellClass: UICollectionViewCell.Type
    var reuseIdentifier: String {
        return "\(cellClass):\(file):\(function):\(line):\(column)"
    }
    let update: (UICollectionViewCell) -> ()
    
    public init<Cell : UICollectionViewCell>(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        column: Int = #column,
        class: Cell.Type = Cell.self,
        update: @escaping (Cell) -> () = { _ in }
    ) {
        self.file = file
        self.function = function
        self.line = line
        self.column = column
        self.cellClass = `class`
        self.update = { cell in
            guard let cell = cell as? Cell else { return }
            update(cell)
        }
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

