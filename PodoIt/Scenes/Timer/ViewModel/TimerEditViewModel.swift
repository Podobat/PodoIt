//
//  TimerEditViewModel.swift
//  PodoIt
//
//  Created by 노가현 on 8/27/25.
//

import Foundation

final class TimerEditViewModel {
  private let repo: TimerRepository
  private(set) var editing: TimerModel?

  init(repo: TimerRepository, editing: TimerModel? = nil) {
    self.repo = repo
    self.editing = editing
  }

  // 저장(신규/수정 모두 처리)
  func save(title: String, iconName: String, goalMinutes: Int) throws {
    if let current = editing {
      try repo.update(id: current.timerID, title: title, iconName: iconName, goalMinutes: goalMinutes)
      // 반영된 값 로컬에도 반영해두면 화면 재표시 시 편함
      editing?.title = title
      editing?.iconName = iconName
      editing?.goalTime = goalMinutes
    } else {
      editing = try repo.insert(title: title, iconName: iconName, goalMinutes: goalMinutes)
    }
  }

  // 삭제
  func delete() throws {
    guard let id = editing?.timerID else { return }
    try repo.delete(id: id)
    editing = nil
  }
}