//
//  EmptyHistoryView.swift
//  SumDU
//
//  Created by Yura Voevodin on 9/26/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Cartography
import UIKit

class EmptyHistoryView: UIView {
  
  // MARK: - UI objects
  
  fileprivate let historyImage = UIImageView()
  fileprivate let emptyHistoryLabel = UILabel()
  
  // MARK: - Lifecycle
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    // Image
    historyImage.contentMode = .scaleAspectFit
    historyImage.clipsToBounds = true
    addSubview(historyImage)
    historyImage.image = #imageLiteral(resourceName: "empty_history")
    constrain(historyImage, self) {
      historyImage, superview in
      
      historyImage.centerY == superview.centerY - 55.0
      historyImage.centerX == superview.centerX
    }
    
    // Label
    emptyHistoryLabel.text = NSLocalizedString("History is empty", comment: "")
    emptyHistoryLabel.font = Font.named(.helveticaNeueMedium, size: 20)
    emptyHistoryLabel.textColor = Color.textNormal
    emptyHistoryLabel.textAlignment = .center
    addSubview(emptyHistoryLabel)
    constrain(historyImage, emptyHistoryLabel, self) {
      historyImage, emptyHistoryLabel, superview in
      
      emptyHistoryLabel.top == historyImage.bottom + 30.0
      emptyHistoryLabel.leading == superview.leading + 14.0
      emptyHistoryLabel.trailing == superview.trailing - 14.0
    }
  }
}
