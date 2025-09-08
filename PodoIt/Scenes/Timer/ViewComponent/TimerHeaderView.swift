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
  private enum Layout {
    static let horizontalPadding: CGFloat = 20
  }

  private let dateLabel: UILabel = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR") // 한국어 로케일
    formatter.dateFormat = "M월 d일"
    let today = formatter.string(from: Date())

    return UILabel.makeAttributed(
      text: today, style: .headingLg, color: .appBlack, alignment: .left
    )
  }()

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
      $0.leading.equalToSuperview().offset(Layout.horizontalPadding)
    }

    dividerView.snp.makeConstraints {
      $0.top.equalTo(dateLabel.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(1)
    }

    descriptionLabel.snp.makeConstraints {
      $0.top.equalTo(dividerView.snp.bottom).offset(16)
      $0.leading.equalToSuperview().offset(Layout.horizontalPadding)
    }

    timeLabel.snp.makeConstraints {
      $0.top.equalTo(descriptionLabel.snp.bottom).offset(2)
      $0.leading.equalToSuperview().offset(Layout.horizontalPadding)
      $0.bottom.equalToSuperview() // 전체 높이 계산
    }
  }
}
