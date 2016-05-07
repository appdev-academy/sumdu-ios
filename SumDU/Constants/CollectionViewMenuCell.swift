//
//  CollectionViewMenuCell.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/7/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Foundation
import UIKit
import Cartography

class CollectionViewMenuCell: UICollectionViewCell {
    
    
    // MARK: - UI objects
    
    private let activeHistoryImage = UIImage(named:"activeHistory")
    private let inactiveHistoryImage = UIImage(named:"inactiveHistory")
    
    //MARK: - Variables
    
    override var selected: Bool {
        didSet {
            
            if self.historyImage.superview == self.contentView {
                self.historyImage.image = self.selected ? self.activeHistoryImage : self.inactiveHistoryImage
            } else {
                self.textLabel.textColor = self.selected ? colorForSelectedObjects : defaultColorForObjects
            }
        }
    }
    
    //MARK: - Constants
    
    let textLabel = UILabel(frame: CGRect.zero)
    let historyImage = UIImageView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor()
    }
    
    func addImage() {
        
        self.contentView.addSubview(self.historyImage)
        
        self.historyImage.image = self.inactiveHistoryImage
        
        constrain(self.historyImage) {
            historyImage in
            
            historyImage.centerX == historyImage.superview!.centerX
            historyImage.centerY == historyImage.superview!.centerY
            
        }
    }
    
    func addTitle(titleText: String) {
        
        self.textLabel.font = titleTextFont
        self.textLabel.textColor = defaultColorForObjects
        self.contentView.addSubview(self.textLabel)
        
        self.textLabel.text = titleText
        
        constrain(self.textLabel) {
            textLabel in
            
            textLabel.centerX == textLabel.superview!.centerX
            textLabel.centerY == textLabel.superview!.centerY
        }
    }
}