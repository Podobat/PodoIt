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
  // MARK: - Properties

  private let disposeBag = DisposeBag()

  private let headerView = StatsHeaderView()
  private let calendarView = CalendarView()
  private let calendarColorView = CalendarColorView()
  private let summaryView = StatsSummaryView()

  private var selectedCategory = StatsCategoryModel.all // 기본 선택값

  // 임시
  private let categories = StatsCategoryModel.items

  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .gray100
    $0.alwaysBounceVertical = true
  }

  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 0
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bind()
  }

  // MARK: - Private Methods

  private func configureUI() {
    view.backgroundColor = .appWhite
    navigationController?.setNavigationBarHidden(true, animated: false)
    setupViews()
    setupConstraints()
  }

  private func setupViews() {
    [headerView, scrollView].forEach { view.addSubview($0) }
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
      $0.edges.equalToSuperview()
      $0.width.equalTo(scrollView.snp.width)
    }
  }

  private func bind() {
    // HeaderView 카테고리 버튼 탭
    headerView.categoryButton.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance) // 연속 탭 방지
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.presentCategorySheet()
      })
      .disposed(by: disposeBag)
  }

  // MARK: - CategorySheet Presentation

  private func presentCategorySheet() {
    let sheet = CategorySheetViewController(
      categories: categories,
      selectedCategory: selectedCategory,
      onSelect: { [weak self] category in
        guard let self = self else { return }
        self.selectedCategory = category

        // HeaderView에 아이콘과 이름 함께 표시
        self.headerView.updateCategory(category)

        // 선택된 카테고리에 맞춰 통계 UI 갱신 - 임시
        self.reloadStatsData(for: category)
      }
    )
    present(sheet, animated: true)
  }

  // MARK: - 통계 데이터 갱신 (임시)

  private func reloadStatsData(for category: StatsCategoryModel) {
    print("선택된 카테고리: \(category.name)")
  }
}
