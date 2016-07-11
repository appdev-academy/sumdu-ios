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
    
    // MARK: - Variables
    
    override var selected: Bool {
        didSet {
            if historyImage.superview == contentView {
                historyImage.image = selected ? activeHistoryImage : inactiveHistoryImage
            } else {
                textLabel.textColor = selected ? colorForSelectedObjects : defaultColorForObjects
            }
        }
    }
    
    // MARK: - UI objects
    
    private let activeHistoryImage = UIImage(named:"activeHistory")
    private let inactiveHistoryImage = UIImage(named:"inactiveHistory")
    private let textLabel = UILabel()
    private let historyImage = UIImageView()
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.whiteColor()
    }
    
    // MARK: - Interface
    
    func addImage() {
        
        // TODO: Fix it
        
        contentView.addSubview(historyImage)
        
        historyImage.image = inactiveHistoryImage
        
        constrain(historyImage) {
            historyImage in
            
            historyImage.centerX == historyImage.superview!.centerX
            historyImage.centerY == historyImage.superview!.centerY
            
        }
    }
    
    func addTitle(titleText: String) {
        
        // TODO: Fix it
        
        textLabel.font = titleTextFont
        textLabel.textColor = defaultColorForObjects
        contentView.addSubview(textLabel)
        
        textLabel.text = titleText
        
        constrain(textLabel) {
            textLabel in
            
            textLabel.centerX == textLabel.superview!.centerX
            textLabel.centerY == textLabel.superview!.centerY
        }
    }
}