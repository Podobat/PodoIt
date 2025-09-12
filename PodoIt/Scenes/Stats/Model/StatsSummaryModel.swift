//
//  StatsSummaryModel.swift
//  PodoIt
//
//  Created by 김이든 on 9/3/25.
//

import Foundation

struct StatsSummaryModel: Hashable {
  let icon: String
  let title: String
  let stats: String
}

struct SummaryUI {
  let items: [StatsSummaryModel]
  let totalText: String
}
