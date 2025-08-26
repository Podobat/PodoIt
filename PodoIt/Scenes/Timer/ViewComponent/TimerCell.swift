//
//  TimerCell.swift
//  PodoIt
//
//  Created by 노가현 on 8/25/25.
//

import SnapKit
import Then
import UIKit

final class TimerCell: UICollectionViewCell {
  static let reuseIdentifier = "TimerCell"

  // MARK: - Metrics

  private enum Metrics {
    static let cornerRadius: CGFloat = 12
    static let emojiFrame: CGFloat = 28
    static let emojiFont: CGFloat = 18
    static let playSize: CGFloat = 32
    static let stackHPadding: CGFloat = 16
    static let stackVPadding: CGFloat = 20
    static let interItemSpacing: CGFloat = 10
    static let titleMetaSpacing: CGFloat = 8
    static let metaAfterFocusVal: CGFloat = 18
    static let metaAfterToday: CGFloat = 10
    static let buttonTrailingSpacing: CGFloat = 8
  }

  // MARK: - UI

  private let emojiFrameView = UIView().then {
    $0.backgroundColor = .gray100
    $0.layer.cornerRadius = Metrics.emojiFrame / 2
    $0.clipsToBounds = true
  }

  private let iconLabel = UILabel().then {
    $0.font = .systemFont(ofSize: Metrics.emojiFont) // 20x20
    $0.textAlignment = .center
  }

  private let titleLabel = UILabel().then {
    $0.font = Typography.font(for: .headingMd)
    $0.textColor = .appBlack
    $0.numberOfLines = 1
    $0.lineBreakMode = .byTruncatingTail
    // 텍스트 스택이 버튼과 충돌 안 나도록 우선순위 명시
    $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
  }

  private let focusPrefixLabel = UILabel().then {
    $0.font = Typography.font(for: .bodyMd(weight: .medium))
    $0.textColor = .gray400
    $0.text = "집중"
  }

  private let focusValueLabel = UILabel().then {
    $0.font = Typography.font(for: .bodyMd(weight: .semibold))
    $0.textColor = .gray700
  }

  private let todayLabel = UILabel().then {
    $0.font = Typography.font(for: .bodyMd(weight: .medium))
    $0.textColor = .gray400
    $0.text = "오늘"
  }

  private let todayValueLabel = UILabel().then {
    let base = Typography.font(for: .bodyMd(weight: .semibold))
    let mono = UIFont.monospacedDigitSystemFont(ofSize: base.pointSize, weight: .semibold)
    $0.font = mono
    $0.textColor = .gray700
    $0.adjustsFontForContentSizeCategory = true // Dynamic Type 대응
  }

  private lazy var metaStack = UIStackView().then {
    $0.addArrangedSubviews([focusPrefixLabel, focusValueLabel, todayLabel, todayValueLabel])
    $0.axis = .horizontal
    $0.alignment = .lastBaseline
    $0.spacing = 8
    $0.setCustomSpacing(Metrics.metaAfterFocusVal, after: focusValueLabel)
    $0.setCustomSpacing(Metrics.metaAfterToday, after: todayLabel)
  }

  private lazy var playButton = UIButton(type: .system).then {
    let image = UIImage(named: "play_fill")?.withRenderingMode(.alwaysOriginal)
    $0.setImage(image, for: .normal)
    $0.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    $0.setContentHuggingPriority(.required, for: .horizontal)
    $0.addTarget(self, action: #selector(handlePlayTapped), for: .touchUpInside)
  }

  var onPlayTapped: (() -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func prepareForReuse() {
    super.prepareForReuse()
    resetLabels()
  }

  private func setupUI() {
    setupContentView()
    addSubviews()
    setupConstraints()
  }

  private func setupContentView() {
    contentView.backgroundColor = .appWhite
    contentView.layer.cornerRadius = Metrics.cornerRadius
    contentView.layer.cornerCurve = .continuous
    contentView.clipsToBounds = true

    selectedBackgroundView = UIView().then {
      $0.backgroundColor = UIColor.gray100.withAlphaComponent(0.5)
    }
  }

  private func addSubviews() {
    contentView.addSubviews([emojiFrameView, titleLabel, metaStack, playButton])
    emojiFrameView.addSubview(iconLabel)
  }

  private func setupConstraints() {
    emojiFrameView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(Metrics.stackHPadding)
      $0.top.equalToSuperview().inset(Metrics.stackVPadding)
      $0.size.equalTo(Metrics.emojiFrame)
    }

    iconLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }

    titleLabel.snp.makeConstraints {
      $0.leading.equalTo(emojiFrameView.snp.trailing).offset(Metrics.interItemSpacing)
      $0.centerY.equalTo(emojiFrameView)
      $0.trailing.lessThanOrEqualTo(playButton.snp.leading).offset(-Metrics.buttonTrailingSpacing)
    }

    metaStack.snp.makeConstraints {
      $0.leading.equalTo(emojiFrameView)
      $0.top.equalTo(emojiFrameView.snp.bottom).offset(Metrics.titleMetaSpacing)
      $0.trailing.lessThanOrEqualTo(playButton.snp.leading).offset(-Metrics.buttonTrailingSpacing)
      $0.bottom.lessThanOrEqualTo(contentView).inset(Metrics.stackVPadding)
    }

    playButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(16)
      $0.centerY.equalToSuperview()
      $0.size.equalTo(Metrics.playSize)
    }
  }

  private func resetLabels() {
    [iconLabel, titleLabel, focusValueLabel, todayValueLabel].forEach { $0.text = nil }
  }

  @objc private func handlePlayTapped() {
    onPlayTapped?()
  }

  // MARK: - Public Methods

  func configure(with timer: TimerModel, today: String = "00:00:00") {
    setupAccessibility(timer: timer, today: today)
    updateContent(timer: timer, today: today)
  }

  private func setupAccessibility(timer: TimerModel, today: String) {
    isAccessibilityElement = true
    accessibilityLabel = "\(timer.title), 집중 목표 \(timer.goalTime)분, 오늘 \(today)"
  }

  private func updateContent(timer: TimerModel, today: String) {
    iconLabel.text = timer.iconName
    titleLabel.text = timer.title
    focusValueLabel.text = "\(timer.goalTime)분"
    todayValueLabel.text = today
  }
}

// MARK: - UIView Extension

extension UIView {
  func addSubviews(_ views: [UIView]) {
    views.forEach(addSubview)
  }
}

// MARK: - UIStackView Extension

extension UIStackView {
  func addArrangedSubviews(_ views: [UIView]) {
    views.forEach(addArrangedSubview)
  }
}
