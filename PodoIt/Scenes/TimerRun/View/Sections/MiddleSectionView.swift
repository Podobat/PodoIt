//
//  MiddleSectionView.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import SnapKit
import Then
import UIKit

final class MiddleSectionView: UIView {
  // MARK: Components

  private let switchContainerView = UIView() // progressView, restButtonsView를 감싼 스택뷰
  
  // progress
  private let progressView = UIView().then { // progressBar를 감싸는 View (isHidden 대상)
    $0.isHidden = true
  }

  private let progressContainer = UIView().then { // 진행률 바 배경 View
    $0.backgroundColor = .primary50
    $0.layer.cornerRadius = 16
  }

  private(set) var progressBar = UIProgressView(progressViewStyle: .default).then { // 진행률 바
    $0.progressTintColor = .primary400 // 채워진 부분 색상
    $0.trackTintColor = .clear // 아직 진행 안된 구간 색상
    $0.layer.cornerRadius = 12
    $0.clipsToBounds = true
  }
  
  // buttons
  private let restButtonsView = UIView().then { // restButtons를 감싸는 View (isHidden 대상)
    $0.isHidden = false
  }
  private let buttonsHStackView = UIStackView().then { // 3개 버튼의 H스택뷰
    $0.axis = .horizontal
    $0.alignment = .center
    $0.distribution = .equalSpacing
    $0.spacing = 8
  }
  
  private let plusOneMinuteButton = UIButton(type: .system).then { // +1분
    $0.setTitle("+1분", for: .normal)
  }
  private let plusFiveMinuteButton = UIButton(type: .system).then { // +5분
    $0.setTitle("+5분", for: .normal)
  }
  private let plusTenMinuteButton = UIButton(type: .system).then { // +10분
    $0.setTitle("+10분", for: .normal)
  }
  
  private lazy var restAddButtons: [UIButton] = [ // 버튼들 공통 로직 쓰기 편하도록 묶음
    plusOneMinuteButton,
    plusFiveMinuteButton,
    plusTenMinuteButton,
  ]
  
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
    addSubview(switchContainerView)
    [progressView, restButtonsView].forEach { switchContainerView.addSubview($0) }
    progressView.addSubview(progressContainer)
    progressContainer.addSubview(progressBar)
    restButtonsView.addSubview(buttonsHStackView)
    restAddButtons.forEach { buttonsHStackView.addArrangedSubview($0) }
    
    restAddButtons.forEach {
      $0.backgroundColor = .gray100
      $0.titleLabel?.font = Typography.font(for: .labelLg(weight: .semibold))
      $0.setTitleColor(.gray900, for: .normal)
      $0.layer.cornerRadius = 8
    }
  }

  // MARK: - configureLayout

  private func configureLayout() {
    switchContainerView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(20)
    }
    
    progressView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(16)
      $0.leading.trailing.equalToSuperview()
    }

    progressContainer.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
      $0.height.equalTo(32)
    }

    progressBar.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(4)
      $0.height.equalTo(24)
    }
    
    restButtonsView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(12)
      $0.leading.trailing.equalToSuperview()
    }
    
    buttonsHStackView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.bottom.equalToSuperview()
    }
    
    restAddButtons.forEach {
      $0.snp.makeConstraints {
        $0.width.equalTo(72)
        $0.height.equalTo(44) // TODO: 44 주고싶어요.. 디자이너님과 대화
      }
    }
  }

  // MARK: - Progress State/Color Update

  func updateProgressBar(progress: Float) {
    progressBar.setProgress(progress, animated: false)
    progressBar.progressTintColor = .primary600
  }
  
  // MARK: - isHidden Update
  func updateIsHiddenView(isRunning: Bool) {
    if isRunning { // 공부 중
      progressView.isHidden = false
      restButtonsView.isHidden = true
    } else { // 휴식 중
      progressView.isHidden = true
      restButtonsView.isHidden = false
    }
  }
}
