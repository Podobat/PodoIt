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
    [iconImageView, titleLabel, muteButton].forEach { hStackView.addArrangedSubview($0) }
  }

  private func configureLayout() {
    hStackView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(6)
      $0.leading.trailing.equalToSuperview()
    }

    iconImageView.snp.makeConstraints {
      $0.size.equalTo(24)
    }

    muteButton.snp.makeConstraints {
      $0.size.equalTo(44) // 실제 터치 영역 크기
    }

    muteButton.imageView?.snp.makeConstraints {
      $0.size.equalTo(24) // 보이는 크기
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    iconImageView.layoutIfNeeded()
    iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
  }
}
