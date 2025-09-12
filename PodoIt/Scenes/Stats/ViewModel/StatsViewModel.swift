//
//  StatsViewModel.swift
//  PodoIt
//
//  Created by 김이든 on 9/2/25.
//

import Foundation
import RxCocoa
import RxSwift

final class StatsViewModel {
  // MARK: - Inputs

  let selectedDate = BehaviorRelay<Date>(value: Date()) // 캘린더에서 고른 날짜
  let selectedSegmentIndex = BehaviorRelay<Int>(value: 0) // 탭바 일간/월간
  let selectedCategory = BehaviorRelay<StatsCategoryModel>(value: .all)
  // 달 범위 입력 (VC가 CalendarView.visibleMonth를 바인딩)
  let visibleMonthRange = BehaviorRelay<(start: Date, end: Date)>(value: (.distantPast, .distantPast))


  // MARK: - Outputs

  let categories = BehaviorRelay<[StatsCategoryModel]>(value: [.all])
  private(set) lazy var summary: Driver<SummaryUI> = buildSummary()
  // 달의 일별 집중 분 출력
  private(set) lazy var monthHeatMap: Driver<[Int: Int]> = makeMonthHeatMap()
  let isTodaySelected: Driver<Bool>

  // MARK: - Private

  private let repo: StatsRepository
  private let bag = DisposeBag()
  private static let empty = SummaryUI(items: [], totalText: "0분")

