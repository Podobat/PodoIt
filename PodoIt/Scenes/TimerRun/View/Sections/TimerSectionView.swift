//
//  TimerSectionView.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import SnapKit
import Then
import UIKit

final class TimerSectionView: UIView {
  private let vStackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .center
    $0.spacing = 8
  }

  private let goalTimeContainerView = UIView().then { // 아이콘 + 목표 시간/달성 Label
    $0.layer.cornerRadius = 14
    $0.backgroundColor = .gray100
  }

  private let goalIconImageView = UIImageView().then { // 아이콘
    $0.image = UIImage(named: "flag")
    $0.contentMode = .scaleAspectFit
  }

  private let goalTimeLabel = UILabel.makeAttributed( // 목표 시간/달성 Label
    text: "49:59",
    style: .labelMd(weight: .medium),
    color: .gray900
  )

  private let runningTimeLabel = UILabel.makeAttributed(
    text: "0:00:00",
    style: .displayLg(weight: .bold),
    color: .appBlack,
    alignment: .center
  )

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    configureLayout()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureUI() {
    backgroundColor = .appWhite
    addSubview(vStackView)
    [goalTimeContainerView, runningTimeLabel].forEach { vStackView.addArrangedSubview($0) }
    [goalIconImageView, goalTimeLabel].forEach { goalTimeContainerView.addSubview($0) }
  }

  private func configureLayout() {
    vStackView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(8)
      $0.leading.trailing.equalToSuperview().inset(20)
    }

    goalIconImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(8)
      $0.centerY.equalTo(goalTimeLabel.snp.centerY) // 라벨과 같은 세로선
      $0.size.equalTo(16)
    }

    goalTimeLabel.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(4)
      $0.leading.equalTo(goalIconImageView.snp.trailing).offset(4)
      $0.trailing.equalToSuperview().inset(8)
    }
  }
}
