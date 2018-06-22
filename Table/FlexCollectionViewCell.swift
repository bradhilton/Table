//
//  FlexCollectionViewCell.swift
//  Table
//
//  Created by Bradley Hilton on 4/25/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public class FlexCollectionViewCell : UICollectionViewCell {
    
    public var child: Flex {
        get {
            return flexView.child
        }
        set {
            flexView.child = newValue
        }
    }
    
    private let flexView = FlexView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(flexView)
        flexView.translatesAutoresizingMaskIntoConstraints = false
        flexView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        flexView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        flexView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        flexView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
