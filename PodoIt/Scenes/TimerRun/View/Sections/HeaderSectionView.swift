//
//  HeaderSectionView.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import SnapKit
import Then
import UIKit

final class HeaderSectionView: UIView {
  private let hStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.isLayoutMarginsRelativeArrangement = true
    $0.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
  }

  private let title = UILabel().then {
    $0.text = "제목 라벨"
    $0.textAlignment = .center
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
    backgroundColor = .purple
    addSubview(hStackView)
    hStackView.addArrangedSubview(title)
  }

  private func configureLayout() {
    hStackView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
}
