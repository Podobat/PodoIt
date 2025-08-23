//
//  TimerViewController.swift
//  PodoIt
//
//  Created by 노가현 on 8/20/25.
//

import SnapKit
import Then
import UIKit

final class TimerViewController: UIViewController {
  private let paddedContainer = PaddedContainerView()

  // MARK: - Header

  private let dateLabel = UILabel().then {
    $0.attributedText = Typography.attributed(
      "8월 19일",
      style: .headingLg,
      color: .appBlack
    )
    $0.textAlignment = .left
  }

  private let dividerView = UIView().then {
    $0.backgroundColor = .gray100
  }

  private let descriptionLabel = UILabel().then {
    $0.attributedText = Typography.attributed(
      "오늘의 집중 시간",
      style: .labelMd(weight: .semibold),
      color: .gray500
    )
    $0.textAlignment = .left
  }

  private let timeLabel = UILabel().then {
    $0.attributedText = Typography.attributed(
      "00:00:00",
      style: .displayMd(weight: .bold),
      color: .appBlack
    )
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }

  // MARK: - Private Methods

  private func configureUI() {
    view.backgroundColor = .appWhite

    for item in [dateLabel, dividerView, descriptionLabel, timeLabel] {
      view.addSubview(item)
    }

    dateLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(0)
      $0.leading.equalToSuperview().offset(20)
    }

    dividerView.snp.makeConstraints {
      $0.top.equalTo(dateLabel.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(1)
    }

    descriptionLabel.snp.makeConstraints {
      $0.top.equalTo(dividerView.snp.bottom).offset(16)
      $0.leading.equalToSuperview().offset(20)
    }

    timeLabel.snp.makeConstraints {
      $0.top.equalTo(descriptionLabel.snp.bottom).offset(2)
      $0.leading.equalToSuperview().offset(20)
    }
  }
}
