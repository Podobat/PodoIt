//
//  PodoItFontStyle.swift
//  PodoIt
//
//  Created by 노가현 on 8/21/25.
//

import UIKit

enum Typography {
  enum Style {
    case displayLg(weight: AppFontWeight = .semibold) // 48 / 64
    case displayMd(weight: AppFontWeight = .semibold) // 32 / 40
    case titleLg // 18 / 26 Bold
    case titleMd // 16 / 24 Semi
    case bodyLg // 16 / 24 Regular
    case bodyMd // 14 / 20 Regular
    case labelLg // 16 / 24 Regular
    case labelMd // 14 / 20 Regular
    case captionLg // 12 / 18 Regular
    case captionMd // 11 / 16 Regular
  }

  struct Spec {
    let size: CGFloat
    let lineHeight: CGFloat
    let weight: AppFontWeight
  }

  static func spec(for style: Style) -> Spec {
    switch style {
    case .displayLg(let w):
      return .init(size: 48, lineHeight: 64, weight: w)
    case .displayMd(let w):
      return .init(size: 32, lineHeight: 40, weight: w)
    case .titleLg:
      return .init(size: 18, lineHeight: 26, weight: .bold)
    case .titleMd:
      return .init(size: 16, lineHeight: 24, weight: .semibold)
    case .bodyLg:
      return .init(size: 16, lineHeight: 24, weight: .regular)
    case .bodyMd:
      return .init(size: 14, lineHeight: 20, weight: .regular)
    case .labelLg:
      return .init(size: 16, lineHeight: 24, weight: .regular)
    case .labelMd:
      return .init(size: 14, lineHeight: 20, weight: .regular)
    case .captionLg:
      return .init(size: 12, lineHeight: 18, weight: .regular)
    case .captionMd:
      return .init(size: 11, lineHeight: 16, weight: .regular)
    }
  }

  // UIFont 생성
  static func font(for style: Style, scalable: Bool = true) -> UIFont {
    let spec = spec(for: style)
    let base = FontBook.font(size: spec.size, weight: spec.weight)
    guard scalable else { return base }
    return UIFontMetrics(forTextStyle: .body).scaledFont(for: base)
  }

  // 문단 스타일
  static func paragraphStyle(for style: Style, font: UIFont? = nil) -> NSMutableParagraphStyle {
    let p = NSMutableParagraphStyle()
    let spec = spec(for: style)
    p.minimumLineHeight = spec.lineHeight
    p.maximumLineHeight = spec.lineHeight
    p.lineBreakMode = .byTruncatingTail
    p.alignment = .natural
    return p
  }

  // 베이스라인 보정
  static func baselineOffset(for style: Style, using font: UIFont) -> CGFloat {
    let spec = spec(for: style)
    return (spec.lineHeight - font.lineHeight) / 2.0
  }

  // 속성 딕셔너리
  static func attributes(for style: Style,
                         color: UIColor,
                         scalable: Bool = true) -> [NSAttributedString.Key: Any]
  {
    let f = font(for: style, scalable: scalable)
    let p = paragraphStyle(for: style, font: f)
    let baseline = baselineOffset(for: style, using: f)

    return [
      .font: f,
      .foregroundColor: color,
      .paragraphStyle: p,
      .baselineOffset: baseline
    ]
  }

  static func attributed(_ text: String,
                         style: Style,
                         color: UIColor,
                         scalable: Bool = true) -> NSAttributedString
  {
    .init(string: text, attributes: attributes(for: style, color: color, scalable: scalable))
  }
}
