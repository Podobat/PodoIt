//
//  StatsHeaderView.swift
//  PodoIt
//
//  Created by 김이든 on 8/23/25.
//

import SnapKit
import Then
import UIKit

final class StatsHeaderView: UIView {
  private enum Layout {
    static let horizontalPadding: CGFloat = 20
    static let verticalPadding: CGFloat = 16
  }

  private let container = PaddedContainerView(horizontal: Layout.horizontalPadding, vertical: Layout.verticalPadding).then {
    $0.backgroundColor = .appWhite
  }

  let categoryButton = UIButton(type: .system).then {
    // 타이틀
    $0.setTitle("전체", for: .normal)
    $0.titleLabel?.font = Typography.font(for: .headingMd)
    $0.setTitleColor(.appBlack, for: .normal)
    // 버튼 style
    $0.backgroundColor = .appWhite
    // 버튼 이미지 설정
    let image = UIImage(named: "chevron-down")?.withRenderingMode(.alwaysTemplate)
    $0.setImage(image, for: .normal)
    $0.tintColor = .appBlack
    // 텍스트 오른쪽, 이미지 왼쪽 기본 동작을 반대로
    $0.semanticContentAttribute = .forceRightToLeft
    // 텍스트와 이미지 간 간격
    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureUI() {
    setupView()
    setupConstraints()
  }

  private func setupView() {
    [container].forEach { addSubview($0) }
    [categoryButton].forEach { container.contentView.addSubview($0) }
  }

  private func setupConstraints() {
    container.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    categoryButton.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview()
      $0.leading.equalToSuperview()
    }
  }

  func updateCategory(_ category: StatsCategoryModel) {
    if let icon = category.icon {
      categoryButton.setTitle("\(icon) " + "\(category.name)".limited(to: 8, addEllipsis: true), for: .normal)
    } else {
      categoryButton.setTitle(category.name, for: .normal)
    }
  }
}
