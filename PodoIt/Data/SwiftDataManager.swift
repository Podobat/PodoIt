//
//  SwiftDataManager.swift
//  PodoIt
//
//  Created by 김이든 on 8/21/25.
//

import Dependencies
import Foundation
import SwiftData

@MainActor
final class SwiftDataManager: TimerRepository {
  static let shared = SwiftDataManager()

  // Dependencies에서 주입받은 ModelContext 사용
  @Dependency(\.modelContext) private var modelContext

  private init() {}

  // MARK: - CRUD (TimerRepository)

  func fetchAll() throws -> [TimerModel] {
    // 현재는 timerID 오름차순. createdAt 추가 시 최신순으로 변경 권장.
    let descriptor = FetchDescriptor<TimerModel>(
      sortBy: [SortDescriptor(\.timerID, order: .forward)]
    )
    do {
      return try modelContext.fetch(descriptor)
    } catch {
      throw RepositoryError.fetchFailed
    }
  }

  @discardableResult
  func insert(title: String, iconName: String, goalMinutes: Int) throws -> TimerModel {
    let entity = TimerModel(
      timerID: UUID(),
      title: title,
      iconName: iconName,
      goalTime: goalMinutes
    )
    modelContext.insert(entity)
    do {
      try modelContext.save()
      return entity
    } catch {
      throw RepositoryError.saveFailed
    }
  }

  func update(id: UUID, title: String, iconName: String, goalMinutes: Int) throws {
    guard let entity = try fetch(by: id) else {
      throw RepositoryError.entityNotFound
    }
    entity.title = title
    entity.iconName = iconName
    entity.goalTime = goalMinutes
    do {
      try modelContext.save()
    } catch {
      throw RepositoryError.saveFailed
    }
  }

  func delete(id: UUID) throws {
    let predicate = #Predicate<TimerModel> { $0.timerID == id }
    let descriptor = FetchDescriptor<TimerModel>(predicate: predicate)
    let entities = try modelContext.fetch(descriptor)
    guard !entities.isEmpty else {
      throw RepositoryError.entityNotFound
    }
    for e in entities {
      modelContext.delete(e)
    }
    do {
      try modelContext.save()
    } catch {
      throw RepositoryError.saveFailed
    }
  }

  // MARK: - Helper

  func fetch(by id: UUID) throws -> TimerModel? {
    let predicate = #Predicate<TimerModel> { $0.timerID == id }
    var descriptor = FetchDescriptor<TimerModel>(predicate: predicate)
    descriptor.fetchLimit = 1
    return try modelContext.fetch(descriptor).first
  }
}
