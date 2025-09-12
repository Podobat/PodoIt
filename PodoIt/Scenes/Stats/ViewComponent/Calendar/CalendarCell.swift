//
//  CalendarCell.swift
//  PodoIt
//
//  Created by 김이든 on 8/28/25.
//

import SnapKit
import Then
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
    case .zero: return .appWhite
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
    $0.backgroundColor = .clear
    $0.layer.borderWidth = 1.5
    $0.layer.borderColor = UIColor.primary700.cgColor
    $0.isHidden = true
  }

  private let selectionShadowView = UIView().then {
    $0.backgroundColor = .clear
    $0.isHidden = true
  }

  private let heatView = UIView().then {
    $0.backgroundColor = .clear
  }

  private let todayMarkerView = UIView().then {
    $0.backgroundColor = .clear
    $0.isHidden = true
  }

  private let todayShapeLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.fillColor = UIColor.primary700.cgColor // 안쪽 색
    layer.strokeColor = UIColor.appWhite.cgColor // 테두리 색
    layer.lineWidth = 1.0 / UIScreen.main.scale // center stroke
    layer.contentsScale = UIScreen.main.scale
    return layer
  }()

  override var isSelected: Bool {
    didSet {
      selectionView.isHidden = !isSelected
      selectionShadowView.isHidden = !isSelected
      dayLabel.font = isSelected
        ? Typography.font(for: .labelMd(weight: .semibold))
        : Typography.font(for: .labelMd(weight: .regular))

      // 선택된 셀만 z-index 올리기
      layer.zPosition = isSelected ? 10 : 0
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
    [selectionShadowView, heatView, selectionView, todayMarkerView].forEach {
      $0.layer.cornerRadius = $0.bounds.width / 2
    }

    let selectionPath = UIBezierPath(ovalIn: selectionShadowView.bounds).cgPath
    selectionShadowView.layer.shadowPath = selectionPath
    selectionShadowView.layer.shadowColor = UIColor.primary600.withAlphaComponent(0.2).cgColor
    selectionShadowView.layer.shadowOpacity = 1
    selectionShadowView.layer.shadowRadius = 12

    todayMarkerView.snp.updateConstraints {
      let offset = ((dayLabel.frame.minY - selectionView.frame.minY) / 2)
      $0.top.equalTo(selectionView.snp.top).offset(offset)
    }

    // 오늘 마커 path 갱신
    CATransaction.begin()
    CATransaction.setDisableActions(true) // 애니메이션 방지
    todayShapeLayer.path = UIBezierPath(ovalIn: todayMarkerView.bounds).cgPath
    CATransaction.commit()
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    dayLabel.text = nil
    dayLabel.font = Typography.font(for: .labelMd(weight: .regular))
    heatView.backgroundColor = .clear
    selectionView.isHidden = true
    selectionView.layer.borderColor = UIColor.primary500.cgColor
    todayMarkerView.isHidden = true
    layer.zPosition = 0
  }

  func update(day: String, isToday: Bool) {
    dayLabel.text = day
    todayMarkerView.isHidden = !isToday
  }

  private func configure() {
    [selectionShadowView, heatView, selectionView, todayMarkerView, dayLabel].forEach {
      addSubview($0)
    }

    [selectionShadowView, heatView, selectionView].forEach {
      $0.snp.makeConstraints {
        $0.center.equalToSuperview()
        $0.width.height.equalToSuperview().multipliedBy(0.8)
      }
    }

    dayLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }

    todayMarkerView.snp.makeConstraints {
      $0.centerX.equalTo(dayLabel.snp.centerX)
      $0.width.height.equalToSuperview().multipliedBy(0.1)
      $0.top.equalTo(selectionView.snp.top).offset(6)
    }

    todayMarkerView.layer.addSublayer(todayShapeLayer)
  }

  // day: "1"…"31" (빈칸은 ""), isToday: 오늘, focusMinutes: 해당 날짜 총 집중 시간(분)
  func update(day: String, isToday: Bool, focusMinutes: Int = 0) {
    // 기본 텍스트/오늘 마커
    dayLabel.text = day
    todayMarkerView.isHidden = !isToday

    // 빈칸 셀은 색/보더 모두 제거
    guard !day.isEmpty else {
      dayLabel.textColor = .gray800
      heatView.backgroundColor = .clear
      selectionView.layer.borderColor = UIColor.clear.cgColor
      return
    }

    // FocusBucket(초 단위 기준)으로 등급 계산
    let bucket = FocusBucket.bucket(for: focusMinutes * 60)

    // 등급에 따른 스타일 적용
    dayLabel.textColor = bucket.dayTextColor
    heatView.backgroundColor = bucket.fillColor
    selectionView.layer.borderColor = bucket.selectedBorder.cgColor
  }
}
