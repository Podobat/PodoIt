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

  private let modelContainer: ModelContainer
  private var modelContext: ModelContext {
    modelContainer.mainContext
  }

  private init() {
    do {
      modelContainer = try ModelContainer(for: TimerModel.self, StatsModel.self)
    } catch {
      fatalError("Failed to create ModelContainer: \(error)")
    }
  }

//  // Dependencies에서 주입받은 ModelContext 사용
//  @Dependency(\.modelContext) private var modelContext
//
//  private init() {}

  // MARK: - CRUD (TimerRepository)

  func fetchAll() throws -> [TimerModel] {
    // createdAt 기준 최신순
    let descriptor = FetchDescriptor<TimerModel>(
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
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
      statsDidChange()
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
      statsDidChange()
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
      statsDidChange()
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

// MARK: - CRUD (StatsModel)

extension SwiftDataManager: StatsRepository {
  // CREATE
  @discardableResult
  func insertStats(date: Date = Date(), icon: String, category: String, time: String) throws -> StatsModel {
    let entity = StatsModel(
      date: date,
      icon: icon,
      category: category,
      time: time
    )
    modelContext.insert(entity)
    do {
      try modelContext.save()
      statsDidChange()
      return entity
    } catch {
      throw RepositoryError.saveFailed
    }
  }

  // MARK: - READ

  // StatsModel에 저장된 카테고리를 TimerModel 기준으로 생성
  // TimerModel(title, iconName) → StatsCategoryModel 로 매핑하고 "전체"를 맨 앞에 둠
  func fetchDistinctCategories() throws -> [StatsCategoryModel] {
    // TimerModel 전부 조회 (생성일 최신순)
    let request = FetchDescriptor<TimerModel>(
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )

    do {
      let timers = try modelContext.fetch(request)

      // TimerModel -> StatsCategoryModel
      let mapped: [StatsCategoryModel] = timers.map { timer in
        StatsCategoryModel(
          name: timer.title,
          icon: timer.iconName.isEmpty ? nil : timer.iconName
        )
      }

      return [.all] + mapped
    } catch {
      throw RepositoryError.fetchFailed
    }
  }

  // 기간/카테고리 조건으로 StatsModel 조회
  // categoryName == "전체" 면 카테고리 필터 없이 기간만 적용
  func fetchStats(from startDate: Date, to endDate: Date, categoryName: String) throws -> [StatsModel] {
    // 조건 구성
    let predicate: Predicate<StatsModel>
    if categoryName == "전체" {
      predicate = #Predicate<StatsModel> { record in
        record.date >= startDate && record.date < endDate
      }
    } else {
      let targetCategory = categoryName // 캡처용 지역 변수
      predicate = #Predicate<StatsModel> { record in
        record.date >= startDate && record.date < endDate && record.category == targetCategory
      }
    }

    // 요청(조건 + 정렬)
    let request = FetchDescriptor<StatsModel>(
      predicate: predicate,
      sortBy: [SortDescriptor(\.date, order: .forward)] // 오래된 → 최신
    )

    do {
      return try modelContext.fetch(request)
    } catch {
      throw RepositoryError.fetchFailed
    }
  }

  // 주어진 카테고리의 "가장 최신" 아이콘을 조회
  // 없으면 nil 반환
  func fetchLatestIcon(for categoryName: String) throws -> String? {
    let targetCategory = categoryName

    // 카테고리 일치 + 아이콘이 비어있지 않은 데이터만
    let predicate = #Predicate<StatsModel> { record in
      record.category == targetCategory && !record.icon.isEmpty
    }

    // 최신 1건만 (날짜 내림차순)
    var request = FetchDescriptor<StatsModel>(
      predicate: predicate,
      sortBy: [SortDescriptor(\.date, order: .reverse)]
    )
    request.fetchLimit = 1

    do {
      return try modelContext.fetch(request).first?.icon
    } catch {
      throw RepositoryError.fetchFailed
    }
  }
}

// MARK: - NotificationCenter

extension SwiftDataManager {
  private func statsDidChange() {
    DispatchQueue.main.async {
      NotificationCenter.default.post(name: .statsDidChange, object: nil)
    }
  }
}

extension Notification.Name {
  static let statsDidChange = Notification.Name("StatsDidChange")
}
