//
//  HeaderSectionView.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import AudioToolbox
import RxCocoa
import SnapKit
import Then
import UIKit

final class HeaderSectionView: UIView {
  // MARK: - Components

  private let hStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.spacing = 8
  }
  
  private let iconLabel = UILabel().then {
    $0.textAlignment = .center
    $0.backgroundColor = .gray50
    $0.clipsToBounds = true
  }
  
  private let titleLabel = UILabel().then {
    $0.lineBreakMode = .byTruncatingTail // 길면 ...처리
  }
  
  private let muteButton = UIButton().then {
    $0.setImage(UIImage(named: "alarm-clock"), for: .normal)
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
  
  // MARK: - layoutSubviews

  override func layoutSubviews() {
    super.layoutSubviews()
    iconLabel.layoutIfNeeded()
    iconLabel.layer.cornerRadius = iconLabel.frame.width / 2
  }
  
  // MARK: - configureUI

  private func configureUI() {
    addSubview(hStackView)
    [iconLabel, titleLabel].forEach { hStackView.addArrangedSubview($0) }
    addSubview(muteButton) // 터치영역 확장을 위해서 stackView에서 빼서 배치
  }
  
  // MARK: - configureLayout

  private func configureLayout() {
    hStackView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(16)
      $0.leading.equalToSuperview().inset(20)
      $0.trailing.equalTo(muteButton.snp.leading).inset(8)
    }
    
    iconLabel.snp.makeConstraints {
      $0.size.equalTo(24)
    }
    
    muteButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().offset(-10)
      $0.size.equalTo(44)
    }
  }
  
  // MARK: - 사운드 발생 및 이미지 교체
  func soundPlayAndUpdateImage(isMute: Bool, goalTime: String, restingTime: String) {
    muteButton.setImage(UIImage(named: isMute ? "alarm-clock-off" : "alarm-clock"), for: .normal)
    
    // 음소거면 종료
    guard !isMute else { return }
    
    // 목표시간이 "00:00"이 되면 사운드 1번 방출
    if goalTime == "00:00" {
      if playedGoalOnce == false {
        AudioServicesPlaySystemSound(1013)
        playedGoalOnce = true // 다시 00:00에서 벗어날 일이 없어서 true로 고정
      }
    }
    
    // 휴식시간이 "00:00"이 될 때 사운드 1번 방출
    if restingTime == "00:00" {
      if playedRestOnce == false {
        AudioServicesPlaySystemSound(1013)
        playedRestOnce = true // 00:00값이 유지될때 사운드 반복이 안되고 1회로 한정
      }
    } else {
      playedRestOnce = false // 다음 1 -> 0으로 오는 상태를 위해 00:00에서 벗어나면 false로 초기화
    }
  }
  
  // MARK: - configure(model: )

  func configure(model: TimerModel) {
    iconLabel.text = model.iconName
    titleLabel.attributedText = Typography.attributed(model.title, style: .bodyLg(weight: .semibold), color: .gray900)
  }
}

extension HeaderSectionView {
  var muteButtonTap: ControlEvent<Void> {
    return muteButton.rx.tap
  }
}
