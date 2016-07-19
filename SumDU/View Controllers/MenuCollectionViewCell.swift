//
//  MenuCollectionViewCell.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/7/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Cartography
import UIKit

class MenuCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "\(MenuCollectionViewCell.self)"
    static let cellHeight: CGFloat = 62.0
    
    // MARK: - Variables
    
    override var selected: Bool {
        didSet {
            textLabel.textColor = selected ? Color.textBlack : Color.textLight
        }
    }
    
    // MARK: - UI objects
    
    private let textLabel = UILabel()
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Background
        backgroundColor = UIColor.whiteColor()
        
        // Title
        textLabel.font = FontManager.getFont(name: FontName.HelveticaNeueMedium, size: 17.0)
        textLabel.textColor = Color.textLight
        textLabel.textAlignment = .Center
        contentView.addSubview(textLabel)
        constrain(textLabel, contentView) { textLabel, superview in
            textLabel.edges == superview.edges
        }
    }
    
    // MARK: - Public interface
    
    func update(withTitle title: String) {
        textLabel.text = title
    }
}