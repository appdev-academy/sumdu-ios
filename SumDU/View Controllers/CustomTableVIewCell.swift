//
//  CustomTableVIewCell.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/7/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import UIKit
import Cartography

class CustomTableVIewCell: UITableViewCell {

    // MARK: - UIObjects
    
    var label: UILabel = UILabel(frame: CGRectZero)
    
    private let separatorLine = UIView(frame: CGRectZero)
    
    private var group = ConstraintGroup()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.whiteColor()
        
        self.label.textColor = textColorForTableViewCell
        self.label.font = textFontForTableViewCell
        
        self.separatorLine.backgroundColor = lineColor
        
        self.addSubview(self.label)
        self.addSubview(self.separatorLine)
        
        self.setupConstraints()
    }
    
    private func setupConstraints() {
        
        constrain(self.label,self.separatorLine, replace: self.group) {
            label, separatorLine in
            
            label.height == 24.0
            label.leading == label.superview!.leading + 10
            //label.trailing == label.superview!.trailing - 10
            label.centerY == label.superview!.centerY
            
            separatorLine.height == 1.0
            separatorLine.leading == separatorLine.superview!.leading
            separatorLine.trailing == separatorLine.superview!.trailing
            separatorLine.bottom == separatorLine.superview!.bottom
        }
    }
    
}
