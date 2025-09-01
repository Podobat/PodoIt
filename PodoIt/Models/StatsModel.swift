//
//  StatsModel.swift
//  PodoIt
//
//  Created by 김이든 on 8/21/25.
//

import Foundation
import SwiftData

// Stats 모델
@Model
final class StatsModel: Hashable {
  var statsID: UUID
  var date: Date
  var icon: String
  var category: String
  var time: Int

  init(
    statsID: UUID = UUID(),
    date: Date,
    icon: String,
    category: String,
    time: Int
  ) {
    self.statsID = statsID
    self.date = date
    self.icon = icon
    self.category = category
    self.time = time
  }
}
