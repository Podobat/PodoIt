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

  private enum Layout {
    static let headerVerticalPadding: CGFloat = 15
    static let buttonHorizontalPadding: CGFloat = 40
    static let buttonSize: CGFloat = 44
    static let calendarPadding: CGFloat = 16
    static let weekStackViewBottomPadding: CGFloat = 4
  }

  // MARK: - Properties

  private let disposeBag = DisposeBag()

  private let selectedDateRelay = BehaviorRelay<Date>(value: Date())
  var selectedDate: Observable<Date> { selectedDateRelay.asObservable() }

  private lazy var titleLabel = UILabel().then {
    $0.text = "2003년 01월"
    $0.font = Typography.font(for: .labelLg(weight: .semibold))
    $0.textColor = .gray900
  }

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
      $0.top.equalToSuperview().offset(Layout.headerVerticalPadding)
      $0.centerX.equalToSuperview()
    }

    previousButton.snp.makeConstraints {
      $0.size.equalTo(Layout.buttonSize)
      $0.leading.equalToSuperview().inset(Layout.buttonHorizontalPadding)
      $0.centerY.equalTo(titleLabel.snp.centerY)
    }

    nextButton.snp.makeConstraints {
      $0.size.equalTo(Layout.buttonSize)
      $0.trailing.equalToSuperview().inset(Layout.buttonHorizontalPadding)
      $0.centerY.equalTo(titleLabel.snp.centerY)
    }

    weekStackView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(Layout.headerVerticalPadding)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Layout.calendarPadding)
    }

    collectionView.snp.makeConstraints {
      $0.top.equalTo(weekStackView.snp.bottom).offset(Layout.weekStackViewBottomPadding)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Layout.calendarPadding)
      collectionViewHeightConstraint = $0.height.equalTo(0).constraint
      $0.bottom.equalToSuperview().priority(.low)
    }
  }

  private func configureWeekLabel() {
    let dayOfTheWeek = ["일", "월", "화", "수", "목", "금", "토"]
    for day in dayOfTheWeek {
      let label = UILabel()
      label.text = day
      label.textColor = .gray300
      label.font = Typography.font(for: .captionLg(weight: .semibold))
      label.textAlignment = .center
      weekStackView.addArrangedSubview(label)
    }
  }

  private func updateCollectionViewHeight() {
    collectionView.layoutIfNeeded()
    let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
    collectionViewHeightConstraint?.update(offset: contentHeight)
  }
}

// MARK: - CollectionView DataSoure, Delegate

extension CalendarView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    return days.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.identifier, for: indexPath) as? CalendarCell else { return UICollectionViewCell() }
    let day = days[indexPath.item]
    cell.update(day: day.day, isToday: day.isToday)
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
    }
    print("선택된 날짜: \(titleLabel.text ?? "") \(dayNumber)일")
  }
  
  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    return !days[indexPath.item].day.isEmpty
  }
}

extension CalendarView {
  private func configureCalendar() {
    dateFormatter.dateFormat = "yyyy년 MM월"
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
  }

  private func updateTitle() {
    let date = dateFormatter.string(from: calendarDate)
    titleLabel.text = date
  }

  private func updateDays() {
    days.removeAll()

    let startDayOfTheWeek = self.startDayOfTheWeek()
    let totalDays = startDayOfTheWeek + endDate()

    let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
    let currentComponents = calendar.dateComponents([.year, .month], from: calendarDate)

    var todayIndexPath: IndexPath?

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

      // 오늘 날짜일 때만 선택 IndexPath 저장
      if isToday {
        todayIndexPath = IndexPath(item: day, section: 0)
      }
    }

    collectionView.reloadData()
    collectionView.layoutIfNeeded()

    // 오늘 날짜가 있는 달일 때만 선택 적용
    if let indexPath = todayIndexPath {
      collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
    }

    updateCollectionViewHeight()
  }

  private func minusMonth() {
    calendarDate = calendar.date(byAdding: DateComponents(month: -1), to: calendarDate) ?? Date()
    updateCalendar()
  }

  private func plusMonth() {
    calendarDate = calendar.date(byAdding: DateComponents(month: 1), to: calendarDate) ?? Date()
    updateCalendar()
  }

  private func today() {
    let components = calendar.dateComponents([.year, .month], from: Date())
    calendarDate = calendar.date(from: components) ?? Date()
    updateCalendar()

    // 오늘 날짜 한 번 방출 (초기 상태 전달)
    selectedDateRelay.accept(Date())
  }
}

// MARK: - Bind

extension CalendarView {
  private func bind() {
    previousButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.minusMonth()
      })
      .disposed(by: disposeBag)

    nextButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.plusMonth()
      })
      .disposed(by: disposeBag)
  }
}
