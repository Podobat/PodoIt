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
    // 1) 선택된 카테고리 → 헤더 버튼 타이틀 업데이트
    viewModel.selectedCategory
      .asDriver()
      .drive(onNext: { [weak self] category in
        self?.headerView.updateCategory(category)
        // 필요 시: self?.reloadStatsData(for: category)
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

    // 3) 에러 메시지 (있으면 알림)
    viewModel.errorMessage
      .asSignal()
      .emit(onNext: { [weak self] message in
        self?.presentAlert(message: message)
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
        self?.reloadStatsData(for: category)
      }
    )
    present(sheet, animated: true)
  }

  // MARK: - Helpers

  private func presentAlert(message: String) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    present(alert, animated: true)
  }

  // 통계 갱신 훅 (필요 시 구현)
  private func reloadStatsData(for category: StatsCategoryModel) {
    print("선택된 카테고리: \(category.name)")
  }
}
