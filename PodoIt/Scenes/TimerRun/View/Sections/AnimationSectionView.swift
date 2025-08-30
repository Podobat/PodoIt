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
  private let dummyImage = UIImageView().then {
    $0.image = UIImage(named: "dummy-animation-preview")
    // VC에 있는 rootStack의 stackView 내부에서 우선순위는 적용되지 않음.
    // 다만, 그 내부에 있는 컴포넌트 우선순위는 적용되기 때문에 이미지 뷰의 우선순위를 낮춰서 rootStack 내에서 남는 공간을 이 뷰가 차지하도록 함
    $0.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
    $0.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(dummyImage)

    dummyImage.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview().inset(20)
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureUI() {}

  private func configureLayout() {}
}
