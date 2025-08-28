//
//  TimerRunViewModel.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import Foundation

final class TimerRunViewModel {
  private let timerID: UUID
  private let repo: TimerRepository

  private(set) var timer: TimerModel?

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
}
