//
//  StatsViewController.swift
//  PodoIt
//
//  Created by 노가현 on 8/20/25.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class StatsViewController: UIViewController {
  // MARK: - Metrics

  private enum Metrics {
    static let addButtonBottomOffset: CGFloat = -16
    static let addButtonHeight: CGFloat = 36
  }

  // MARK: - Properties

  private let viewModel = StatsViewModel()

  private let disposeBag = DisposeBag()

  private let headerView = StatsHeaderView()
  private let calendarView = CalendarView()
  private let calendarColorView = CalendarColorView()
  private let summaryView = StatsSummaryView()

  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .gray100
    $0.alwaysBounceVertical = true
  }

  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 0
  }

  private let todayButton = UIButton(type: .system).then {
    $0.setAttributedTitle(
      Typography.attributed("오늘 날짜", style: .labelMd(weight: .semibold), color: .primary600),
      for: .normal
    )
    $0.backgroundColor = .primary100
    // 버튼 이미지 설정
    let image = UIImage(named: "rotate-ccw")?
      .withConfiguration(
        UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
      )
      .withRenderingMode(.alwaysTemplate)
    $0.setImage(image, for: .normal)
    $0.tintColor = .primary600
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.primary200.cgColor
    $0.layer.cornerRadius = 18
    $0.layer.shadowColor = UIColor.appBlack.cgColor
    $0.layer.shadowOpacity = 0.08
    $0.layer.shadowRadius = 12
    // 버튼 전체 패딩
    $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 16)
    // 이미지-텍스트 간격
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bind()
    viewModel.viewDidLoad()
  }

  // MARK: - Private Methods

  private func configureUI() {
    view.backgroundColor = .appWhite
    navigationController?.setNavigationBarHidden(true, animated: false)
    setupViews()
    setupConstraints()
  }

  private func setupViews() {
    [headerView, scrollView, todayButton].forEach { view.addSubview($0) }
    scrollView.addSubview(contentStackView)
    [calendarView, calendarColorView, summaryView].forEach { contentStackView.addArrangedSubview($0) }
    calendarView.layer.zPosition = 1
  }

  private func setupConstraints() {
    headerView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.directionalHorizontalEdges.equalToSuperview()
    }

    scrollView.snp.makeConstraints {
      $0.top.equalTo(headerView.snp.bottom)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }

    contentStackView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-48)
      $0.width.equalTo(scrollView.snp.width)
    }

    todayButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(Metrics.addButtonBottomOffset)
      $0.centerX.equalToSuperview()
    }
  }

  private func bind() {
    // 1) 선택된 카테고리 → 헤더 버튼 타이틀 업데이트
    viewModel.selectedCategory
      .asDriver()
      .drive(onNext: { [weak self] category in
        self?.headerView.updateCategory(category)
      })
      .disposed(by: disposeBag)

    // 2) 헤더 버튼 탭 → 시트 표시 (현재 목록/선택값 사용)
    headerView.categoryButton.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .withLatestFrom(Observable.combineLatest(viewModel.categories.asObservable(),
                                               viewModel.selectedCategory.asObservable()))
      .subscribe(onNext: { [weak self] categories, selected in
        self?.presentCategorySheet(categories: categories, selected: selected)
      })
      .disposed(by: disposeBag)

    calendarView.selectedDate
      .bind(to: viewModel.selectedDate)
      .disposed(by: disposeBag)

    summaryView.segmentIndexChanged
      .bind(to: viewModel.selectedSegmentIndex)
      .disposed(by: disposeBag)

    // VM → SummaryView 반영
    Driver.combineLatest(
      viewModel.summary, // SummaryUI(items, totalText)
      viewModel.selectedSegmentIndex.asDriver() // 0=일간, 1=월간
    )
    .drive(onNext: { [weak self] ui, seg in
      self?.summaryView.apply(
        items: ui.items,
        totalTimeText: ui.totalText,
        isDaily: seg == 0
      )
    })
    .disposed(by: disposeBag)

    // 1) 먼저 monthHeatMap을 구독해서 내부 combineLatest가 활성화되게 함
    viewModel.monthHeatMap
      .drive(onNext: { [weak self] heat in
        self?.calendarView.applyHeat(heat)
      })
      .disposed(by: disposeBag)

    // 2) 그 다음 visibleMonthRange에 바인딩 (이 타이밍의 첫 이벤트를 놓치지 않음)
    calendarView.visibleMonth
      .bind(to: viewModel.visibleMonthRange)
      .disposed(by: disposeBag)

    todayButton.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        self?.calendarView.goToToday()
      })
      .disposed(by: disposeBag)
  }

  // MARK: - CategorySheet Presentation

  private func presentCategorySheet(categories: [StatsCategoryModel], selected: StatsCategoryModel) {
    let sheet = CategorySheetViewController(
      categories: categories,
      selectedCategory: selected,
      onSelect: { [weak self] category in
        self?.viewModel.didSelect(category: category)
      }
    )
    present(sheet, animated: true)
  }
}
