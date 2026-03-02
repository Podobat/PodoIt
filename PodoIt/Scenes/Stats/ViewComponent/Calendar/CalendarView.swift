//
//  CalendarView.swift
//  PodoIt
//
//  Created by 김이든 on 8/28/25.
//

import RxCocoa
import RxRelay
import RxSwift
import SnapKit
import Then
import UIKit

final class CalendarView: UIView {
  // MARK: - Metrics

  private enum Metrics {
    static let headerVerticalPadding: CGFloat = 15
    static let buttonHorizontalPadding: CGFloat = 40
    static let buttonSize: CGFloat = 44
    static let calendarPadding: CGFloat = 16
    static let weekStackViewTopPadding: CGFloat = 23
    static let weekStackViewBottomPadding: CGFloat = 4
  }

  // MARK: - Properties

  private let disposeBag = DisposeBag()

  private let selectedDateRelay = BehaviorRelay<Date>(value: Date())
  var selectedDate: Observable<Date> { selectedDateRelay.asObservable() }

  // 현재 보이는 달 범위 방송 (달 시작 ~ 다음달 시작)
  private let visibleMonthRelay = BehaviorRelay<(start: Date, end: Date)>(value: (Date(), Date()))
  var visibleMonth: Observable<(start: Date, end: Date)> { visibleMonthRelay.asObservable() }

  // heat 데이터: 키 = 일(day, 1~31), 값 = 총 분
  private var heatMinutesByDay: [Int: Int] = [:]

  private var lastSelectedDate: Date? = Date() // 앱 시작 시 오늘을 기본 선택으로

  private lazy var titleLabel = UILabel.makeAttributed(
    text: "", style: .labelLg, color: .gray900
  )

  private let previousButton = UIButton().then {
    let image = UIImage(named: "chevron-left")?.withRenderingMode(.alwaysTemplate)
    $0.setImage(image, for: .normal)
    $0.tintColor = .gray500
    $0.imageView?.contentMode = .scaleAspectFit
  }

  private let nextButton = UIButton().then {
    let image = UIImage(named: "chevron-right")?.withRenderingMode(.alwaysTemplate)
    $0.setImage(image, for: .normal)
    $0.tintColor = .gray500
    $0.backgroundColor = .clear
    $0.imageView?.contentMode = .scaleAspectFit
  }

