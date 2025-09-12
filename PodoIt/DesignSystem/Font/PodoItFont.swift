//
//  PodoItFont.swift
//  PodoIt
//
//  Created by 노가현 on 8/21/25.
//

import UIKit

enum AppFontWeight: String {
  case regular = "Regular"
  case medium = "Medium"
  case semibold = "SemiBold"
  case bold = "Bold"
}

enum FontBook {
  // Pretendard- 이름 규칙
  private static let familyPrefix = "Pretendard-"

  // 커스텀 폰트 로드
  static func font(size: CGFloat, weight: AppFontWeight) -> UIFont {
    let name = familyPrefix + weight.rawValue
    if let f = UIFont(name: name, size: size) {
      return f
    } else {
      // 시스템 폰트로 굵기 매핑
      switch weight {
      case .bold: return .boldSystemFont(ofSize: size)
      case .semibold: return .systemFont(ofSize: size, weight: .semibold)
      case .medium: return .systemFont(ofSize: size, weight: .medium)
      case .regular: return .systemFont(ofSize: size, weight: .regular)
      }
    }
  }
}
