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
  }

  // MARK: - UI

  private let emojiFrameView = UIView().then {
    $0.backgroundColor = .gray100
    $0.layer.cornerRadius = 14
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

  private lazy var metaStack = UIStackView(arrangedSubviews: [
    focusPrefixLabel, focusValueLabel, todayLabel, todayValueLabel
  ]).then {
    $0.axis = .horizontal
    $0.alignment = .lastBaseline
    $0.spacing = 8
  }

  private let playButton = UIButton(type: .system).then {
    let image = UIImage(named: "play_fill")?.withRenderingMode(.alwaysOriginal)
    $0.setImage(image, for: .normal)
    $0.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    // 버튼이 줄어들지 않도록 명시
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    $0.setContentHuggingPriority(.required, for: .horizontal)
  }

  var onPlayTapped: (() -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    playButton.addTarget(self, action: #selector(handlePlayTapped), for: .touchUpInside) // [CHANGED]
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func prepareForReuse() {
    super.prepareForReuse()
    iconLabel.text = nil
    titleLabel.text = nil
    focusValueLabel.text = nil
    todayValueLabel.text = nil
  }

  private func setupUI() {
    contentView.backgroundColor = .appWhite
    contentView.layer.cornerRadius = Metrics.cornerRadius
    contentView.layer.cornerCurve = .continuous
    contentView.clipsToBounds = true

    let selectedBG = UIView()
    selectedBG.backgroundColor = UIColor.gray100.withAlphaComponent(0.5)
    selectedBackgroundView = selectedBG

    contentView.addSubview(emojiFrameView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(metaStack)
    contentView.addSubview(playButton)

    emojiFrameView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(Metrics.stackHPadding) // 16
      $0.top.equalToSuperview().inset(Metrics.stackVPadding) // 20
      $0.width.height.equalTo(Metrics.emojiFrame) // 28
    }

    emojiFrameView.addSubview(iconLabel)
    iconLabel.snp.makeConstraints { $0.center.equalToSuperview() }

    titleLabel.snp.makeConstraints {
      $0.leading.equalTo(emojiFrameView.snp.trailing).offset(Metrics.interItemSpacing) // 10
      $0.centerY.equalTo(emojiFrameView.snp.centerY) //  이모지 ↔ 제목 높이
      $0.trailing.lessThanOrEqualTo(playButton.snp.leading).offset(-8)
    }

    metaStack.snp.makeConstraints {
      $0.leading.equalTo(emojiFrameView.snp.leading)
      $0.top.equalTo(emojiFrameView.snp.bottom).offset(Metrics.titleMetaSpacing) // 8
      $0.trailing.lessThanOrEqualTo(playButton.snp.leading).offset(-8)
      $0.bottom.lessThanOrEqualTo(contentView.snp.bottom).inset(Metrics.stackVPadding) // 20
    }

    playButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(16)
      $0.centerY.equalToSuperview()
      $0.width.height.equalTo(Metrics.playSize) // 32
    }

    // 구간별 커스텀 간격
    metaStack.setCustomSpacing(Metrics.metaAfterFocusVal, after: focusValueLabel) // 50분 ↔ 오늘
    metaStack.setCustomSpacing(Metrics.metaAfterToday, after: todayLabel)
  }

  @objc private func handlePlayTapped() { onPlayTapped?() }

  // MARK: - Configure

  func configure(with timer: TimerModel, today: String = "00:00:00") {
    // 접근성 라벨
    isAccessibilityElement = true
    accessibilityLabel = "\(timer.title), 집중 목표 \(timer.goalTime)분, 오늘 \(today)"

    iconLabel.text = timer.iconName
    titleLabel.text = timer.title
    focusValueLabel.text = "\(timer.goalTime)분"
    todayValueLabel.text = today
  }
}
