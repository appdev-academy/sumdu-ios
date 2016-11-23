//
//  ScheduleSectionHeaderView.swift
//  SumDU
//
//  Created by Yura Voevodin on 14.07.16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Cartography
import UIKit

class ScheduleSectionHeaderView: UITableViewHeaderFooterView {
  
  // MARK: - Constants
  
  static let reuseIdentifier = "\(ScheduleSectionHeaderView.self)"
  static let viewHeight: CGFloat = 30.0
  
  // MARK: - UI objects
  
  let dateLabel = UILabel()
  let dayLabel = UILabel()
  
  // MARK: - Lifecycle
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    
    let leadingMargin: CGFloat = 14.0
    let trailingMargin: CGFloat = 14.0
    
    contentView.backgroundColor = Color.backgroundGray
    
    // Date
    dateLabel.font = Font.named(.helveticaNeueMedium, size: 17.0)
    dateLabel.textColor = Color.textNormal
    dateLabel.textAlignment = .left
    addSubview(dateLabel)
    constrain(dateLabel, self) {
      dateLabel, superview in
      
      dateLabel.top == superview.top
      dateLabel.leading == superview.leading + leadingMargin
      dateLabel.trailing == superview.centerX - trailingMargin
      dateLabel.bottom == superview.bottom
    }
    // Day
    dayLabel.font = Font.named(.helveticaNeueRegular, size: 15.0)
    dayLabel.textColor = Color.textLight
    dayLabel.textAlignment = .right
    addSubview(dayLabel)
    constrain(dayLabel, self) {
      dayLabel, superview in
      
      dayLabel.top == superview.top
      dayLabel.leading == superview.centerX + leadingMargin
      dayLabel.trailing == superview.trailing - trailingMargin
      dayLabel.bottom == superview.bottom
    }
  }
}
