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
    static let categoryImageSpacing: CGFloat = 2
    static let todayImageSpacing: CGFloat = 4
    static let todayHorizontalPadding: CGFloat = 12
    static let todayVerticalPadding: CGFloat = 8
    static let titleMaxLength: Int = 8
  }

  // MARK: - Properties

  private let container = PaddedContainerView(horizontal: Metrics.horizontalPadding, vertical: Metrics.verticalPadding).then {
    $0.backgroundColor = .appWhite
  }

  let categoryButton = UIButton(type: .system).then { btn in
    var config = UIButton.Configuration.plain()
    config.baseForegroundColor = .appBlack

    // 텍스트
    let title = Typography.attributed("전체", style: .headingMd(weight: .bold), color: .appBlack)
    config.attributedTitle = AttributedString(title)

    // 아이콘 (오른쪽)
    config.image = UIImage.chevronDown.withRenderingMode(.alwaysTemplate)
    config.imagePlacement = .trailing
    config.imagePadding = Metrics.categoryImageSpacing

    // 바깥 여백
    config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)

    // 배경
    var bg = UIBackgroundConfiguration.clear()
    bg.backgroundColor = .clear
    config.background = bg

    btn.configuration = config

    // 잘림 방지
    btn.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  let todayButton = UIButton(type: .system).then { btn in
    var config = UIButton.Configuration.plain()
    config.baseForegroundColor = .primary600

    // 텍스트
    let title = Typography.attributed(
      "오늘",
      style: .labelMd(weight: .semibold),
      color: .primary600
    )
    config.attributedTitle = AttributedString(title)

    // 아이콘 (왼쪽)
    config.image = UIImage.rotateCcw.withRenderingMode(.alwaysTemplate)
    config.imagePlacement = .leading
    config.imagePadding = Metrics.todayImageSpacing

    // 바깥 여백
    config.contentInsets = .init(
      top: Metrics.todayVerticalPadding,
      leading: Metrics.todayHorizontalPadding,
      bottom: Metrics.todayVerticalPadding,
      trailing: Metrics.todayHorizontalPadding
    )

    // 배경/테두리/코너
    var bg = UIBackgroundConfiguration.clear()
    bg.backgroundColor = .primary100
    bg.strokeColor = .primary200
    bg.strokeWidth = 1
    bg.cornerRadius = 18
    config.background = bg

    btn.configuration = config

    // 잘림 방지
    btn.setContentCompressionResistancePriority(.required, for: .horizontal)
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
    spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

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
      Typography.attributed(title, style: .headingMd(weight: .bold), color: .appBlack),
      for: .normal
    )
  }
}
