//
//  TimerRunViewModel.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import Foundation
import RxCocoa
import RxSwift

final class TimerRunViewModel {
  private let timerID: UUID
  private let repo: TimerRepository

  private(set) var timer: TimerModel?
  private let disposeBag = DisposeBag()
  
  private let sessionStart = Date() // 공부 시작한 시간 기록
  private var stateStart: Date? // 현재 구간(공부/휴식)이 시작된 시간 기록
  private var isRunning = true // 공부 중(true)/휴식 중(false)
  
  private var studySeconds = 0 // 지금까지 누적된 총 공부 시간(초)
  private var restSeconds = 0 // 지금까지 누적된 총 휴식 시간(초)
  
  let runningTimeText: Driver<String> // UI바인딩용. 공부시간을 방출
  
  private static func format(seconds: Int) -> String {
    let h = seconds / 3600
    let m = (seconds % 3600) / 60
    let s = seconds % 60
    return String(format: "%d:%02d:%02d", h, m, s) // 0:12:53, 1:50:49, 12:49:39등으로 포맷
  }

  init(timerID: UUID, repo: TimerRepository) {
    self.timerID = timerID
    self.repo = repo
//    startAndPause()
  }

  func load() throws {
    guard let entity = try repo.fetch(by: timerID) else {
      throw RepositoryError.entityNotFound
    }
    self.timer = entity
  }

  func startAndPause() {
    // 여기에서 타이머 작동 로직
    // isRunning: Bool의 상태값을 기준으로, start/pause 상태로 관리
  }
}
