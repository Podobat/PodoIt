//
//  StatsModel.swift
//  PodoIt
//
//  Created by 김이든 on 8/21/25.
//

import Foundation
import SwiftData

// 카테고리별 시간 모델
@Model
final class CategoryTimeModel {
  var icon: String
  var category: String
  var time: Int

  init(
    icon: String,
    category: String,
    time: Int
  ) {
    self.icon = icon
    self.category = category
    self.time = time
  }
}

// Stats 모델
@Model
final class StatsModel: Hashable {
  var statsID: UUID
  var date: Date
  var dayTotalTime: Int
  var monthTotalTime: Int

  // 하루 카테고리별 시간들
  @Relationship(deleteRule: .cascade)
  var dayCategoryTimes: [CategoryTimeModel] = []

  // 월간 카테고리별 시간들
  @Relationship(deleteRule: .cascade)
  var monthCategoryTimes: [CategoryTimeModel] = []

  init(
    statsID: UUID = UUID(),
    date: Date,
    dayTotalTime: Int,
    monthTotalTime: Int
  ) {
    self.statsID = statsID
    self.date = date
    self.dayTotalTime = dayTotalTime
    self.monthTotalTime = monthTotalTime
  }
}
