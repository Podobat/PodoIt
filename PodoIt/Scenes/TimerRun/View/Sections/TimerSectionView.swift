//
//  TimerSectionView.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import SnapKit
import Then
import UIKit

final class TimerSectionView: UIView {
  // MARK: - Components

  private let vStackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .center
    $0.spacing = 8
  }

  private(set) var statusContainerView = CapsuleBackgroundView().then { // 아이콘 + 목표 시간/달성 Label
    $0.backgroundColor = .gray100
    $0.clipsToBounds = true
  }

  private var statusIconImageView = UIImageView().then { // 아이콘
    $0.image = UIImage(named: "flag")
    $0.tintColor = .gray900
    $0.contentMode = .scaleAspectFit
  }

  private var statusTimeLabel = UILabel().then { // 목표 시간/달성 or 휴식 상태 Label
    $0.font = Typography.font(for: .labelMd(weight: .medium)).monospacedDigits()
    $0.textColor = .gray900
  }

  private var timerContainerView = UIView()

  private(set) var TimerLabel = UILabel().then { // 공부,휴식 진행 시간 Label
    $0.text = "0:00:00"
    $0.font = Typography.font(for: .displayLg(weight: .bold)).monospacedDigits()
    $0.textColor = .appBlack
    $0.textAlignment = .center
  }

  // 00:00에서 중복 사운드 반복이 안되게 하는 플래그 값
  private var playedGoalOnce = false
  private var playedRestOnce = false

  // MARK: - init

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    configureLayout()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - configureUI

  private func configureUI() {
    backgroundColor = .appWhite
    addSubview(vStackView)
    [statusContainerView, timerContainerView].forEach { vStackView.addArrangedSubview($0) }
    timerContainerView.addSubview(TimerLabel)
    [statusIconImageView, statusTimeLabel].forEach { statusContainerView.addSubview($0) }
  }

  // MARK: - configureLayout

  private func configureLayout() {
    vStackView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(8)
      $0.leading.trailing.equalToSuperview().inset(20)
    }

    timerContainerView.snp.makeConstraints {
      $0.height.equalTo(56)
      $0.centerX.equalToSuperview()
    }

    TimerLabel.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    statusIconImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(8)
      $0.centerY.equalTo(statusTimeLabel.snp.centerY) // 라벨과 같은 세로선
      $0.size.equalTo(16)
    }

    statusTimeLabel.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(4)
      $0.leading.equalTo(statusIconImageView.snp.trailing).offset(4)
      $0.trailing.equalToSuperview().inset(8)
    }
  }

  // MARK: - update Goal Time

  /// 공부 중. 목표시간 달성 시 UI 업데이트
  func updateGoalTimeUI(goalTime: String, studyingTime: String) {
    statusTimeLabel.text = goalTime // 조건 없이 계속해서 줄어드는 타이머 String값 바인딩
    TimerLabel.font = Typography.font(for: .displayLg(weight: .bold)).monospacedDigits()
    TimerLabel.text = studyingTime
    if goalTime == "00:00" { // 공부 목표 시간에 달성했을 경우, 화면 업데이트
      statusContainerView.backgroundColor = .primary50
      statusIconImageView.image = UIImage(named: "circle-check")
      statusTimeLabel.text = "목표 달성 완료!"
      statusTimeLabel.textColor = .primary700
    } else { // 목표시간 도달 전
      statusContainerView.backgroundColor = .gray100
      statusIconImageView.image = UIImage(named: "flag")
      statusIconImageView.tintColor = .gray900
      statusTimeLabel.textColor = .gray900
    }
  }

  /// 휴식 중. 휴식시간이 끝나는것을 기준으로 UI 업데이트
  func updateRestTimeUI(totalRestTime: String, restingTime: String) {
    statusTimeLabel.text = totalRestTime
    statusIconImageView.image = UIImage(named: "cup")
    if restingTime == "00:00" { // 휴식 시간이 끝났을 경우
      TimerLabel.text = "휴식 시간이 끝났어요"
      TimerLabel.font = Typography.font(for: .displayMd(weight: .semibold)).withSize(32).monospacedDigits()
      statusContainerView.backgroundColor = .error.withAlphaComponent(0.08) // 투명도 8%
      statusIconImageView.tintColor = .error
      statusTimeLabel.textColor = .error
    } else { // 휴식 시간이 남아있을 경우
      TimerLabel.text = restingTime
      TimerLabel.font = Typography.font(for: .displayLg(weight: .bold)).monospacedDigits()
      statusContainerView.backgroundColor = .green100
      statusIconImageView.tintColor = .green600
      statusTimeLabel.textColor = .green600
    }
  }
}

/// 원형 캡슐모양 유지를 위해 CornerRadius를 높이 기반으로 계산
/// - 상위 뷰의 layoutSubviews 시점에 frame.height가 0으로 잡혀서 직각으로 되는 문제가 있었음
/// - 그래서 자체 layoutSubviews에서 frame값이 잡힌 후 cornerRadius를 설정하기 위함.
/// (iOS 18에서는 우연히 타이밍이 맞았지만, iOS 26에서는 깨져서 별도 서브클래스로 분리)
final class CapsuleBackgroundView: UIView {
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = bounds.height / 2
  }
}
