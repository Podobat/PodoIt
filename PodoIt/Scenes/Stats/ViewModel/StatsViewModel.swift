//
//  StatsViewModel.swift
//  PodoIt
//
//  Created by 김이든 on 9/2/25.
//

import Foundation
import RxCocoa
import RxSwift

protocol StatsRepository {
  func fetchDistinctCategories() throws -> [StatsCategoryModel]
  func fetchStats(from start: Date, to end: Date, categoryName: String) throws -> [StatsModel]
  func fetchLatestIcon(for categoryName: String) throws -> String?
}

final class StatsViewModel {
  let selectedDate = BehaviorRelay<Date>(value: Date()) // CalendarView.selectedDate 바인딩
  let selectedSegmentIndex = BehaviorRelay<Int>(value: 0) // 0=일간, 1=월간 (StatsSummaryView.segmentIndexChanged 바인딩)

  // Outputs
  let categories = BehaviorRelay<[StatsCategoryModel]>(value: [.all])
  let selectedCategory = BehaviorRelay<StatsCategoryModel>(value: .all)
  let errorMessage = PublishRelay<String>()

  lazy var summary: Driver<SummaryUI> = self.buildSummary()

  private let repo: StatsRepository
  private let disposeBag = DisposeBag()

  init(repo: StatsRepository = SwiftDataManager.shared) {
    self.repo = repo

    // 기존 알림 구독은 그대로 유지
    NotificationCenter.default.rx.notification(.statsDidChange)
      .subscribe(onNext: { [weak self] _ in
        self?.reloadCategories()
      })
      .disposed(by: disposeBag)

    // 저장/변경 시 요약도 재계산
    let refresh = NotificationCenter.default.rx
      .notification(.statsDidChange)
      .map { _ in () }
      .startWith(()) // 최초 1회 트리거

    // 카테고리/날짜/세그/리프레시 → READ → 집계
    summary = Observable
      .combineLatest(selectedCategory, selectedDate, selectedSegmentIndex, refresh)
      .observe(on: MainScheduler.instance) // SwiftData 메인 스레드 안전
      .map { [weak self] category, date, seg, _ -> SummaryUI in
        guard let self else { return .init(items: [], totalText: "0분") }
        let (start, end) = (seg == 0) ? self.dayRange(date) : self.monthRange(date)
        do {
          let rows = try self.repo.fetchStats(from: start, to: end, categoryName: category.name)
          return self.aggregate(rows: rows, categoryName: category.name)
        } catch {
          self.errorMessage.accept("데이터를 불러오지 못했습니다.")
          return .init(items: [], totalText: "0분")
        }
      }
      .asDriver(onErrorJustReturn: .init(items: [], totalText: "0분"))
  }

  // 화면 최초 로드 시 호출
  func viewDidLoad() {
    do {
      let list = try repo.fetchDistinctCategories()
      categories.accept(list.isEmpty ? [.all] : list)
      // 초기 선택값은 항상 .all
      selectedCategory.accept(.all)
    } catch {
      errorMessage.accept("카테고리를 불러오지 못했습니다.")
    }
  }

  // 시트에서 항목 선택 시 호출
  func didSelect(category: StatsCategoryModel) {
    selectedCategory.accept(category)
  }

  // 카테고리 갱신
  private func reloadCategories() {
    do {
      let list = try repo.fetchDistinctCategories()
      categories.accept(list.isEmpty ? [.all] : list)
      if !categories.value.contains(selectedCategory.value) {
        selectedCategory.accept(.all)
      }
    } catch {
      errorMessage.accept("카테고리를 불러오지 못했습니다.")
    }
  }

