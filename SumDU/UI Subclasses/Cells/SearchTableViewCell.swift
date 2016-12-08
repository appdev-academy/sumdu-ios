//
//  SearchTableViewCell.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/7/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import UIKit
import Cartography

class SearchTableViewCell: UITableViewCell {
  
  // MARK: - Constants
  
  static let reuseIdentifier = "\(SearchTableViewCell.self)"
  static let cellHeight: CGFloat = 65.0
  
  // MARK: - UIObjects
  
  let label = UILabel()
  fileprivate let separatorLine = UIView()
  
  // MARK: - Initialization
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    // Separator
    separatorLine.backgroundColor = Color.separator
    contentView.addSubview(separatorLine)
    constrain(separatorLine, contentView) { separatorLine, superview in
      separatorLine.leading == superview.leading
      separatorLine.trailing == superview.trailing
      separatorLine.bottom == superview.bottom
      separatorLine.height == 1.0
    }
    // Text label
    label.textColor = Color.textNormal
    label.font = Font.named(.helveticaNeueMedium, size: 20.0)
    contentView.addSubview(label)
    constrain(label, separatorLine, contentView) {
      label, separatorLine, superview in
      
      label.top == superview.top
      label.leading == superview.leading + 14.0
      label.trailing == superview.trailing - 14.0
      label.bottom == separatorLine.top
    }
  }
  
}
