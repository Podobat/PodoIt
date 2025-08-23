//
//  UILabel+Factory.swift
//  PodoIt
//
//  Created by 노가현 on 8/23/25.
//

import UIKit

extension UILabel {
  static func makeAttributed(
    text: String,
    style: Typography.Style,
    color: UIColor,
    alignment: NSTextAlignment = .left
  ) -> UILabel {
    return UILabel().then {
      $0.attributedText = Typography.attributed(text, style: style, color: color)
      $0.textAlignment = alignment
    }
  }
}