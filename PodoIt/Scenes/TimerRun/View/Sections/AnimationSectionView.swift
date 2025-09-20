//
//  AnimationSectionView.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import Lottie
import SnapKit
import Then
import UIKit

final class AnimationSectionView: UIView {
  // MARK: - Components

  // 집중 Lottie
  private var animationView = LottieAnimationView().then {
    $0.loopMode = .loop
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
    addSubview(animationView)
  }

  // MARK: - configureLayout

  private func configureLayout() {
    animationView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview().inset(40)
    }
  }

  func updateAnimationsIsHidden(isStudying: Bool) {
    let name = isStudying ? "focus" : "rest"
    animationView.animation = LottieAnimation.named(name)
    animationView.play()
  }
}
