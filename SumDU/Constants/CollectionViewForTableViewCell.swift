//
//  CollectionViewForTableViewCell.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/7/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Foundation
import UIKit
import Cartography

class CollectionViewForTableViewCell: UICollectionViewCell {
    
    // MARK: - Variables
    
    private var group = ConstraintGroup()
    
    override var selected: Bool {
        didSet {
            
            if self.selected == true {
                self.addImage()
                self.removeTableView()
            } else {
                self.removeImage()
                self.addTableView()
            }
        }
    }
    
    // MARK: - UI Objects
    
    var tableView = UITableView(frame: CGRectZero)
    private var historyImagePicture = UIImage(named: "historyImage")
    
    private let historyImage = UIImageView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    private func addImage() {
        
        self.contentView.addSubview(self.historyImage)
        self.historyImage.image = self.historyImagePicture
        
        constrain(self.historyImage, replace: self.group) {
            historyImage in
            
            historyImage.width == historyImage.superview!.width
            historyImage.height == historyImage.superview!.height
            historyImage.trailing == historyImage.superview!.trailing
            historyImage.centerY == historyImage.superview!.centerY
        }
    }
    
    private func addTableView() {
        
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "tableViewCell")
        
        self.addSubview(self.tableView)
        
        constrain(self.tableView, replace: self.group) {
            tableView in
            
            tableView.leading == tableView.superview!.leading
            tableView.trailing == tableView.superview!.trailing
            tableView.top == tableView.superview!.top
            tableView.bottom == tableView.superview!.bottom
        }
    }
    
    private func removeImage() {
        
        if self.historyImage.superview == self {
            self.historyImage.removeFromSuperview()
        }
    }
    
    private func removeTableView() {
        
        if self.tableView.superview == self {
            self.tableView.removeFromSuperview()
        }
    }
    
}