//
//  AnimationSectionView.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import DotLottie
import SnapKit
import Then
import UIKit

final class AnimationSectionView: UIView {
  // MARK: - Components

  // 집중 Lottie
  private var focusAnimation = DotLottieAnimation(fileName: "focus", config: AnimationConfig(autoplay: true, loop: true))
  private lazy var focusAnimationView: UIView = focusAnimation.view().then {
    $0.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
    $0.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
  }

  // 휴식 Lottie
  private var restAnimation = DotLottieAnimation(fileName: "Marketing", config: AnimationConfig(autoplay: true, loop: true))
  private lazy var restAnimationView: UIView = restAnimation.view().then {
    $0.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
    $0.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
  }

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
    [focusAnimationView, restAnimationView].forEach { addSubview($0) }
  }

  // MARK: - configureLayout

  private func configureLayout() {
    focusAnimationView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview().inset(40)
    }

    restAnimationView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview().inset(40)
    }
  }

  func updateAnimationsIsHidden(isStudying: Bool) {
    focusAnimationView.isHidden = isStudying ? false : true
    restAnimationView.isHidden = isStudying ? true : false
  }
}
