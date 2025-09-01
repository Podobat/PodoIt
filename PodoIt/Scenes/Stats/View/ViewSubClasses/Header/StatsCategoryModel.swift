//
//  StatsCategoryModel.swift
//  PodoIt
//
//  Created by 김이든 on 9/1/25.
//

import Foundation

// 카테고리
struct StatsCategoryModel: Equatable {
  let name: String
  let icon: String? // 전체는 nil
  static let all = StatsCategoryModel(name: "전체", icon: nil)
}

// 더미 데이터
extension StatsCategoryModel {
  static let items: [StatsCategoryModel] = [
    .init(name: "공부", icon: "📚"),
    .init(name: "코딩", icon: "💻"),
    .init(name: "메모", icon: "📝"),
  ]
}
