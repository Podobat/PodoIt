//
//  ButtonBarView.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import RxCocoa
import SnapKit
import Then
import UIKit

final class ButtonSectionView: UIView {
  // MARK: - Components
  
  private let hStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 8
  }
  
  private lazy var stopButton = UIButton(configuration: {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .gray100
    config.image = UIImage(named: "stop-fill")
    config.imagePadding = 8 // 8만큼의 spacing
    config.attributedTitle = AttributedString("종료하기", attributes: AttributeContainer([
      .font: Typography.font(for: .labelMd(weight: .medium)),
      .foregroundColor: UIColor.gray900
    ]))
    config.contentInsets = NSDirectionalEdgeInsets(
      top: 16,
      leading: 20,
      bottom: 16,
      trailing: 20
    )
    config.cornerStyle = .capsule
    return config
  }())
  
  private(set) lazy var startPauseButton = UIButton(configuration: {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .gray100
    config.image = UIImage(named: "pause")
    config.imagePadding = 8
    config.attributedTitle = AttributedString("휴식하기", attributes: AttributeContainer([
      .font: Typography.font(for: .labelMd(weight: .medium)),
      .foregroundColor: UIColor.gray900
    ]))
    config.contentInsets = NSDirectionalEdgeInsets(
      top: 16,
      leading: 20,
      bottom: 16,
      trailing: 20
    )
    config.cornerStyle = .capsule
    return config
  }())
  
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
    backgroundColor = .appWhite
    addSubview(hStackView)
    [stopButton, startPauseButton].forEach { hStackView.addArrangedSubview($0) }
  }
  
  // MARK: - configureLayout
  
  private func configureLayout() {
    hStackView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.bottom.equalToSuperview().inset(24)
    }
  }
  
  // MARK: 집중/휴식 상태에 따른 버튼 이미지, 색상 변경
  
  func updateStartPauseButtonImage(isStudying: Bool) {
    if isStudying { // 공부 중
      startPauseButton.configuration?.baseBackgroundColor = .gray100
      startPauseButton.configuration?.image = UIImage(named: "pause")
      startPauseButton.configuration?.attributedTitle = AttributedString("휴식하기", attributes: AttributeContainer([
        .font: Typography.font(for: .labelMd(weight: .medium)),
        .foregroundColor: UIColor.gray900
      ]))
    } else { // 휴식 중
      startPauseButton.configuration?.baseBackgroundColor = .primary600
      startPauseButton.configuration?.image = UIImage(named: "play-white")
      startPauseButton.configuration?.attributedTitle = AttributedString("집중하기", attributes: AttributeContainer([
        .font: Typography.font(for: .labelMd(weight: .medium)),
        .foregroundColor: UIColor.appWhite
      ]))
    }
  }
}

extension ButtonSectionView {
  /// addTarget과 같은 역할을 Rx로 감싼 코드.
  /// - return의 startPauseButton.rx.tap으로, 그 버튼의 tap 이벤트 스트림을 반환함
  /// - VC에서 반환값을 구독해서 연결되는 형태
  var startPauseTap: ControlEvent<Void> {
    return startPauseButton.rx.tap
  }
  
  var stopButtonTap: ControlEvent<Void> {
    return stopButton.rx.tap
  }
}
