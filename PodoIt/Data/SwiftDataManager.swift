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
      DispatchQueue.main.async {
        NotificationCenter.default.post(name: .statsDidChange, object: nil)
      }
      return entity
    } catch {
      throw RepositoryError.saveFailed
    }
  }

  // READ
  // StatsModel에 저장된 카테고리들을 중복 없이 추출
  func fetchDistinctCategories() throws -> [StatsCategoryModel] {
    // StatsModel 전체 데이터 가져오기
    let stats = try modelContext.fetch(FetchDescriptor<StatsModel>())

    var seen = Set<String>() // 이미 본 카테고리 이름 저장
    var unique: [StatsCategoryModel] = [] // 중복 제거 후 결과 배열

    // 모든 StatsModel 순회
    for s in stats {
      // 아직 안 본 카테고리일 때만 추가
      if !seen.contains(s.category) {
        seen.insert(s.category) // 본 목록에 추가
        // icon 값이 비어있으면 nil 처리
        unique.append(.init(name: s.category, icon: s.icon.isEmpty ? nil : s.icon))
      }
    }

    // "전체" 항목을 항상 맨 앞에 추가하고, 혹시 중복된 건 걸러냄
    return [.all] + unique.filter { $0.name != "전체" }
  }

  // 기간과 카테고리에 맞는 StatsModel 목록 조회
  //   - start: 조회 시작일 (포함)
  //   - end:   조회 종료일 (미포함)
  // - Returns: 조건에 맞는 StatsModel 배열
  func fetchStats(from start: Date, to end: Date, categoryName: String) throws -> [StatsModel] {
    // "전체"면 카테고리 조건 없이 기간만 체크
    // 특정 카테고리면 기간 + 카테고리명 조건 동시 체크
    let predicate: Predicate<StatsModel>
    if categoryName == "전체" {
      predicate = #Predicate<StatsModel> { s in
        s.date >= start && s.date < end
      }
    } else {
      let name = categoryName // 캡처용 지역 변수 (closure 내부에서 참조 가능하도록)
      predicate = #Predicate<StatsModel> { s in
        s.date >= start && s.date < end && s.category == name
      }
    }

    // FetchDescriptor: 조건 + 정렬 방식 정의
    let descriptor = FetchDescriptor<StatsModel>(
      predicate: predicate,
      sortBy: [SortDescriptor(\.date, order: .forward)] // 날짜 오름차순
    )

    do {
      return try modelContext.fetch(descriptor)
    } catch {
      // SwiftData fetch 실패 → RepositoryError로 변환
      throw RepositoryError.fetchFailed
    }
  }

  // 특정 카테고리 이름에 대해, 저장된 데이터 중 가장 최신의 아이콘 값 조회
  func fetchLatestIcon(for categoryName: String) throws -> String? {
    let name = categoryName
    // 조건: 카테고리명 일치 + icon 값이 비어있지 않은 데이터만
    let predicate = #Predicate<StatsModel> { $0.category == name && !$0.icon.isEmpty }

    // 최신(날짜 내림차순) 1건만 가져오기
    var desc = FetchDescriptor<StatsModel>(
      predicate: predicate,
      sortBy: [SortDescriptor(\.date, order: .reverse)]
    )
    desc.fetchLimit = 1

    // 최신 아이콘 반환 (없으면 nil)
    return try modelContext.fetch(desc).first?.icon
  }
}

extension Notification.Name {
  static let statsDidChange = Notification.Name("StatsDidChange")
}
