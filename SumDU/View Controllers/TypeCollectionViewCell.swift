//
//  TypeCollectionViewCell.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/7/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Cartography
import UIKit

class TypeCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "\(TypeCollectionViewCell.self)"
    
    // MARK: - Variables
    
    override var selected: Bool {
        didSet {
            if selected {
                tableView.hidden = true
                historyImage.hidden = false
            } else {
                tableView.hidden = false
                historyImage.hidden = true
            }
        }
    }
    
    // MARK: - UI Objects
    
    private let tableView = UITableView()
    private let historyImage = UIImageView()
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // History image
        contentView.addSubview(historyImage)
        historyImage.image = UIImage(named: "historyImage")
        constrain(historyImage, contentView) { historyImage, superview in
            historyImage.edges == superview.edges
        }
        // Table
        tableView.registerClass(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .None
        contentView.addSubview(tableView)
        constrain(tableView, contentView) { tableView, superview in
            tableView.edges == superview.edges
        }
    }
}