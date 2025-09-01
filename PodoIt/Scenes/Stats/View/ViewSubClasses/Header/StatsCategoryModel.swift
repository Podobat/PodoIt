//
//  StatsCategoryModel.swift
//  PodoIt
//
//  Created by 김이든 on 9/1/25.
//

import Foundation

// 카테고리
struct StatsCategoryModel: Hashable {
  let name: String
  let icon: String?
  static let all = StatsCategoryModel(name: "전체", icon: nil)

  func hash(into hasher: inout Hasher) {
    hasher.combine(name) // name만 고유성 판단 기준
  }
}

// 더미 데이터
extension StatsCategoryModel {
  static let items: [StatsCategoryModel] = [
    .init(name: "공부", icon: "📚"),
    .init(name: "코딩", icon: "💻"),
    .init(name: "메모", icon: "📝"),
    .init(name: "공부", icon: "🔥"), // name 중복 안됨
    .init(name: "코딩", icon: "🍇"),
    .init(name: "메모", icon: "🦊"),
    .init(name: "공부", icon: "📚"),
    .init(name: "코딩", icon: "💻"),
    .init(name: "메모", icon: "📝"),
  ]
}
