//
//  SettingViewModel.swift
//  PodoIt
//
//  Created by 서광용 on 8/24/25.
//

import Foundation

final class SettingViewModel {
  let items: [SettingItem] = [.notification(isOn: false), .theme(current: .system), .inquiry, .review]
}