  private lazy var weekStackView = UIStackView().then {
    $0.distribution = .fillEqually
  }

  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
    $0.backgroundColor = .clear
    $0.dataSource = self
    $0.delegate = self
    $0.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.identifier)
    $0.clipsToBounds = false
  }

  private let calendar = Calendar.current
  private let dateFormatter = DateFormatter()
  private var calendarDate = Date()
  private var days: [(day: String, isToday: Bool)] = []

  private var collectionViewHeightConstraint: Constraint?

  // MARK: - Init

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configureUI()
    bind()
  }

  // MARK: - Methods

  override func layoutSubviews() {
    super.layoutSubviews()
    updateCollectionViewHeight()
  }

  private func configureUI() {
    setupView()
    setupConstraints()
    configureWeekLabel()
    configureCalendar()
  }

  private func setupView() {
    backgroundColor = .appWhite
    [titleLabel, previousButton, nextButton, weekStackView, collectionView].forEach { addSubview($0) }
  }

  private func setupConstraints() {
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(Metrics.headerVerticalPadding)
      $0.centerX.equalToSuperview()
    }

    previousButton.snp.makeConstraints {
      $0.size.equalTo(Metrics.buttonSize)
      $0.leading.equalToSuperview().inset(Metrics.buttonHorizontalPadding)
      $0.centerY.equalTo(titleLabel.snp.centerY)
    }

    nextButton.snp.makeConstraints {
      $0.size.equalTo(Metrics.buttonSize)
      $0.trailing.equalToSuperview().inset(Metrics.buttonHorizontalPadding)
      $0.centerY.equalTo(titleLabel.snp.centerY)
    }

    weekStackView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(Metrics.weekStackViewTopPadding)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Metrics.calendarPadding)
    }

    collectionView.snp.makeConstraints {
      $0.top.equalTo(weekStackView.snp.bottom).offset(Metrics.weekStackViewBottomPadding)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Metrics.calendarPadding)
      collectionViewHeightConstraint = $0.height.equalTo(0).constraint
      $0.bottom.equalToSuperview().inset(8).priority(.low)
    }
  }

  private func configureWeekLabel() {
    let dayOfTheWeek = calendar.shortWeekdaySymbols
    for day in dayOfTheWeek {
      let label = UILabel()
      let attr = Typography.attributed(
        day,
        style: .captionLg(weight: .semibold),
        color: .gray300
      )
      label.attributedText = attr
      label.textAlignment = .center
      weekStackView.addArrangedSubview(label)
    }
  }

  private func updateCollectionViewHeight() {
    collectionView.layoutIfNeeded()
    let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
    collectionViewHeightConstraint?.update(offset: contentHeight)
  }

  // 선택 복구 유틸
  private func indexPath(for date: Date) -> IndexPath? {
    let comps = calendar.dateComponents([.year, .month, .day], from: date)
    let current = calendar.dateComponents([.year, .month], from: calendarDate)
    guard comps.year == current.year,
          comps.month == current.month,
          let day = comps.day else { return nil }

    let start = startDayOfTheWeek()
    return IndexPath(item: start + (day - 1), section: 0)
  }

  private func restoreSelection() {
    guard let last = lastSelectedDate,
          let ip = indexPath(for: last) else { return }

    collectionView.selectItem(at: ip, animated: false, scrollPosition: [])
    (collectionView.cellForItem(at: ip) as? CalendarCell)?.isSelected = true
  }
  
  private func defaultSelectionDate(for month: Date) -> Date {
    let comps = calendar.dateComponents([.year, .month], from: month)
    let firstDayOfMonth = calendar.date(from: comps) ?? month

    // 오늘(Date())이 month와 같은 연/월인지 비교
    if calendar.isDate(Date(), equalTo: firstDayOfMonth, toGranularity: .month) {
      return Date()
    } else {
      return firstDayOfMonth
    }
  }

  // 히트맵 주입 시 선택 복구 호출
  func applyHeat(_ minutesByDay: [Int: Int]) {
    heatMinutesByDay = minutesByDay
    collectionView.reloadData()
    collectionView.layoutIfNeeded()
    restoreSelection()
  }
}

// MARK: - CollectionView DataSoure, Delegate

extension CalendarView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    return days.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: CalendarCell.identifier,
      for: indexPath
    ) as? CalendarCell else { return UICollectionViewCell() }

    let info = days[indexPath.item]
    let minutes = Int(info.day).flatMap { heatMinutesByDay[$0] } ?? 0
    cell.update(day: info.day, isToday: info.isToday, focusMinutes: minutes)
    return cell
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout _: UICollectionViewLayout,
                      sizeForItemAt _: IndexPath) -> CGSize
  {
    let width = collectionView.bounds.width / 7
    return CGSize(width: width, height: width)
  }

  func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
    return .zero
  }

  func collectionView(_: UICollectionView,
                      layout _: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt _: Int) -> CGFloat
  {
    return 0
  }

  func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard !days[indexPath.item].day.isEmpty else { return }
    let dayNumber = Int(days[indexPath.item].day) ?? 1

    var comps = calendar.dateComponents([.year, .month], from: calendarDate)
    comps.day = dayNumber
    if let date = calendar.date(from: comps) {
      // 선택된 날짜 방출
      selectedDateRelay.accept(date)
      lastSelectedDate = date
    }
    #if DEBUG
    print("선택된 날짜: \(titleLabel.text ?? "") \(dayNumber)일")
    #endif
  }

  func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    return !days[indexPath.item].day.isEmpty
  }
}

