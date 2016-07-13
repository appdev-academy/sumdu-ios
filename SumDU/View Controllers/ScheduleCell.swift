//
//  ScheduleCell.swift
//  SumDU
//
//  Created by Yura on 26.12.15.
//  Copyright © 2015 AppDecAcademy. All rights reserved.
//

import Cartography
import UIKit

class ScheduleCell: UITableViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "\(ScheduleCell.self)"
    static let cellHeight: CGFloat = 44.0
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialSetup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.initialSetup()
    }
    
    // MARK: - Helpers
    
    private func initialSetup() {
        
    }
    
    // MARK: - Interface
    
    //// Update cell data
    func updateWithData() {
        
    }
}