//
//  PodoItFontStyle.swift
//  PodoIt
//
//  Created by 노가현 on 8/21/25.
//

import UIKit

enum Typography {
  enum Style {
    case display1(weight: AppFontWeight = .semibold) // 18 / 26
    case display2(weight: AppFontWeight = .semibold) // 32 / 40
    case title1 // 18 / 26 Bold
    case title2 // 16 / 24 Semi
    case body1 // 14 / 20 Regular
    case label1 // 16 / 24 Regular
    case label2 // 14 / 20 Regular
    case caption1 // 12 / 18 Regular
    case caption2 // 11 / 16 Regular
  }

  struct Spec {
    let size: CGFloat
    let lineHeight: CGFloat
    let weight: AppFontWeight
  }

  static func spec(for style: Style) -> Spec {
    switch style {
    case .display1(let w):
      return .init(size: 18, lineHeight: 26, weight: w)
    case .display2(let w):
      return .init(size: 32, lineHeight: 40, weight: w)
    case .title1:
      return .init(size: 18, lineHeight: 26, weight: .bold)
    case .title2:
      return .init(size: 16, lineHeight: 24, weight: .semibold)
    case .body1:
      return .init(size: 14, lineHeight: 20, weight: .regular)
    case .label1:
      return .init(size: 16, lineHeight: 24, weight: .regular)
    case .label2:
      return .init(size: 14, lineHeight: 20, weight: .regular)
    case .caption1:
      return .init(size: 12, lineHeight: 18, weight: .regular)
    case .caption2:
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
