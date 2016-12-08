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
  
  fileprivate let label = UILabel()
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
  
  // MARK: - Helpers
  
  /// Show matching pattern
  fileprivate func highlightSearchResults(_ searchString: String, resultString: String) -> NSMutableAttributedString {
    
    let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: resultString)
    let pattern = searchString
    let range: NSRange = NSMakeRange(0, resultString.characters.count)
    
    let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
    
    regex?.enumerateMatches(in: resultString, options: NSRegularExpression.MatchingOptions(), range: range) {
      (textCheckingResult, matchingFlags, stop) -> Void in
      
      if let subRange = textCheckingResult?.range {
        attributedString.addAttribute(NSForegroundColorAttributeName, value: Color.textNormal, range: subRange)
      }
    }
    return attributedString
  }
  
  // MARK: - Interface
  
  func update(with object: ListData, search: Bool, searchingText: String?) {
    label.text = object.name
    if search {
      label.textColor = Color.textLight
      if let searchingText = searchingText {
        label.attributedText = highlightSearchResults(searchingText, resultString: object.name)
      }
    } else {
      label.textColor = Color.textNormal
    }
  }
}
