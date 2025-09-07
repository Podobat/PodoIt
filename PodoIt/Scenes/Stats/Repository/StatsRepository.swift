//
//  StatsRepository.swift
//  PodoIt
//
//  Created by 김이든 on 9/7/25.
//

import Foundation

protocol StatsRepository {
  @discardableResult
  func insertStats(date: Date, icon: String, category: String, time: String) throws -> StatsModel
  func fetchDistinctCategories() throws -> [StatsCategoryModel]
  func fetchStats(from start: Date, to end: Date, categoryName: String) throws -> [StatsModel]
  func fetchLatestIcon(for categoryName: String) throws -> String?
}
