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
  // progressBar / restTimerButton을 번갈아가며 isHidden처리 예정
  // progressBar은 top.bottom = 16, restTimerButton은 top.bottom = 12
  // 토글 될 때마다 위 아래 여백을 미리 만들어두고 토글되서 바꾸는 식으로 해야할 듯 싶음
  private let switchVStackView = UIStackView().then { // progressView, restButtonsView를 감싼 스택뷰
    $0.axis = .vertical
  }
  
  private let progressView = UIView() // progressBar를 감싸는 View (isHidden 대상)
  
  private let restButtonsView = UIView() // restButtons를 감싸는 View (isHidden 대상)

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
    addSubview(switchVStackView)
    [progressView, restButtonsView].forEach { switchVStackView.addArrangedSubview($0) }
    progressView.addSubview(progressContainer)
    progressContainer.addSubview(progressBar)
  }

  // MARK: - configureLayout

  private func configureLayout() {
    switchVStackView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.height.equalTo(64)
      $0.leading.trailing.equalToSuperview().inset(20)
    }
    
    progressView.snp.makeConstraints {
      $0.height.equalTo(32)
    }
    
    restButtonsView.snp.makeConstraints {
      $0.height.equalTo(40)
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
  }

  // MARK: - Progress State/Color Update

  func updateProgressBar(progress: Float) {
    progressBar.setProgress(progress, animated: false)
    progressBar.progressTintColor = .primary600
  }
}
