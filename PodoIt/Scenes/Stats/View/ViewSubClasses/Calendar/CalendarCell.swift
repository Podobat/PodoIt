//
//  CalendarCell.swift
//  PodoIt
//
//  Created by 김이든 on 8/28/25.
//

import UIKit

final class CalendarCell: UICollectionViewCell {
  static let identifier = "CalendarCollectionViewCell"

  // MARK: - Properties

  private lazy var dayLabel = UILabel().then {
    $0.textColor = .gray800
    $0.font = Typography.font(for: .labelMd(weight: .regular))
  }

  // MARK: - Init

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }

  // MARK: - Methods

  override func prepareForReuse() {
    dayLabel.text = nil
  }

  func update(day: String) {
    dayLabel.text = day
  }

  private func configure() {
    [dayLabel].forEach {
      addSubview($0)
    }

    dayLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
}
