//
//  BackButton.swift
//  SumDU
//
//  Created by Yura Voevodin on 13.07.16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import UIKit

class BackButton: UIButton {
  
  // MARK: - Constants
  
  static let buttonSize = CGSize(width: 44.0, height: 44.0)
  
  // MARK: - Lifecycle
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setImage(#imageLiteral(resourceName: "back_normal"), for: .normal)
    setImage(#imageLiteral(resourceName: "back_pressed"), for: .selected)
    contentMode = .scaleAspectFill
    imageEdgeInsets = UIEdgeInsetsMake(0.0, -20.0, 0.0, 0.0)
    clipsToBounds = true
  }
}
