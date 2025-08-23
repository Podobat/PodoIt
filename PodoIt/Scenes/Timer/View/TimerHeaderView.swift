//
//  TimerHeaderView.swift
//  PodoIt
//
//  Created by 노가현 on 8/23/25.
//

import SnapKit
import Then
import UIKit

final class TimerHeaderView: UIView {
  private let dateLabel = UILabel.makeAttributed(
    text: "8월 19일", style: .headingLg, color: .appBlack, alignment: .left
  )

  private let dividerView = UIView().then {
    $0.backgroundColor = .gray100
  }

  private let descriptionLabel = UILabel.makeAttributed(
    text: "오늘의 집중 시간", style: .labelMd(weight: .semibold), color: .gray500, alignment: .left
  )

  private let timeLabel = UILabel.makeAttributed(
    text: "00:00:00", style: .displayMd(weight: .bold), color: .appBlack, alignment: .left
  )

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    setupConstraints()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    for item in [dateLabel, dividerView, descriptionLabel, timeLabel] {
      addSubview(item)
    }
  }

  private func setupConstraints() {
    dateLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalToSuperview()
    }

    dividerView.snp.makeConstraints {
      $0.top.equalTo(dateLabel.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(1)
    }

    descriptionLabel.snp.makeConstraints {
      $0.top.equalTo(dividerView.snp.bottom).offset(16)
      $0.leading.equalToSuperview()
    }

    timeLabel.snp.makeConstraints {
      $0.top.equalTo(descriptionLabel.snp.bottom).offset(2)
      $0.leading.equalToSuperview()
      $0.bottom.equalToSuperview() // 전체 높이 계산
    }
  }
}
