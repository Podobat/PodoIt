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

  private(set) var sessionContainerView = UIView().then { // 아이콘 + 목표 시간/달성 Label
    $0.backgroundColor = .gray100
  }

  private var sessionIconImageView = UIImageView().then { // 아이콘
    $0.image = UIImage(named: "flag")
    $0.tintColor = .gray900
    $0.contentMode = .scaleAspectFit
  }

  private var sessionTimeLabel = UILabel().then { // 목표 시간/달성 or 휴식 상태 Label
    $0.font = Typography.font(for: .labelMd(weight: .medium)).monospacedDigits()
    $0.textColor = .gray900
  }
  
  private var activeTimeContainerView = UIView()

  private(set) var activeTimerLabel = UILabel().then { // 공부,휴식 진행 시간 Label
    $0.text = "0:00:00"
    $0.font = Typography.font(for: .displayLg(weight: .bold)).monospacedDigits()
    $0.textColor = .appBlack
    $0.textAlignment = .center
  }

  // MARK: - init
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    configureLayout()
  }

  // MARK: - layoutSubviews
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutIfNeeded()
    sessionContainerView.layer.cornerRadius = sessionContainerView.bounds.height / 2
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - configureUI
  private func configureUI() {
    backgroundColor = .appWhite
    addSubview(vStackView)
    [sessionContainerView, activeTimeContainerView].forEach { vStackView.addArrangedSubview($0) }
    activeTimeContainerView.addSubview(activeTimerLabel)
    [sessionIconImageView, sessionTimeLabel].forEach { sessionContainerView.addSubview($0) }
  }

  // MARK: - configureLayout
  private func configureLayout() {
    vStackView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(8)
      $0.leading.trailing.equalToSuperview().inset(20)
    }

    activeTimeContainerView.snp.makeConstraints {
      $0.height.equalTo(56)
      $0.centerX.equalToSuperview()
    }

    activeTimerLabel.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    sessionIconImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(8)
      $0.centerY.equalTo(sessionTimeLabel.snp.centerY) // 라벨과 같은 세로선
      $0.size.equalTo(16)
    }

    sessionTimeLabel.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(4)
      $0.leading.equalTo(sessionIconImageView.snp.trailing).offset(4)
      $0.trailing.equalToSuperview().inset(8)
    }
  }

  // MARK: - update Goal Time

  // TODO: VM에서 상태 판정해서 enum으로 묶어서 case로 돌려주도록 리팩토링
  /// 공부 중. 목표시간 달성 시 UI 업데이트
  func updateGoalTimeUI(goalTime: String, runningTime: String) {
    sessionTimeLabel.text = goalTime // 조건 없이 계속해서 줄어드는 타이머 String값 바인딩
    activeTimerLabel.font = Typography.font(for: .displayLg(weight: .bold)).monospacedDigits()
    activeTimerLabel.text = runningTime
    if goalTime == "00:00" { // 공부 목표 시간에 달성했을 경우, 화면 업데이트
      sessionContainerView.backgroundColor = .primary50
      sessionIconImageView.image = UIImage(named: "circle-check")
      sessionTimeLabel.text = "목표 달성 완료!"
      sessionTimeLabel.textColor = .primary700
    } else { // 목표시간 도달 전
      sessionContainerView.backgroundColor = .gray100
      sessionIconImageView.image = UIImage(named: "flag")
      sessionIconImageView.tintColor = .gray900
      sessionTimeLabel.textColor = .gray900
    }
  }

  /// 휴식 중. 휴식시간이 끝나는것을 기준으로 UI 업데이트
  func updateRestTimeUI(restTime: String, totalRestTime: String) {
    sessionIconImageView.image = UIImage(named: "cup")
    if restTime == "00:00" { // 휴식 시간이 끝났을 경우
      activeTimerLabel.text = "휴식 시간이 끝났어요"
      activeTimerLabel.font = Typography.font(for: .displayMd(weight: .semibold)).withSize(32).monospacedDigits()
      sessionContainerView.backgroundColor = .error.withAlphaComponent(0.08) // 투명도 8%
      sessionIconImageView.tintColor = .error
      sessionTimeLabel.textColor = .error
    } else { // 휴식 시간이 남아있을 경우
      activeTimerLabel.text = restTime
      activeTimerLabel.font = Typography.font(for: .displayLg(weight: .bold)).monospacedDigits()
      sessionTimeLabel.text = totalRestTime
      sessionContainerView.backgroundColor = .green100
      sessionIconImageView.tintColor = .green600
      sessionTimeLabel.textColor = .green600
    }
  }
}
