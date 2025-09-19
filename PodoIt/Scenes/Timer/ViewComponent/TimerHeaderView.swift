//
//  TimerHeaderView.swift
//  PodoIt
//
//  Created by 노가현 on 8/23/25.
//

import SnapKit
import Then
import UIKit

final class TimerHeaderView: UIView {
  private enum Layout {
    static let horizontalPadding: CGFloat = 20
  }

  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR") // 한국어 로케일
    formatter.dateFormat = "M월 d일 E요일"

    return formatter
  }()

  private let dateLabel = UILabel.makeAttributed(
    text: "", style: .headingMd(weight: .bold), color: .appBlack, alignment: .left
  )

  private let dividerView = UIView().then {
    $0.backgroundColor = .gray100
  }

  private let descriptionLabel = UILabel.makeAttributed(
    text: "오늘의 집중 시간", style: .labelMd(weight: .semibold), color: .gray500, alignment: .left
  )

  private let timeLabel = UILabel.makeAttributed(
    text: "00:00:00", style: .displayMd(weight: .bold), color: .appBlack, alignment: .left
  )

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    setupConstraints()
    updateDate()
    setupObservers()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    for item in [dateLabel, dividerView, descriptionLabel, timeLabel] {
      addSubview(item)
    }
  }

  private func setupConstraints() {
    dateLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalToSuperview().offset(Layout.horizontalPadding)
    }

    dividerView.snp.makeConstraints {
      $0.top.equalTo(dateLabel.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(1)
    }

    descriptionLabel.snp.makeConstraints {
      $0.top.equalTo(dividerView.snp.bottom).offset(16)
      $0.leading.equalToSuperview().offset(Layout.horizontalPadding)
    }

    timeLabel.snp.makeConstraints {
      $0.top.equalTo(descriptionLabel.snp.bottom).offset(2)
      $0.leading.equalToSuperview().offset(Layout.horizontalPadding)
      $0.bottom.equalToSuperview() // 전체 높이 계산
    }
  }

  // MARK: - Date Handling

  private func updateDate() {
      let today = TimerHeaderView.dateFormatter.string(from: Date())
      let attributed = Typography.attributed(
          today,
          style: .headingMd(weight: .bold),
          color: .appBlack
      )

      DispatchQueue.main.async {
          self.dateLabel.attributedText = attributed
      }
  }

  private func setupObservers() {
    // 자정 지나서 날짜 바뀔 때
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleDayChanged),
      name: .NSCalendarDayChanged,
      object: nil
    )

    // 시스템 시간대/시간 큰 변경
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleSignificantTimeChange),
      name: UIApplication.significantTimeChangeNotification,
      object: nil
    )

    // 앱 포그라운드 복귀 시(백그라운드 동안 날짜가 바뀌었을 수 있음)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleWillEnterForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
  }

  @objc private func handleDayChanged() {
    updateDate()
  }

  @objc private func handleSignificantTimeChange() {
    updateDate()
  }

  @objc private func handleWillEnterForeground() {
    updateDate()
  }

  // MARK: - Public

  func updateTotalTime(_ text: String) {
    timeLabel.attributedText = Typography.attributed(
      text,
      style: .displayMd(weight: .bold),
      color: .appBlack
    )
  }
}
