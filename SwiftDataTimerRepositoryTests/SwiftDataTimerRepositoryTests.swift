//
//  SwiftDataTimerRepositoryTests.swift
//  SwiftDataTimerRepositoryTests
//
//  Created by 노가현 on 8/27/25.
//

@testable import PodoIt
import SwiftData
import XCTest

final class SwiftDataTimerRepositoryTests: XCTestCase {
  var container: ModelContainer!
  var context: ModelContext!
  var repo: SwiftDataTimerRepository!

  override func setUp() async throws {
    // 인메모리 SwiftData 컨테이너
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    container = try ModelContainer(for: TimerModel.self, configurations: config)
    context = ModelContext(container)
    repo = SwiftDataTimerRepository(context: context)
  }

  override func tearDown() {
    container = nil
    context = nil
    repo = nil
  }

  func test_insert_and_fetchAll() throws {
    // when
    let saved = try repo.insert(title: "공부", iconName: "🔥", goalMinutes: 50)

    // then
    let all = try repo.fetchAll()
    XCTAssertEqual(all.count, 1)
    XCTAssertEqual(all.first?.timerID, saved.timerID)
    XCTAssertEqual(all.first?.title, "공부")
    XCTAssertEqual(all.first?.goalTime, 50)
  }

  func test_update() throws {
    let e = try repo.insert(title: "공부", iconName: "🔥", goalMinutes: 50)

    try repo.update(id: e.timerID, title: "개발", iconName: "💻", goalMinutes: 120)

    let fetched = try repo.fetchAll().first
    XCTAssertEqual(fetched?.title, "개발")
    XCTAssertEqual(fetched?.iconName, "💻")
    XCTAssertEqual(fetched?.goalTime, 120)
  }

  func test_delete() throws {
    let e1 = try repo.insert(title: "A", iconName: "😀", goalMinutes: 10)
    _ = try repo.insert(title: "B", iconName: "😎", goalMinutes: 20)

    try repo.delete(id: e1.timerID)

    let all = try repo.fetchAll()
    XCTAssertEqual(all.count, 1)
    XCTAssertEqual(all.first?.title, "B")
  }
}
