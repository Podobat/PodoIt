//
//  StatsModel.swift
//  PodoIt
//
//  Created by 김이든 on 8/21/25.
//

import Foundation
import SwiftData

@Model
final class StatsModel: Hashable {
  var date: Date
  var icon: String
  var category: String
  var time: String

  init(
    date: Date,
    icon: String,
    category: String,
    time: String
  ) {
    self.date = date
    self.icon = icon
    self.category = category
    self.time = time
  }
}
