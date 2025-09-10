//
//  AudioSettings.swift
//  PodoIt
//
//  Created by 서광용 on 9/9/25.
//

import RxCocoa

final class AudioSettings {
  static let shared = AudioSettings() // 싱글톤
  private init() {}
  
  // 사운드 음소거. 값이 바뀔 때마다 이벤트 방출
  let isMute = BehaviorRelay<Bool>(value: false)
}
