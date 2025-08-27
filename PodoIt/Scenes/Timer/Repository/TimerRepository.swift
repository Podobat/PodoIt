
//
// TimerRepository.swift
//  PodoIt
//
//  Created by 노가현 on 8/27/25.
//

import Foundation
import SwiftData

protocol TimerRepository {
  func fetchAll() throws -> [TimerModel]
  @discardableResult
  func insert(title: String, iconName: String, goalMinutes: Int) throws -> TimerModel
  func update(id: UUID, title: String, iconName: String, goalMinutes: Int) throws
  func delete(id: UUID) throws
}

final class SwiftDataTimerRepository: TimerRepository {
  private let context: ModelContext

  init(context: ModelContext) {
    self.context = context
  }

  func fetchAll() throws -> [TimerModel] {
    let descriptor = FetchDescriptor<TimerModel>(
      sortBy: [SortDescriptor(\.timerID, order: .forward)]
    )
    return try context.fetch(descriptor)
  }

  @discardableResult
  func insert(title: String, iconName: String, goalMinutes: Int) throws -> TimerModel {
    let entity = TimerModel(
      timerID: UUID(),
      title: title,
      iconName: iconName,
      goalTime: goalMinutes
    )
    context.insert(entity)
    try context.save()
    return entity
  }

  func update(id: UUID, title: String, iconName: String, goalMinutes: Int) throws {
    let predicate = #Predicate<TimerModel> { $0.timerID == id }
    var descriptor = FetchDescriptor<TimerModel>(predicate: predicate)
    descriptor.fetchLimit = 1

    guard let entity = try context.fetch(descriptor).first else {
      throw RepositoryError.entityNotFound
    }

    entity.title = title
    entity.iconName = iconName
    entity.goalTime = goalMinutes
    try context.save()
  }

  func delete(id: UUID) throws {
    let predicate = #Predicate<TimerModel> { $0.timerID == id }
    let descriptor = FetchDescriptor<TimerModel>(predicate: predicate)

    let entities = try context.fetch(descriptor)
    guard !entities.isEmpty else {
      throw RepositoryError.entityNotFound
    }

    for entity in entities {
      context.delete(entity)
    }
    try context.save()
  }
}

// MARK: - Repository Errors

enum RepositoryError: Error, LocalizedError {
  case entityNotFound
  case saveFailed
  case fetchFailed

  var errorDescription: String? {
    switch self {
    case .entityNotFound:
      return "요청한 타이머를 찾을 수 없습니다"
    case .saveFailed:
      return "데이터 저장에 실패했습니다"
    case .fetchFailed:
      return "데이터 조회에 실패했습니다"
    }
  }
}
