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
  }
  
  private lazy var stopButton = UIButton(type: .system).then {
    $0.setImage(UIImage(named: "stop-fill"), for: .normal)
    $0.backgroundColor = .gray100
    $0.tintColor = .appBlack
    $0.layer.cornerRadius = 32 // 버튼이 고정값이라 값 명시
    $0.clipsToBounds = true
    $0.addTarget(self, action: #selector(didTapStopButton), for: .touchUpInside)
  }
  
  private lazy var startPauseButton = UIButton(type: .system).then {
    $0.setImage(UIImage(named: "play-white"), for: .normal)
    $0.tintColor = .appWhite
    $0.backgroundColor = .primary600
    $0.layer.cornerRadius = 32
    $0.clipsToBounds = true
    $0.addTarget(self, action: #selector(didTapStartPauseButton), for: .touchUpInside)
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
      $0.top.bottom.equalToSuperview().inset(24)
    }
    
    for item in [stopButton, startPauseButton] {
      item.snp.makeConstraints { $0.size.equalTo(64) }
    }
  }
  
  @objc private func didTapStopButton() {
    print("눌림")
  }
  
  @objc private func didTapStartPauseButton() {
    print("눌림")
  }
}
