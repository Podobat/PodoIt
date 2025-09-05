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
    UserDefaults.standard.set(theme.rawValue, forKey: "theme")
  }

  var items: [SettingItem] {
    return [
      .notification(isOn: false),
      // TODO: 테마 셀은 기능 완성 시 다시 노출
      // UserDefaults 저장과 UI는 완성. 어떤 상태를 했냐에 따라서 테마 변경만 지원하면 끝.
      // .theme(current: currentTheme),
      .inquiry,
      .review
    ]
  }
}
