//
//  TimerRepositoryTests.swift
//  TimerRepositoryTests
//
//  Created by 노가현 on 8/27/25.
//

import XCTest
import SwiftData
@testable import PodoIt

final class TimerRepositoryTests: XCTestCase {
  private var container: ModelContainer!
  private var context: ModelContext!
  private var repo: SwiftDataTimerRepository!

  override func setUp() {
    super.setUp()
    // 디스크를 전혀 쓰지 않는 인메모리 컨테이너
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    container = try! ModelContainer(for: TimerModel.self, configurations: config)
    context = ModelContext(container)
    repo = SwiftDataTimerRepository(context: context)
  }

  func test_insert_fetch_update_delete() throws {
    // 1) Insert
    let created = try repo.insert(title: "공부", iconName: "🔥", goalMinutes: 50)
    XCTAssertEqual(created.title, "공부")
    XCTAssertEqual(created.goalTime, 50)

    // 2) Fetch
    var all = try repo.fetchAll()
    XCTAssertEqual(all.count, 1)
    XCTAssertEqual(all.first?.title, "공부")

    // 3) Update
    try repo.update(id: created.timerID, title: "개발", iconName: "💻", goalMinutes: 120)
    all = try repo.fetchAll()
    XCTAssertEqual(all.first?.title, "개발")
    XCTAssertEqual(all.first?.iconName, "💻")
    XCTAssertEqual(all.first?.goalTime, 120)

    // 4) Delete
    try repo.delete(id: created.timerID)
    all = try repo.fetchAll()
    XCTAssertEqual(all.count, 0)
  }

  func test_update_nonexistent_should_not_throw() throws {
    // 존재하지 않는 ID 업데이트해도 크래시/throw 없이 무시되는지 확인
    let random = UUID()
    XCTAssertNoThrow(try repo.update(id: random, title: "x", iconName: "x", goalMinutes: 1))
  }
}