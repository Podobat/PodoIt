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
  private let startDateRelay = BehaviorRelay<Date?>(value: nil) // 타이머 시작을 기억

  init(timerID: UUID, repo: TimerRepository) {
    self.timerID = timerID
    self.repo = repo
  }

  func load() throws {
    guard let entity = try repo.fetch(by: timerID) else {
      throw RepositoryError.entityNotFound
    }
    self.timer = entity
  }

  func start() {
    // 여기에서 타이머 작동 로직
  }
}
