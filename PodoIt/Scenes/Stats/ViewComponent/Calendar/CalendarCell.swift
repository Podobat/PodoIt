//
//  CalendarCell.swift
//  PodoIt
//
//  Created by 김이든 on 8/28/25.
//

import UIKit

enum FocusBucket: Int {
  case zero = 0 // 0분
  case under1h // ~1시간
  case h1to2 // 1~2시간
  case h2to3 // 2~3시간
  case over3h // 3시간+

  static func bucket(for seconds: Int) -> FocusBucket {
    switch seconds {
    case 0: return .zero
    case 1 ..< (60 * 60): return .under1h
    case (60 * 60) ..< (120 * 60): return .h1to2
    case (120 * 60) ..< (180 * 60): return .h2to3
    default: return .over3h
    }
  }

  var dayTextColor: UIColor {
    switch self {
    case .zero, .under1h: return .appBlack
    case .h1to2, .h2to3, .over3h: return .appWhite
    }
  }

  var fillColor: UIColor {
    switch self {
    case .zero: return .clear
    case .under1h: return .primary100
    case .h1to2: return .primary300
    case .h2to3: return .primary500
    case .over3h: return .primary700
    }
  }

  var selectedBorder: UIColor {
    switch self {
    case .zero: return .primary500
    case .under1h, .h1to2, .h2to3: return .primary700
    case .over3h: return .primary900
    }
  }
}

final class CalendarCell: UICollectionViewCell {
  static let identifier = "CalendarCell"

  // MARK: - Properties

  private lazy var dayLabel = UILabel().then {
    $0.textColor = .gray800
    $0.font = Typography.font(for: .labelMd(weight: .regular))
  }

  private let selectionView = UIView().then {
    $0.backgroundColor = .appWhite
    $0.layer.borderWidth = 1.5
    $0.layer.borderColor = UIColor.primary700.cgColor
    $0.isHidden = true
  }

  private let todayMarkerView = UIView().then {
    $0.backgroundColor = .primary700
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
    selectionView.layer.cornerRadius = selectionView.bounds.width / 2
    todayMarkerView.layer.cornerRadius = todayMarkerView.bounds.width / 2

    let path = UIBezierPath(ovalIn: selectionView.bounds).cgPath
    selectionView.layer.shadowPath = path
    selectionView.layer.shadowColor = UIColor.primary700.withAlphaComponent(0.2).cgColor
    selectionView.layer.shadowOpacity = 1
    selectionView.layer.shadowRadius = 12

    todayMarkerView.snp.updateConstraints {
      let offset = ((dayLabel.frame.minY - selectionView.frame.minY) / 2)
      $0.top.equalTo(selectionView.snp.top).offset(offset)
    }
  }

  override func prepareForReuse() {
    dayLabel.text = nil
    selectionView.isHidden = true
    todayMarkerView.isHidden = true
  }

  func update(day: String, isToday: Bool) {
    dayLabel.text = day
    todayMarkerView.isHidden = !isToday
  }

  private func configure() {
    [selectionView, todayMarkerView, dayLabel].forEach {
      addSubview($0)
    }

    selectionView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.height.equalToSuperview().multipliedBy(0.8)
    }

    dayLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }

    todayMarkerView.snp.makeConstraints {
      $0.centerX.equalTo(dayLabel.snp.centerX)
      $0.width.height.equalToSuperview().multipliedBy(0.1)
      $0.top.equalTo(selectionView.snp.top).offset(6)
    }
  }
}
