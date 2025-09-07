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
  // MARK: - Metrics

  private enum Metrics {
    static let horizontalPadding: CGFloat = 20
    static let verticalPadding: CGFloat = 16
    static let titleImageSpacing: CGFloat = 4
    static let titleMaxLength: Int = 8
  }

  // MARK: - Properties

  private let container = PaddedContainerView(horizontal: Metrics.horizontalPadding, vertical: Metrics.verticalPadding).then {
    $0.backgroundColor = .appWhite
  }

  let categoryButton = UIButton(type: .system).then {
    $0.setTitle("전체", for: .normal)
    $0.titleLabel?.font = Typography.font(for: .headingMd)
    $0.setTitleColor(.appBlack, for: .normal)
    $0.backgroundColor = .appWhite
    // 버튼 이미지 설정
    let image = UIImage.chevronDown.withRenderingMode(.alwaysTemplate)
    $0.setImage(image, for: .normal)
    $0.tintColor = .appBlack
    // 텍스트 오른쪽, 이미지 왼쪽
    $0.semanticContentAttribute = .forceRightToLeft
    // 텍스트와 이미지 간 간격
    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.titleImageSpacing, bottom: 0, right: 0)
  }

  // MARK: - Init

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Methods

  private func configureUI() {
    setupView()
    setupConstraints()
  }

  private func setupView() {
    addSubview(container)
    container.contentView.addSubview(categoryButton)
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

  // 카테고리 제목 생성
  private func makeTitle(for category: StatsCategoryModel) -> String {
    if let icon = category.icon {
      return "\(icon) " + category.name.limited(to: Metrics.titleMaxLength)
    } else {
      return category.name
    }
  }

  // 카테고리 갱신
  func updateCategory(_ category: StatsCategoryModel) {
    categoryButton.setTitle(makeTitle(for: category), for: .normal)
  }
}
