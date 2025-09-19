//
//  PodoItFontStyle.swift
//  PodoIt
//
//  Created by 노가현 on 8/21/25.
//

import UIKit

enum Typography {
  enum Style {
    case displayLg(weight: AppFontWeight = .semibold) // 48 / 56 Semi or Bold
    case displayMd(weight: AppFontWeight = .semibold) // 32 / 40 Semi or Bold
    case headingLg(weight: AppFontWeight = .semibold) // 20 / 32 Semi or Bold
    case headingMd(weight: AppFontWeight = .semibold) // 18 / 28 Semi or Bold
    case headingSm // 16 / 24 Semi
    case bodyLg(weight: AppFontWeight = .regular) // 16 / 24 -
    case bodyMd(weight: AppFontWeight = .regular) // 14 / 20 -
    case labelLg // 16 / 24 Semi
    case labelMd(weight: AppFontWeight = .regular) // 14 / 20 -
    case captionLg(weight: AppFontWeight = .regular) // 12 / 18 Regular or Semi
    case captionMd // 11 / 16 Semi
  }

  struct Spec {
    let size: CGFloat
    let lineHeight: CGFloat
    let weight: AppFontWeight
  }

  static func spec(for style: Style) -> Spec {
    switch style {
    case .displayLg(let w):
      return .init(size: 48, lineHeight: 56, weight: w)
    case .displayMd(let w):
      return .init(size: 32, lineHeight: 40, weight: w)
    case .headingLg(let w):
      return .init(size: 20, lineHeight: 32, weight: w)
    case .headingMd(let w):
      return .init(size: 18, lineHeight: 28, weight: w)
    case .headingSm:
      return .init(size: 16, lineHeight: 24, weight: .semibold)
    case .bodyLg(let w):
      return .init(size: 16, lineHeight: 24, weight: w)
    case .bodyMd(let w):
      return .init(size: 14, lineHeight: 20, weight: w)
    case .labelLg:
      return .init(size: 16, lineHeight: 24, weight: .semibold)
    case .labelMd(let w):
      return .init(size: 14, lineHeight: 20, weight: w)
    case .captionLg(let w):
      return .init(size: 12, lineHeight: 18, weight: w)
    case .captionMd:
      return .init(size: 11, lineHeight: 16, weight: .semibold)
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

extension UIFont {
  // 현재 폰트의 굵기나 크기는 유지. 숫자만 고정폭(monospaced)으로 렌더링
  func monospacedDigits() -> UIFont {
    let features: [[UIFontDescriptor.FeatureKey: Any]] = [
      [
        .type: kNumberSpacingType, // 어떤 기능 그룹인지: 숫자 간격 기능 그룹
        .selector: kMonospacedNumbersSelector // 그 그룹 안에서 어떤 옵션을 쓸 것인가: 위 간격을 고정폭으로 선택
      ]
    ]
    let desc = fontDescriptor.addingAttributes([.featureSettings: features]) // 기존 폰트 기반에 만들어둔 features 적용
    return UIFont(descriptor: desc, size: pointSize)
  }
}
