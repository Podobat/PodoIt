//
//  CalendarColorView.swift
//  PodoIt
//
//  Created by 김이든 on 8/29/25.
//

import SnapKit
import Then
import UIKit

final class CalendarColorView: UIView {
  // MARK: - Metrics

  private enum Layout {
    static let horizontalPadding: CGFloat = 20
    static let verticalPadding: CGFloat = 8
    static let hStackSpacing: CGFloat = 12
    static let dividerViewHeight: CGFloat = 1
  }

  // MARK: - Properties

  private let container = PaddedContainerView(horizontal: Layout.horizontalPadding, vertical: Layout.verticalPadding).then {
    $0.backgroundColor = .appWhite
  }

  private lazy var hStack = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = Layout.hStackSpacing
    $0.alignment = .center
    $0.distribution = .fill
  }

  private let dividerView = UIView().then {
    $0.backgroundColor = .gray100
  }

  private let items: [CalendarColorModel] = [
    CalendarColorModel(time: "0분", color: UIColor.appWhite),
    CalendarColorModel(time: "~1시간", color: UIColor.primary100),
    CalendarColorModel(time: "1~2시간", color: UIColor.primary300),
    CalendarColorModel(time: "2~3시간", color: UIColor.primary500),
    CalendarColorModel(time: "3시간+", color: UIColor.primary700),
  ]
  private let stroke = 0

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
    makeCalendarColorViews()
    setupConstraints()
  }

  private func makeCalendarColorViews() {
    for (index, item) in items.enumerated() {
      let view = CircleLabelView(
        text: item.time,
        color: item.color,
        isSelected: index == stroke // 첫 번째만 Stoke
      )

      hStack.addArrangedSubview(view)
    }
    [container, dividerView].forEach { addSubview($0) }
    [hStack].forEach { container.contentView.addSubview($0) }
  }

  private func setupConstraints() {
    container.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    dividerView.snp.makeConstraints {
      $0.top.equalTo(container)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(Layout.dividerViewHeight)
    }

    hStack.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview()
      $0.centerX.equalToSuperview()
    }
  }
}

final class CircleLabelView: UIView {
  // MARK: - Metrics

  private enum Layout {
    static let circleViewSize: CGFloat = 12
    static let stackSpacing: CGFloat = 4
    static let borderWidth: CGFloat = 1
  }

  // MARK: - Properties

  private let circleView = UIView()
  private let label = UILabel()

  // MARK: - Init

  init(text: String, color: UIColor, isSelected: Bool = false) {
    super.init(frame: .zero)
    setupCircle(color: color, isSelected: isSelected)
    setupLabel(text: text)
    setupLayout()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError()
  }

  // MARK: - Methods

  private func setupCircle(color: UIColor, isSelected: Bool) {
    circleView.backgroundColor = color
    circleView.layer.cornerRadius = Layout.circleViewSize / 2

    if isSelected {
      circleView.layer.borderColor = UIColor.gray100.cgColor
      circleView.layer.borderWidth = Layout.borderWidth
    }
  }

  private func setupLabel(text: String) {
    label.text = text
    label.font = Typography.font(for: .captionLg(weight: .regular))
    label.textColor = .gray500
  }

  private func setupLayout() {
    let stack = UIStackView(arrangedSubviews: [circleView, label])
    stack.axis = .horizontal
    stack.spacing = Layout.stackSpacing
    stack.alignment = .center

    addSubview(stack)
    stack.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    circleView.snp.makeConstraints { $0.size.equalTo(Layout.circleViewSize) }
  }
}
