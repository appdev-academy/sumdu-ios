//
//  MenuImageCollectionViewCell.swift
//  SumDU
//
//  Created by Yura Voevodin on 18.07.16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Cartography
import UIKit

class MenuImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "\(MenuImageCollectionViewCell.self)"
    static let cellHeight: CGFloat = 62.0
    static let historyImageSize = CGSize(width: 24.0, height: 24.0)
    
    // MARK: - Variables
    
    override var selected: Bool {
        didSet {
            historyImageView.image = selected ? activeHistoryImage : inactiveHistoryImage
        }
    }
    
    // MARK: - UI objects
    
    private let activeHistoryImage = UIImage(named:"history_pressed")
    private let inactiveHistoryImage = UIImage(named:"history_normal")
    private let historyImageView = UIImageView()
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Background
        backgroundColor = UIColor.whiteColor()
        
        historyImageView.contentMode = .ScaleAspectFill
        historyImageView.clipsToBounds = true
        contentView.addSubview(historyImageView)
        constrain(historyImageView, contentView) {
            historyImageView, superview in
            
            historyImageView.center == superview.center
            historyImageView.height == MenuImageCollectionViewCell.historyImageSize.height
            historyImageView.width == MenuImageCollectionViewCell.historyImageSize.width
        }
    }
}