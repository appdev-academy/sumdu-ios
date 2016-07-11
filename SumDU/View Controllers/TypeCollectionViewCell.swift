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
    
    private var data: [ListData] = []
    private var search = false
    private var searchText: String?
    
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
        historyImage.hidden = true
        contentView.addSubview(historyImage)
        historyImage.image = UIImage(named: "historyImage")
        constrain(historyImage, contentView) { historyImage, superview in
            historyImage.edges == superview.edges
        }
        // Table
        tableView.registerClass(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .None
        tableView.delegate = self
        tableView.dataSource = self
        contentView.addSubview(tableView)
        constrain(tableView, contentView) { tableView, superview in
            tableView.edges == superview.edges
        }
    }
    
    // MARK: - Interface
    
    func update(with data: [ListData], search: Bool, searchText: String?) {
        self.search = search
        self.searchText = searchText
        self.data = data
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension TypeCollectionViewCell: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SearchTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! SearchTableViewCell
        cell.update(with: data[indexPath.row], search: search, searchingText: searchText)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TypeCollectionViewCell: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: Implement logic
    }
}