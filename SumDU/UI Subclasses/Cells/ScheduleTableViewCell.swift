//
//  ScheduleTableViewCell.swift
//  SumDU
//
//  Created by Yura Voevodin on 26.12.15.
//  Copyright © 2015 App Dev Academy. All rights reserved.
//

import Cartography
import UIKit

class ScheduleTableViewCell: UITableViewCell {
  
  // MARK: - Constants
  
  static let reuseIdentifier = "\(ScheduleTableViewCell.self)"
  static let cellHeight: CGFloat = 126.0
  
  // MARK: - UI objects
  
  fileprivate let nameLabel = UILabel()
  fileprivate let timeLabel = UILabel()
  fileprivate let dotImageView = UIImageView()
  fileprivate let auditoriumLabel = UILabel()
  fileprivate let teacherLabel = UILabel()
  fileprivate let separatorView = UIView()
  
  // MARK: - Lifecycle
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    initialSetup()
  }
  
  // MARK: - Helpers
  
  fileprivate func initialSetup() {
    let leadingMargin: CGFloat = 14.0
    let trailingMargin: CGFloat = 14.0
    let itemSpacing: CGFloat = 6.0
    selectionStyle = .none
    // Name
    nameLabel.font = Font.named(.helveticaNeueMedium, size: 20.0)
    nameLabel.textColor = Color.textBlack
    nameLabel.textAlignment = .left
    nameLabel.adjustsFontSizeToFitWidth = true
    nameLabel.minimumScaleFactor = 0.7
    nameLabel.numberOfLines = 2
    contentView.addSubview(nameLabel)
    constrain(nameLabel, contentView) {
      nameLabel, superview in
      
      nameLabel.top == superview.top + 12.0
      nameLabel.leading == superview.leading + leadingMargin
      nameLabel.trailing == superview.trailing - trailingMargin
      nameLabel.height == 48.0
    }
    // Time
    timeLabel.font = Font.named(.helveticaNeueMedium, size: 17.0)
    timeLabel.textColor = Color.textNormal
    timeLabel.textAlignment = .left
    contentView.addSubview(timeLabel)
    constrain(timeLabel, nameLabel, contentView) {
      timeLabel, nameLabel, superview in
      
      timeLabel.top == nameLabel.bottom + 8.0
      timeLabel.leading == superview.leading + leadingMargin
      timeLabel.height == 21.0
    }
    // Dot
    dotImageView.image = UIImage(named: "dot")
    dotImageView.contentMode = .scaleAspectFill
    dotImageView.clipsToBounds = true
    contentView.addSubview(dotImageView)
    constrain(dotImageView, timeLabel) {
      dotImageView, timeLabel in
      
      dotImageView.leading == timeLabel.trailing + itemSpacing
      dotImageView.centerY == timeLabel.centerY
      dotImageView.height == 6.0
      dotImageView.width == 6.0
    }
    // Auditorium
    auditoriumLabel.font = Font.named(.helveticaNeueMedium, size: 17.0)
    auditoriumLabel.textColor = Color.textNormal
    auditoriumLabel.textAlignment = .left
    contentView.addSubview(auditoriumLabel)
    constrain(auditoriumLabel, dotImageView, nameLabel, contentView) {
      auditoriumLabel, dotImageView, nameLabel, superview in
      
      auditoriumLabel.top == nameLabel.bottom + 8.0
      auditoriumLabel.leading == dotImageView.trailing + itemSpacing
      auditoriumLabel.height == 21.0
    }
    // Separator
    separatorView.backgroundColor = Color.backgroundGray
    contentView.addSubview(separatorView)
    constrain(separatorView, contentView) {
      separatorView, superview in
      
      separatorView.leading == superview.leading
      separatorView.trailing == superview.trailing
      separatorView.bottom == superview.bottom
      separatorView.height == 1.0
    }
    // Teacher
    teacherLabel.font = Font.named(.helveticaNeueMedium, size: 15.0)
    teacherLabel.textColor = Color.textLight
    teacherLabel.textAlignment = .left
    contentView.addSubview(teacherLabel)
    constrain(teacherLabel, timeLabel, separatorView, contentView) {
      teacherLabel, timeLabel, separatorView, superview in
      
      teacherLabel.top == timeLabel.bottom + itemSpacing
      teacherLabel.leading == superview.leading + leadingMargin
      teacherLabel.trailing == superview.trailing - trailingMargin
      teacherLabel.bottom == separatorView.top
    }
  }
  
  // MARK: - Public interface
  
  /** Update cell data */
  func update(withSchedule schedule: Schedule) {
    // Name
    var name = schedule.pairName
    if schedule.pairType.characters.count > 0 { name += " (" + schedule.pairType + ")" }
    nameLabel.text = name
    // Time
    timeLabel.text = schedule.pairTime
    // Auditorium
    auditoriumLabel.text = schedule.auditoriumName
    // Teacher
    teacherLabel.text = schedule.teacherName
  }
}
