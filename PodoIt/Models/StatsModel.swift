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
  var category: String
  var time: Int

  init(
    category: String,
    time: Int
  ) {
    self.category = category
    self.time = time
  }
}

// Stats 모델
@Model
final class StatsModel {
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
    date: Date,
    dayTotalTime: Int,
    monthTotalTime: Int
  ) {
    self.date = date
    self.dayTotalTime = dayTotalTime
    self.monthTotalTime = monthTotalTime
  }
}
