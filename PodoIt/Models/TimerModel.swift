//
//  TimerModel.swift
//  PodoIt
//
//  Created by 김이든 on 8/21/25.
//

import Foundation
import SwiftData

@Model
final class TimerModel: Identifiable {
  var timerID: UUID
  var title: String
  var iconName: String
  var goalTime: Int

  init(
    timerID: UUID = UUID(),
    title: String,
    iconName: String,
    goalTime: Int
  ) {
    self.timerID = timerID
    self.title = title
    self.iconName = iconName
    self.goalTime = goalTime
  }
}
