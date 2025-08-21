//
//  ColorBook.swift
//  PodoIt
//
//  Created by 노가현 on 8/21/25.
//

import UIKit

private final class _TokenBundleMarker {}

enum ColorBook {
  static var bundle: Bundle {
    #if SWIFT_PACKAGE
    return .module
    #else
    return Bundle(for: _TokenBundleMarker.self)
    #endif
  }

  static func uicolor(_ name: String) -> UIColor {
    guard let color = UIColor(named: name, in: bundle, compatibleWith: nil) else {
      assertionFailure("Missing color asset: \(name)")
      return .clear
    }
    return color
  }
}
