//
//  StatsViewController.swift
//  PodoIt
//
//  Created by 노가현 on 8/20/25.
//

import SnapKit
import Then
import UIKit

final class StatsViewController: UIViewController {
  // MARK: - Properties

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
}
