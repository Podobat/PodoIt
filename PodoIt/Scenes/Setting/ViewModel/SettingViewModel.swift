//
//  SettingViewModel.swift
//  PodoIt
//
//  Created by 서광용 on 8/24/25.
//

import Foundation

final class SettingViewModel {
  private(set) var currentTheme: Theme
  
  init() {
    // UserDefaults에서 불러오기, 없다면 .system
    let saved = UserDefaults.standard.string(forKey: "theme")
    self.currentTheme = Theme(rawValue: saved ?? "") ?? .system
  }
  
  func applyTheme(_ theme: Theme) {
    currentTheme = theme
    UserDefaults.standard.set(currentTheme, forKey: "theme")
  }
  
  var items: [SettingItem] {
    return [
      .notification(isOn: false),
      .theme(current: currentTheme),
      .inquiry,
      .review
    ]
  }
}
