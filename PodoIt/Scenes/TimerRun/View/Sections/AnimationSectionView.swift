//
//  AnimationSectionView.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import SnapKit
import Then
import UIKit

final class AnimationSectionView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .green
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureUI() {}

  private func configureLayout() {}
}
