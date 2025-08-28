
//
// TimerRepository.swift
//  PodoIt
//
//  Created by 노가현 on 8/27/25.
//

import Foundation

// 타이머 데이터를 다루는 추상화 인터페이스
protocol TimerRepository {
  func fetchAll() throws -> [TimerModel] // 모든 타이머 조회
  func fetch(by id: UUID) throws -> TimerModel? // 단일 타이머 조회
  @discardableResult
  func insert(title: String, iconName: String, goalMinutes: Int) throws -> TimerModel // 생성
  func update(id: UUID, title: String, iconName: String, goalMinutes: Int) throws // 수정
  func delete(id: UUID) throws // 삭제
}

// MARK: - Repository Errors

enum RepositoryError: Error, LocalizedError {
  case entityNotFound // 조회/삭제 대상 없음
  case saveFailed // 저장 실패
  case fetchFailed // 조회 실패

  var errorDescription: String? {
    switch self {
    case .entityNotFound: return "요청한 타이머를 찾을 수 없습니다"
    case .saveFailed: return "데이터 저장에 실패했습니다"
    case .fetchFailed: return "데이터 조회에 실패했습니다"
    }
  }
}