  // 집계 (전체=카테고리별, 특정=단일)
  private func aggregate(rows: [StatsModel], categoryName: String) -> SummaryUI {
    if categoryName == "전체" {
      // 1) 기간 필터된 rows로 초 합계만 먼저 만든다
      var bucket: [String: Int] = [:] // category -> total seconds
      for r in rows {
        bucket[r.category, default: 0] += parseHMS(r.time)
      }

      // 2) 각 카테고리의 "전역 최신" 아이콘으로 치환
      var items: [StatsSummaryModel] = []
      for (name, sec) in bucket {
        let latestIcon = (try? repo.fetchLatestIcon(for: name)) ?? nil
        let icon = latestIcon ?? ""
        items.append(.init(icon: icon, title: name, stats: formatHM(sec)))
      }

      // 3) 정렬 + totalText
      items.sort { parseHM($0.stats) > parseHM($1.stats) }
      let total = bucket.values.reduce(0, +)
      return .init(items: items, totalText: formatHM(total))
    } else {
      // 특정 카테고리
      if rows.isEmpty { return .init(items: [], totalText: "0분") }

      let total = rows.reduce(0) { $0 + parseHMS($1.time) }
      // 전역 최신 아이콘으로 교체
      let latestIcon = (try? repo.fetchLatestIcon(for: categoryName)) ?? nil
      let icon = latestIcon ?? "🟣"

      let item = StatsSummaryModel(icon: icon, title: categoryName, stats: formatHM(total))
      return .init(items: [item], totalText: formatHM(total))
    }
  }

  // 기간 헬퍼
  private func dayRange(_ date: Date, cal: Calendar = .current) -> (Date, Date) {
    let start = cal.startOfDay(for: date)
    let end = cal.date(byAdding: .day, value: 1, to: start)!
    return (start, end)
  }

  private func monthRange(_ date: Date, cal: Calendar = .current) -> (Date, Date) {
    let comps = cal.dateComponents([.year, .month], from: date)
    let start = cal.date(from: comps)!
    let end = cal.date(byAdding: .month, value: 1, to: start)!
    return (start, end)
  }

  // 포맷/파서
  private func parseHMS(_ s: String) -> Int { // "h:mm:ss" → 초
    let p = s.split(separator: ":").map { Int($0) ?? 0 }
    guard p.count == 3 else { return 0 }
    return p[0] * 3600 + p[1] * 60 + p[2]
  }

  private func formatHM(_ sec: Int) -> String {
    let h = sec / 3600
    let m = (sec % 3600) / 60

    if h == 0 {
      // 시간 없음 → 분만 출력
      return "\(m)분"
    } else {
      // 시간 있음 → 분은 항상 2자리
      return String(format: "%d시간 %02d분", h, m)
    }
  }

  private func parseHM(_ s: String) -> Int { // "X시간 Y분" → 초 (정렬용)
    var h = 0, m = 0
    if let hr = s.range(of: "시간") {
      h = Int(s[..<hr.lowerBound].trimmingCharacters(in: .whitespaces)) ?? 0
      let after = s[hr.upperBound...]
      if let mr = after.range(of: "분") {
        m = Int(after[..<mr.lowerBound].trimmingCharacters(in: .whitespaces)) ?? 0
      }
    } else if let mr = s.range(of: "분") {
      m = Int(s[..<mr.lowerBound].trimmingCharacters(in: .whitespaces)) ?? 0
    }
    return h * 3600 + m * 60
  }

  private func buildSummary() -> Driver<SummaryUI> {
    // 저장되면 즉시 재조회
    let refresh = NotificationCenter.default.rx
      .notification(.statsDidChange)
      .map { _ in () }
      .startWith(())

    return Observable
      .combineLatest(selectedCategory, selectedDate, selectedSegmentIndex, refresh)
      .observe(on: MainScheduler.instance)
      .map { [weak self] category, date, seg, _ -> SummaryUI in
        guard let self else { return .init(items: [], totalText: "0분") }
        let (start, end) = (seg == 0) ? self.dayRange(date) : self.monthRange(date)
        do {
          let rows = try self.repo.fetchStats(from: start, to: end, categoryName: category.name)
          return self.aggregate(rows: rows, categoryName: category.name)
        } catch {
          self.errorMessage.accept("데이터를 불러오지 못했습니다.")
          return .init(items: [], totalText: "0분")
        }
      }
      .asDriver(onErrorJustReturn: .init(items: [], totalText: "0분"))
  }
}
