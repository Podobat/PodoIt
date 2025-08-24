//
//  SettingModel.swift
//  PodoIt
//
//  Created by 서광용 on 8/24/25.
//

enum Theme {
  case system
  case light
  case dark
  
  var displayName: String {
    switch self {
    case .system: return "시스템 설정"
    case .light: return "라이트 모드"
    case .dark: return "다크 모드"
    }
  }
}

enum SettingItem {
  case notification(isOn: Bool) // 알림 설정
  case theme(current: Theme) // 테마 변경
  case inquiry // 문의/건의하기
  case review // 리뷰 남기기
  
  var title: String {
    switch self {
    case .notification: return "알림 설정"
    case .theme: return "테마 설정"
    case .inquiry: return "문의·건의하기"
    case .review: return "리뷰 남기기"
    }
  }
  
  enum Accessory {
    case toggle(isOn: Bool) // 토글
    case value(text: Theme) // Label
    case disclosure // >
  }
  
  var accessory: Accessory {
    switch self {
    case .notification(let isOn): return .toggle(isOn: isOn)
    case .theme(let current): return .value(text: current)
    case .inquiry, .review: return .disclosure
    }
  }
}
