//
//  Persistence.swift
//  PodoIt
//
//  Created by 김이든 on 8/22/25.
//

import SwiftData

enum Persistence {
  static let container: ModelContainer = {
    do {
      let models: [any PersistentModel.Type] = [
        TimerModel.self,
        StatsModel.self,
      ]
      let schema = Schema(models)
      return try ModelContainer(for: schema)
    } catch {
      fatalError(error.localizedDescription)
    }
  }()
}
