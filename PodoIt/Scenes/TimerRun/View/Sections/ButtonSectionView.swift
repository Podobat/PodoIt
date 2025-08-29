//
//  ButtonBarView.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import SnapKit
import Then
import UIKit

final class ButtonSectionView: UIView {
  private let hStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 16
    $0.isLayoutMarginsRelativeArrangement = true
    $0.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 24, leading: 0, bottom: 24, trailing: 0)
  }
  
  // TODO: 버튼들 가운데만 이미지로 가져와서 배경 만들어서 넣고, 눌릴때 0.95정도로 작아지는 느낌 & 알파값 줄여서 눌림효과도 추가
  let stopButton = UIButton().then {
    $0.setImage(UIImage(named: "stop_circle"), for: .normal)
  }
  
  let startPauseButton = UIButton().then {
    $0.setImage(UIImage(named: "start_circle"), for: .normal)
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
    backgroundColor = .appWhite
    addSubview(hStackView)
    [stopButton, startPauseButton].forEach { hStackView.addArrangedSubview($0) }
  }
  
  private func configureLayout() {
    hStackView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.bottom.equalToSuperview()
    }
    
    for item in [stopButton, startPauseButton] {
      item.snp.makeConstraints { $0.size.equalTo(64) }
    }
  }
}
