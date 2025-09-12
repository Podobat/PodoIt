//
//  EmptyStateView.swift
//  PodoIt
//
//  Created by 노가현 on 8/23/25.
//

import SnapKit
import Then
import UIKit

final class EmptyStateView: UIView {
  private let titleLabel = UILabel.makeAttributed(
    text: "타이머가 비어 있어요", style: .headingLg, color: .appBlack, alignment: .center
  )

  private let descriptionLabel = UILabel.makeAttributed(
    text: "공부, 운동, 취미 등\n원하는 활동을 기록해보세요.",
    style: .bodyLg(weight: .medium),
    color: .gray500,
    alignment: .center
  ).then {
    $0.numberOfLines = 0
  }

  private lazy var stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel]).then {
    $0.axis = .vertical
    $0.spacing = 14
    $0.alignment = .center
  }

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
    [titleLabel, descriptionLabel].forEach { addSubview($0) }
    addSubview(stackView)
  }

  private func setupConstraints() {
    titleLabel.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
    }

    descriptionLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(14)
      $0.leading.trailing.bottom.equalToSuperview()
    }

    stackView.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
      $0.centerY.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(20)
    }
  }
}