extension CalendarView {
  private func configureCalendar() {
    dateFormatter.dateFormat = "yyyy년 M월"
    today()
  }

  private func startDayOfTheWeek() -> Int {
    return calendar.component(.weekday, from: calendarDate) - 1
  }

  private func endDate() -> Int {
    return calendar.range(of: .day, in: .month, for: calendarDate)?.count ?? Int()
  }

  private func updateCalendar() {
    updateTitle()
    updateDays()
    updateVisibleMonthBroadcast()
  }

  private func updateTitle() {
    let date = dateFormatter.string(from: calendarDate)
    titleLabel.attributedText = Typography.attributed(
      date,
      style: .labelLg,
      color: .gray900
    )
  }

  private func updateDays() {
    days.removeAll()

    let startDayOfTheWeek = self.startDayOfTheWeek()
    let totalDays = startDayOfTheWeek + endDate()

    let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
    let currentComponents = calendar.dateComponents([.year, .month], from: calendarDate)

    var selectedIndexPath: IndexPath?

    for day in 0 ..< totalDays {
      if day < startDayOfTheWeek {
        days.append(("", false))
        continue
      }
      let dayNumber = day - startDayOfTheWeek + 1
      let isToday = (
        todayComponents.year == currentComponents.year &&
          todayComponents.month == currentComponents.month &&
          todayComponents.day == dayNumber
      )
      days.append(("\(dayNumber)", isToday))
    }

    collectionView.reloadData()
    collectionView.layoutIfNeeded()

    if let last = lastSelectedDate {
      let lastComps = calendar.dateComponents([.year, .month, .day], from: last)
      if lastComps.year == currentComponents.year,
         lastComps.month == currentComponents.month,
         let day = lastComps.day
      {
        let item = startDayOfTheWeek + (day - 1)
        selectedIndexPath = IndexPath(item: item, section: 0)
      }
    }
    if let indexPath = selectedIndexPath {
      collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
    }

    updateCollectionViewHeight()
  }

  private func changeMonth(by offset: Int) {
    // 새 달 계산 (offset이 -1이면 이전 달, +1이면 다음 달)
    calendarDate = calendar.date(byAdding: .month, value: offset, to: calendarDate) ?? calendarDate

    // 새 달에서 선택할 날짜 결정 (오늘 or 1일)
    let newSelection = defaultSelectionDate(for: calendarDate)

    lastSelectedDate = newSelection
    selectedDateRelay.accept(newSelection)

    updateCalendar()
  }

  // 이전 달로 이동
  private func minusMonth() {
    changeMonth(by: -1)
  }

  // 다음 달로 이동
  private func plusMonth() {
    changeMonth(by: 1)
  }

  private func today() {
    let components = calendar.dateComponents([.year, .month], from: Date())
    calendarDate = calendar.date(from: components) ?? Date()
    updateCalendar()

    // 오늘 날짜 한 번 방출 (초기 상태 전달)
    selectedDateRelay.accept(Date())
    lastSelectedDate = Date()

    restoreSelection()
  }

  private func monthRange(for date: Date) -> (start: Date, end: Date) {
    let comps = calendar.dateComponents([.year, .month], from: date)
    let start = calendar.date(from: comps) ?? calendar.startOfDay(for: date)
    let end = calendar.date(byAdding: .month, value: 1, to: start) ?? start.addingTimeInterval(86400)
    return (start, end)
  }

  private func updateVisibleMonthBroadcast() {
    let r = monthRange(for: calendarDate)
    visibleMonthRelay.accept((r.start, r.end))
  }

  func goToToday() {
    today()
  }
}

// MARK: - Bind

extension CalendarView {
  private func bind() {
    previousButton.rx.tap
      .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        self?.minusMonth()
      })
      .disposed(by: disposeBag)

    nextButton.rx.tap
      .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        self?.plusMonth()
      })
      .disposed(by: disposeBag)
  }
}
