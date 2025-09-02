//
//  HeaderSectionView.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import SnapKit
import Then
import UIKit

final class HeaderSectionView: UIView {
  private let hStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.spacing = 8
  }
  
  private let iconLabel = UILabel().then {
    $0.textAlignment = .center
    $0.backgroundColor = .gray50
    $0.clipsToBounds = true
  }
  
  private let titleLabel = UILabel().then {
    $0.lineBreakMode = .byTruncatingTail // 길면 ...처리
  }
  
  private let muteButton = UIButton().then {
    $0.setImage(UIImage(named: "alarm-clock"), for: .normal)
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
  
  override func layoutSubviews() {
    super.layoutSubviews()
    iconLabel.layoutIfNeeded()
    iconLabel.layer.cornerRadius = iconLabel.frame.width / 2
  }
  
  private func configureUI() {
    addSubview(hStackView)
    [iconLabel, titleLabel].forEach { hStackView.addArrangedSubview($0) }
    addSubview(muteButton) // 터치영역 확장을 위해서 stackView에서 빼서 배치
  }
  
  private func configureLayout() {
    hStackView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(16)
      $0.leading.equalToSuperview().inset(20)
      $0.trailing.equalTo(muteButton.snp.leading).inset(8)
    }
    
    iconLabel.snp.makeConstraints {
      $0.size.equalTo(24)
    }
    
    muteButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().offset(-10)
      $0.size.equalTo(44)
    }
  }
  
  func configure(model: TimerModel) {
    iconLabel.text = model.iconName
    titleLabel.attributedText = Typography.attributed(model.title, style: .bodyLg(weight: .semibold), color: .gray900)
  }
}
