
//
// TimerRepository.swift
//  PodoIt
//
//  Created by 노가현 on 8/27/25.
//

import Foundation
import SwiftData

// 타이머 데이터를 다루는 추상화 인터페이스
protocol TimerRepository {
  func fetchAll() throws -> [TimerModel] // 모든 타이머를 조회
  @discardableResult
  func insert(title: String, iconName: String, goalMinutes: Int) throws -> TimerModel // 새로운 타이머를 삽입
  func update(id: UUID, title: String, iconName: String, goalMinutes: Int) throws // 특정 타이머를 업데이트
  func delete(id: UUID) throws // 특정 타이머를 삭제
}

// SwiftData 기반 타이머 저장소 구현체
final class SwiftDataTimerRepository: TimerRepository {
  private let context: ModelContext

  init(context: ModelContext) {
    self.context = context
  }

  // 모든 타이머 조회 (timerID 기준 오름차순 정렬) -> 최신순으로 수정 예정 !
  func fetchAll() throws -> [TimerModel] {
    let descriptor = FetchDescriptor<TimerModel>(
      sortBy: [SortDescriptor(\.timerID, order: .forward)]
    )
    return try context.fetch(descriptor)
  }

  // 새로운 타이머 삽입 후 저장
  @discardableResult
  func insert(title: String, iconName: String, goalMinutes: Int) throws -> TimerModel {
    let entity = TimerModel(
      timerID: UUID(), // 새로운 UUID 부여
      title: title, // 타이머 제목
      iconName: iconName, // 아이콘(이모지 등)
      goalTime: goalMinutes // 목표 시간(분)
    )
    context.insert(entity) // 컨텍스트에 추가
    try context.save() // 영구 저장
    return entity
  }

  // 기존 타이머 수정 (id로 조회 후 값 변경)
  func update(id: UUID, title: String, iconName: String, goalMinutes: Int) throws {
    // 특정 id에 해당하는 TimerModel 조회
    let predicate = #Predicate<TimerModel> { $0.timerID == id }
    var descriptor = FetchDescriptor<TimerModel>(predicate: predicate)
    descriptor.fetchLimit = 1

    guard let entity = try context.fetch(descriptor).first else {
      throw RepositoryError.entityNotFound // 해당 엔티티 없음
    }

    // 속성 업데이트
    entity.title = title
    entity.iconName = iconName
    entity.goalTime = goalMinutes

    try context.save() // 변경사항 저장
  }

  // 특정 타이머 삭제 (id 기반)
  func delete(id: UUID) throws {
    // id 조건으로 해당 타이머들 조회
    let predicate = #Predicate<TimerModel> { $0.timerID == id }
    let descriptor = FetchDescriptor<TimerModel>(predicate: predicate)

    let entities = try context.fetch(descriptor)
    guard !entities.isEmpty else {
      throw RepositoryError.entityNotFound // 삭제할 엔티티 없음
    }

    // 여러 개가 조회되더라도 모두 삭제
    for entity in entities {
      context.delete(entity)
    }
    try context.save() // 삭제 반영
  }
}

// MARK: - Repository Errors

// Repository 동작 중 발생할 수 있는 에러 정의
enum RepositoryError: Error, LocalizedError {
  case entityNotFound // 조회/삭제 대상 없음
  case saveFailed // 저장 실패
  case fetchFailed // 조회 실패

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
