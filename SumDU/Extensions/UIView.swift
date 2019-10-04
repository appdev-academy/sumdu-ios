//
//  UIView.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 10/4/19.
//  Copyright © 2019 App Dev Academy. All rights reserved.
//

import UIKit

extension UIView {
  func rotate360Degrees(duration: CFTimeInterval?, completionDelegate: AnyObject? = nil) {
    let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
    rotateAnimation.fromValue = 0.0
    rotateAnimation.toValue = CGFloat(.pi * 2.0)
    rotateAnimation.duration = duration ?? 1.0
    rotateAnimation.repeatCount = .infinity
    if let delegate: AnyObject = completionDelegate {
      rotateAnimation.delegate = delegate as? CAAnimationDelegate
    }
    if duration == nil {
      // Make delay before removing animation
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.layer.removeAnimation(forKey: "rotationAnimation")
      }
    } else {
      self.layer.add(rotateAnimation, forKey: "rotationAnimation")
    }
  }
}
