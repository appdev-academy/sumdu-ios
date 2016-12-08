//
//  MenuCollectionViewCell.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/7/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Cartography
import UIKit

class MenuCollectionViewCell: UICollectionViewCell {
  
  // MARK: - Constants
  
  static let reuseIdentifier = "\(MenuCollectionViewCell.self)"
  static let cellHeight: CGFloat = 62.0
  
  // MARK: - Variables
  
  override var isSelected: Bool {
    didSet {
      textLabel.textColor = isSelected ? Color.textBlack : Color.textLight
    }
  }
  
  // MARK: - UI objects
  
  fileprivate let textLabel = UILabel()
  
  // MARK: - Initialization
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    // Background
    backgroundColor = UIColor.white
    
    // Title
    textLabel.font = Font.named(.helveticaNeueMedium, size: 17.0)
    textLabel.textColor = Color.textLight
    textLabel.textAlignment = .center
    contentView.addSubview(textLabel)
    constrain(textLabel, contentView) {
      textLabel, superview in
      
      textLabel.edges == superview.edges
    }
  }
  
  // MARK: - Public interface
  
  func update(withTitle title: String) {
    textLabel.text = title
  }
}
