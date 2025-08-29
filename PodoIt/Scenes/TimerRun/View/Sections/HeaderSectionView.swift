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

  private let iconImageView = UIImageView().then {
    $0.contentMode = .center
    $0.image = UIImage(systemName: "flame.fill") // 임시 이미지. 나중에 string 받아서 세팅 예정
    $0.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16) // 내부 심볼 크기를 16으로 줄임
    $0.backgroundColor = .gray50
    $0.clipsToBounds = true
  }

  private let titleLabel = UILabel
    .makeAttributed(
      text: "자격증공부할수있고길어지면잘림 자격증공부할수있고길어지면잘림 자격증공부할수있고길어지면잘림",
      style: .bodyLg(weight: .semibold), // headingSm이 bodyLg랑 같은 사이즈에 .semibold라 이걸로 채택
      color: .gray900
    ).then {
      $0.lineBreakMode = .byTruncatingTail // 길면 ...처리
    }

  private let muteButton = UIButton().then {
    $0.setImage(UIImage(named: "alarm-clock"), for: .normal)
    $0.backgroundColor = .red
    $0.addTarget(self, action: #selector(tapp), for: .touchUpInside)
  }
  
  @objc func tapp() {
    print("눌림")
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
    addSubview(hStackView)
    [iconImageView, titleLabel].forEach { hStackView.addArrangedSubview($0) }
    addSubview(muteButton) // 터치영역 확장을 위해서 stackView에서 빼서 배치
  }

  private func configureLayout() {
    hStackView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(16)
      $0.leading.equalToSuperview().inset(20)
      $0.trailing.equalTo(muteButton.snp.leading).inset(8)
    }

    iconImageView.snp.makeConstraints {
      $0.size.equalTo(24)
    }

    muteButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().offset(-10)
      $0.size.equalTo(44)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    iconImageView.layoutIfNeeded()
    iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
  }
}