  init(repo: StatsRepository = SwiftDataManager.shared) {
    self.repo = repo
    
    self.isTodaySelected = selectedDate
      .asDriver()
      .map { Calendar.current.isDateInToday($0) }
      .distinctUntilChanged()

    NotificationCenter.default.rx.notification(.statsDidChange)
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in self?.reloadCategories() })
      .disposed(by: bag)
  }

  func viewDidLoad() { reloadCategories() }
  func didSelect(category: StatsCategoryModel) { selectedCategory.accept(category) }

  // MARK: - Category

  private func reloadCategories() {
    let list = (try? repo.fetchDistinctCategories()) ?? []
    let current = list.isEmpty ? [.all] : list
    categories.accept(current)

    // 현재 선택된 카테고리가 사라졌으면 "전체"로 복구
    if !current.contains(selectedCategory.value) {
      selectedCategory.accept(.all)
    }
  }

  // MARK: - Summary

  private func buildSummary() -> Driver<SummaryUI> {
    let refresh = NotificationCenter.default.rx
      .notification(.statsDidChange)
      .map { _ in () }
      .startWith(())

    return Observable
      .combineLatest(selectedCategory, selectedDate, selectedSegmentIndex, refresh)
      .observe(on: MainScheduler.instance)
      .map { [weak self] category, date, seg, _ -> SummaryUI in
        guard let self else { return Self.empty }
        let period = self.makePeriod(date: date, segmentIndex: seg)

        do {
          let rows = try self.repo.fetchStats(from: period.start, to: period.end, categoryName: category.name)
          return self.makeSummary(from: rows, categoryName: category.name)
        } catch {
          return Self.empty
        }
      }
      .asDriver(onErrorJustReturn: Self.empty)
  }

  // MARK: - Period

  private struct Period { let start: Date; let end: Date }

  private func makePeriod(date: Date, segmentIndex: Int, calendar: Calendar = .current) -> Period {
    if segmentIndex == 0 { // 일간
      let start = calendar.startOfDay(for: date)
      let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86400)
      return Period(start: start, end: end)
    } else { // 월간
      let comps = calendar.dateComponents([.year, .month], from: date)
      let monthStart = calendar.date(from: comps) ?? calendar.startOfDay(for: date)
      let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart.addingTimeInterval(86400)
      return Period(start: monthStart, end: monthEnd)
    }
  }

  // MARK: - Summary Stats

  private func makeSummary(from rows: [StatsModel], categoryName: String) -> SummaryUI {
    // 특정 카테고리
    if categoryName != "전체" {
      guard !rows.isEmpty else { return Self.empty }
      let total = rows.reduce(0) { $0 + seconds(hms: $1.time) }
      let icon = (try? repo.fetchLatestIcon(for: categoryName)) ?? "🟣"
      let item = StatsSummaryModel(icon: icon, title: categoryName, stats: label(fromSeconds: total))
      return SummaryUI(items: [item], totalText: label(fromSeconds: total))
    }

    // 전체: 카테고리별 합계
    let grouped = Dictionary(grouping: rows, by: { $0.category })
    var items: [StatsSummaryModel] = []
    items.reserveCapacity(grouped.count)

    for (name, list) in grouped {
      let total = list.reduce(0) { $0 + seconds(hms: $1.time) }
      let icon = (try? repo.fetchLatestIcon(for: name)) ?? ""
      items.append(.init(icon: icon, title: name, stats: label(fromSeconds: total)))
    }

    items.sort { first, second in
      let a = seconds(fromLabel: first.stats)
      let b = seconds(fromLabel: second.stats)

      if a != b {
        return a > b // 시간 내림차순
      }
      return first.title.localizedStandardCompare(second.title) == .orderedAscending // 가나다순
    }
    let grandTotal = rows.reduce(0) { $0 + seconds(hms: $1.time) }
    return SummaryUI(items: items, totalText: label(fromSeconds: grandTotal))
  }

  // MARK: - Time helpers

  // "h:mm:ss" → 초
  private func seconds(hms: String) -> Int {
    let parts = hms.split(separator: ":").compactMap { Int($0) }
    guard parts.count == 3 else { return 0 }
    return parts[0] * 3600 + parts[1] * 60 + parts[2]
  }

  // 초 → "X시간 YY분" 또는 "M분"
  private func label(fromSeconds s: Int) -> String {
    let h = s / 3600
    let m = (s % 3600) / 60
    return h == 0 ? "\(m)분" : String(format: "%d시간 %02d분", h, m)
  }

  // "X시간 Y분" / "Y분" → 초
  private func seconds(fromLabel text: String) -> Int {
    if let hourRange = text.range(of: "시간") {
      let h = Int(text[..<hourRange.lowerBound].trimmingCharacters(in: .whitespaces)) ?? 0
      let after = text[hourRange.upperBound...]
      let m = after
        .split(separator: "분")
        .first
        .flatMap { Int($0.trimmingCharacters(in: .whitespaces)) } ?? 0
      return h * 3600 + m * 60
    } else if let minuteRange = text.range(of: "분") {
      let m = Int(text[..<minuteRange.lowerBound].trimmingCharacters(in: .whitespaces)) ?? 0
      return m * 60
    }
    return 0
  }
  
  // MARK: - MonthHeatMap
  
  private func makeMonthHeatMap() -> Driver<[Int: Int]> {
    let refresh = NotificationCenter.default.rx
      .notification(.statsDidChange)
      .map { _ in () }
      .startWith(()) // 최초 1회

    return Observable
      .combineLatest(selectedCategory.asObservable(),
                     visibleMonthRange.asObservable(),
                     refresh)
      .observe(on: MainScheduler.instance)
      .map { [weak self] category, month, _ -> [Int: Int] in
        guard let self = self else { return [:] }

        // 저장소에서 해당 달/카테고리의 기록 로드
        let rows = (try? self.repo.fetchStats(from: month.start, to: month.end, categoryName: category.name)) ?? []

        // 일(day)별 총 "분"으로 누적
        var minutesByDay: [Int: Int] = [:]
        let cal = Calendar.current
        for r in rows {
          let parts = r.time.split(separator: ":").compactMap { Int($0) } // "h:mm:ss"
          let sec = (parts.count == 3) ? (parts[0]*3600 + parts[1]*60 + parts[2]) : 0
          let day = cal.component(.day, from: r.date)
          minutesByDay[day, default: 0] += sec / 60
        }
        return minutesByDay
      }
      .asDriver(onErrorJustReturn: [:])
  }
}
