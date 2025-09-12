//
//  UITextField+Padding.swift
//  PodoIt
//
//  Created by 노가현 on 8/24/25.
//

import UIKit

extension UITextField {
  func setLeftPadding(_ amount: CGFloat) {
    let padding = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
    self.leftView = padding
    self.leftViewMode = .always
  }
}
