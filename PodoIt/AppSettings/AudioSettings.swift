//
//  AudioSettings.swift
//  PodoIt
//
//  Created by 서광용 on 9/9/25.
//

import Foundation
import RxCocoa
import RxSwift

final class AudioSettings {
  static let shared = AudioSettings() // 싱글톤
  
  private let udKey = "isMute_key"
  private let disposeBag = DisposeBag()
  
  // 사운드 음소거. 값이 바뀔 때마다 이벤트 방출
  let isMute = BehaviorRelay<Bool>(value: false)
  
  private init() {
    // 초기 세팅 (데이터 불러와서 세팅)
    let data = UserDefaults.standard.object(forKey: self.udKey) as? Bool ?? false
    isMute.accept(data)
    
    isMute
      .distinctUntilChanged() // 동일 값은 무시
      .skip(1) // 초기 로드 accept 후에 중복 저장 못하도록 1번은 ud에 저장 무시
      .subscribe(onNext: { [udKey] value in // udKey만 복사해서 넣음
        UserDefaults.standard.set(value, forKey: udKey)
      })
      .disposed(by: disposeBag)
  }
}
