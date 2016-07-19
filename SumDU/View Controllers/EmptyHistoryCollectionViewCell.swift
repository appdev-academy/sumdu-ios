//
//  EmptyHistoryCollectionViewCell.swift
//  SumDU
//
//  Created by Yura Voevodin on 19.07.16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Cartography
import UIKit

class EmptyHistoryCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "\(EmptyHistoryCollectionViewCell.self)"
    
    // MARK: - UI objects
    
    private let historyImage = UIImageView()
    private let emptyHistoryLabel = UILabel()
    private let emptyHistoryDescriptionLabel = UILabel()
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Image
        historyImage.contentMode = .ScaleAspectFill
        historyImage.clipsToBounds = true
        contentView.addSubview(historyImage)
        historyImage.image = UIImage(named: "empty_history")
        constrain(historyImage, contentView) {
            historyImage, superview in
            
            historyImage.top == superview.top + 46.0
            historyImage.centerX == superview.centerX
        }
        
        // Label
        emptyHistoryLabel.text = NSLocalizedString("History is empty", comment: "")
        emptyHistoryLabel.font = FontManager.getFont(name: FontName.HelveticaNeueMedium, size: 20)
        emptyHistoryLabel.textColor = Color.textNormal
        emptyHistoryLabel.textAlignment = .Center
        contentView.addSubview(emptyHistoryLabel)
        constrain(historyImage, emptyHistoryLabel, contentView) {
            historyImage, emptyHistoryLabel, superview in
            
            emptyHistoryLabel.top == historyImage.bottom + 35.0
            emptyHistoryLabel.leading == superview.leading + 14.0
            emptyHistoryLabel.trailing == superview.trailing - 14.0
        }
        
        // Description
        emptyHistoryDescriptionLabel.text = NSLocalizedString("Swipe the screen left and right to navigate between the main sections and the search schedule", comment: "")
        emptyHistoryDescriptionLabel.font = FontManager.getFont(name: FontName.HelveticaNeueMedium, size: 15.0)
        emptyHistoryDescriptionLabel.textColor = Color.textLight
        emptyHistoryDescriptionLabel.textAlignment = .Center
        emptyHistoryDescriptionLabel.numberOfLines = 0
        contentView.addSubview(emptyHistoryDescriptionLabel)
        constrain(emptyHistoryDescriptionLabel, emptyHistoryLabel, contentView) {
            emptyHistoryDescriptionLabel, emptyHistoryLabel, superview in
            
            emptyHistoryDescriptionLabel.top == emptyHistoryLabel.bottom + 8.0
            emptyHistoryDescriptionLabel.leading == superview.leading + 33.0
            emptyHistoryDescriptionLabel.trailing == superview.trailing - 33.0
            emptyHistoryDescriptionLabel.bottom == superview.bottom - 14.0
        }
    }
}