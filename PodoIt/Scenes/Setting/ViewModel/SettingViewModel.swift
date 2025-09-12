//
//  SettingViewModel.swift
//  PodoIt
//
//  Created by 서광용 on 8/24/25.
//

import Foundation
import RxCocoa
import RxSwift

final class SettingViewModel {
  private let audio = AudioSettings.shared
  
  var isMuteDriver: Driver<Bool> {
    AudioSettings.shared.isMute.asDriver()
  }
  
  private(set) var currentTheme: Theme
  var items: [SettingItem]
  
  // MARK: - init

  init() {
    // UserDefaults에서 불러오기, 없다면 .system
    let saved = UserDefaults.standard.string(forKey: "theme")
    self.currentTheme = Theme(rawValue: saved ?? "") ?? .system
    
    // AudioSettings의 현재 상태를 초기값으로 반영
    let initalIsOn = !(audio.isMute.value)
    self.items = [
      .notification(isOn: initalIsOn),
      // TODO: 테마 셀은 기능 완성 시 다시 노출
      // UserDefaults 저장과 UI는 완성. 어떤 상태를 했냐에 따라서 테마 변경만 지원하면 끝.
      // .theme(current: currentTheme),
      .inquiry,
      .review
    ]
  }
  
  // 눌리면 토글 바꿔서 accept
  func updateIsMute(isOn: Bool) {
    audio.isMute.accept(!isOn)
  }
  
  func applyTheme(_ theme: Theme) {
    currentTheme = theme
    UserDefaults.standard.set(theme.rawValue, forKey: "theme")
  }
}
