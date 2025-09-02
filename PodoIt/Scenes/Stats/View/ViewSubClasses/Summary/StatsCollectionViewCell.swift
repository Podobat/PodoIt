//
//  StatsCollectionViewCell.swift
//  PodoIt
//
//  Created by 김이든 on 8/26/25.
//

import UIKit

final class StatsCollectionViewCell: UICollectionViewCell {
  static let reuseIdentifier = "StatsCollectionViewCell"

  // MARK: - Metrics

  private enum Metrics {
    static let emojiFont: CGFloat = 18
    static let hStackSpacing: CGFloat = 8
  }

  // MARK: - Properties

  private let iconLabel = UILabel().then {
    $0.font = .systemFont(ofSize: Metrics.emojiFont)
    $0.textAlignment = .left
  }

  private let titleLabel = UILabel().then {
    $0.font = Typography.font(for: .bodyMd(weight: .medium))
    $0.textColor = .gray500
    $0.textAlignment = .left
  }

  private lazy var hStack = UIStackView(arrangedSubviews: [iconLabel, titleLabel]).then {
    $0.axis = .horizontal
    $0.spacing = Metrics.hStackSpacing
  }

  private let timeLabel = UILabel().then {
    $0.font = Typography.font(for: .bodyMd(weight: .medium))
    $0.textColor = .gray700
    $0.textAlignment = .right
  }

  // MARK: - Init

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - SetupUI

  private func setupUI() {
    [hStack, timeLabel].forEach {
      contentView.addSubview($0)
    }

    hStack.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.centerY.equalToSuperview()
    }

    timeLabel.snp.makeConstraints {
      $0.trailing.equalToSuperview()
      $0.centerY.equalToSuperview()
    }
  }

  // MARK: - Configure

  func configure(icon: String, title: String, stats: String) {
    iconLabel.text = icon
    titleLabel.text = title
    timeLabel.text = stats
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    iconLabel.text = nil
    titleLabel.text = nil
    timeLabel.text = nil
  }
}
