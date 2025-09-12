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
    $0.setAttributedTitle(
      Typography.attributed("전체", style: .headingLg, color: .appBlack),
      for: .normal
    )
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

  let todayButton = UIButton(type: .system).then {
    $0.setAttributedTitle(
      Typography.attributed("오늘", style: .labelMd(weight: .semibold), color: .primary600),
      for: .normal
    )
    $0.backgroundColor = .primary100
    // 버튼 이미지 설정
    let image = UIImage(named: "rotate-ccw")?
      .withConfiguration(
        UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
      )
      .withRenderingMode(.alwaysTemplate)
    $0.setImage(image, for: .normal)
    $0.tintColor = .primary600
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.primary200.cgColor
    $0.layer.cornerRadius = 18 // 버튼 전체 패딩
    $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 16)
    // 이미지-텍스트 간격
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
  }

  private let spacerView = UIView()

  private lazy var hStack = UIStackView(arrangedSubviews: [categoryButton, spacerView, todayButton]).then {
    $0.axis = .horizontal
    $0.distribution = .fill
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
    container.contentView.addSubview(hStack)
  }

  private func setupConstraints() {
    categoryButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
    categoryButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    todayButton.setContentHuggingPriority(.required, for: .horizontal)
    todayButton.setContentCompressionResistancePriority(.required, for: .horizontal)

    container.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    hStack.snp.makeConstraints {
      $0.edges.equalToSuperview()
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
    let title = makeTitle(for: category)
    categoryButton.setAttributedTitle(
      Typography.attributed(title, style: .headingLg, color: .appBlack),
      for: .normal
    )
  }
}
