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
    $0.isLayoutMarginsRelativeArrangement = true
    $0.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 24, leading: 0, bottom: 24, trailing: 0)
  }

  private let title = UILabel().then {
    $0.text = "timer시간과 목표 시간을 나타내는 공간"
  }

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
    backgroundColor = .red
    addSubview(vStackView)
    vStackView.addArrangedSubview(title)
  }

  private func configureLayout() {
    vStackView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
}
