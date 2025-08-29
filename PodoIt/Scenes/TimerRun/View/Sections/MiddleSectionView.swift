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
  private let switchContainerView = UIView()

  private let progressContainer = UIView().then { // 진행률 바 배경 View
    $0.backgroundColor = .primary50
    $0.layer.cornerRadius = 16
  }

  private let progressBar = UIProgressView(progressViewStyle: .default).then { // 진행률 바
    $0.progressTintColor = .primary400 // 채워진 부분 색상
    $0.trackTintColor = .clear // 아직 진행 안된 구간 색상
    $0.layer.cornerRadius = 12
    $0.clipsToBounds = true
    $0.setProgress(0.2, animated: false) // 임시 값 (정적 UI)
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

  private func configureUI() {
    addSubview(switchContainerView)
    switchContainerView.addSubview(progressContainer)
    progressContainer.addSubview(progressBar)
  }

  private func configureLayout() {
    switchContainerView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(16)
      $0.leading.trailing.equalToSuperview().inset(20)
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
}
