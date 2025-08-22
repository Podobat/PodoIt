//
//  Dependencies.swift
//  PodoIt
//
//  Created by 김이든 on 8/22/25.
//

import Dependencies
import Foundation
import SwiftData

extension DependencyValues {
  var modelContext: ModelContext {
    get { self[ModelContextKey.self] }
    set { self[ModelContextKey.self] = newValue }
  }
}

private enum ModelContextKey: DependencyKey {
  static var liveValue: ModelContext {
    ModelContext(Persistence.container)
  }
}

extension ModelContext: @unchecked @retroactive Sendable {}
