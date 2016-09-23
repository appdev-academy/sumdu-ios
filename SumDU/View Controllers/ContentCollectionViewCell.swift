//
//  ContentCollectionViewCell.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/7/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Cartography
import UIKit

class ContentCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "\(ContentCollectionViewCell.self)"
    
    // MARK: - UI Objects
    
    let contentTableView = UITableView()
    fileprivate let notFoudLabel = UILabel()
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        // Table
        contentTableView.register(ScheduleSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: ScheduleSectionHeaderView.reuseIdentifier)
        contentTableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.reuseIdentifier)
        contentTableView.separatorStyle = .none
        contentView.addSubview(contentTableView)
        constrain(contentTableView, contentView) {
            contentTableView, superview in
            
            contentTableView.edges == superview.edges
        }
        
        // Not found
        notFoudLabel.isHidden = true
        notFoudLabel.text = NSLocalizedString("No data found", comment: "")
        notFoudLabel.font = FontManager.getFont(name: FontName.helveticaNeueMedium, size: 20)
        notFoudLabel.textColor = Color.textNormal
        notFoudLabel.textAlignment = .center
        contentView.addSubview(notFoudLabel)
        constrain(notFoudLabel, contentView) {
            notFoudLabel, superview in
            
            notFoudLabel.top == superview.top + 66.0
            notFoudLabel.leading == superview.leading + 14.0
            notFoudLabel.trailing == superview.trailing - 14.0
        }
    }
    
    // MARK: - Public interface
    
    func showEmptySearch() {
        contentTableView.isHidden = true
        notFoudLabel.isHidden = false
    }
    
    func showContent() {
        notFoudLabel.isHidden = true
        contentTableView.isHidden = false
    }
}
