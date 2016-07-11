//
//  MenuCollectionViewCell.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/7/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Foundation
import UIKit
import Cartography

class MenuCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "\(MenuCollectionViewCell.self)"
    static let cellHeight: CGFloat = 62.0
    static let historyImageSize = CGSize(width: 24.0, height: 24.0)
    
    // MARK: - Variables
    
    private var isHistory: Bool = false {
        didSet {
            if isHistory {
                textLabel.hidden = true
                historyImageView.hidden = false
            } else {
                textLabel.hidden = false
                historyImageView.hidden = true
            }
        }
    }
    
    override var selected: Bool {
        didSet {
            if isHistory {
                historyImageView.image = selected ? activeHistoryImage : inactiveHistoryImage
            } else {
                textLabel.textColor = selected ? colorForSelectedObjects : defaultColorForObjects
            }
        }
    }
    
    // MARK: - UI objects
    
    private let activeHistoryImage = UIImage(named:"activeHistory")
    private let inactiveHistoryImage = UIImage(named:"inactiveHistory")
    private let textLabel = UILabel()
    private let historyImageView = UIImageView()
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Background
        backgroundColor = UIColor.whiteColor()
        
        // Title
        textLabel.font = titleTextFont
        textLabel.textColor = defaultColorForObjects
        contentView.addSubview(textLabel)
        constrain(textLabel, contentView) { textLabel, superview in
            textLabel.edges == superview.edges
        }
        
        // Image
        historyImageView.contentMode = .ScaleAspectFill
        historyImageView.clipsToBounds = true
        historyImageView.hidden = true
        contentView.addSubview(historyImageView)
        constrain(historyImageView, contentView) { historyImageView, superview in
            
            historyImageView.center == superview.center
            historyImageView.height == MenuCollectionViewCell.historyImageSize.height
            historyImageView.width == MenuCollectionViewCell.historyImageSize.width
        }
    }
    
    // MARK: - Interface
    
    func update(with title: String) {
        isHistory = false
        textLabel.text = title
    }
    
    func updateWithImage() {
        isHistory = true
        historyImageView.image = inactiveHistoryImage
    }
}