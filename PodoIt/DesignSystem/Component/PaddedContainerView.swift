//
//  PaddedContainerView.swift
//  PodoIt
//
//  Created by 노가현 on 8/22/25.
//

import SnapKit
import UIKit

// 좌우/상하 패딩이 설정된 공통 컨테이너 뷰
final class PaddedContainerView: UIView {
  // 내부 내용물을 담는 뷰
  let contentView = UIView()

  // 패딩 값
  private let horizontalPadding: CGFloat
  private let verticalPadding: CGFloat

  // 기본값 : 좌우 20, 상하 0
  init(horizontal: CGFloat = 20, vertical: CGFloat = 0) {
    self.horizontalPadding = horizontal
    self.verticalPadding = vertical
    super.init(frame: .zero)
    setupLayout()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupLayout() {
    addSubview(contentView)
    contentView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(horizontalPadding)
      $0.trailing.equalToSuperview().inset(horizontalPadding)
      $0.top.equalToSuperview().inset(verticalPadding)
      $0.bottom.equalToSuperview().inset(verticalPadding)
    }
  }
}
