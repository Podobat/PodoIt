//
//  CalendarCell.swift
//  PodoIt
//
//  Created by 김이든 on 8/28/25.
//

import UIKit

final class CalendarCell: UICollectionViewCell {
  static let identifier = "CalendarCell"

  // MARK: - Properties

  private lazy var dayLabel = UILabel().then {
    $0.textColor = .gray800
    $0.font = Typography.font(for: .labelMd(weight: .regular))
  }

  private let selectionView = UIView().then {
    $0.backgroundColor = .appWhite
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.primary500.cgColor
    $0.layer.cornerRadius = 18
    $0.isHidden = true
  }

  override var isSelected: Bool {
    didSet {
      selectionView.isHidden = !isSelected
    }
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

  override func layoutSubviews() {
    super.layoutSubviews()
    let cornerRadius = selectionView.bounds.width / 2
    selectionView.layer.cornerRadius = cornerRadius

    let path = UIBezierPath(ovalIn: selectionView.bounds).cgPath
    selectionView.layer.shadowPath = path
    selectionView.layer.shadowColor = UIColor.primary600.cgColor
    selectionView.layer.shadowOpacity = 0.20
    selectionView.layer.shadowRadius = 12
  }

  override func prepareForReuse() {
    dayLabel.text = nil
  }

  func update(day: String) {
    dayLabel.text = day
  }

  private func configure() {
    [selectionView, dayLabel].forEach {
      addSubview($0)
    }

    selectionView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.height.equalToSuperview().multipliedBy(0.8)
    }

    dayLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
}
