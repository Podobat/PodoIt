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
  private let hStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 16
  }
  
  private lazy var stopButton = UIButton(type: .system).then {
    $0.backgroundColor = .gray100
    $0.tintColor = .gray900
    $0.setImage(UIImage(named: "stop-fill"), for: .normal)
    $0.layer.cornerRadius = 32 // 버튼이 고정값이라 값 명시
    $0.clipsToBounds = true
  }
  
  private(set) lazy var startPauseButton = UIButton(type: .system).then {
    $0.backgroundColor = .primary600
    $0.tintColor = .appWhite
    $0.setImage(UIImage(named: "play-white"), for: .normal)
    $0.layer.cornerRadius = 32
    $0.clipsToBounds = true
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
  
  // MARK: 집중/휴식 상태에 따른 버튼 이미지, 색상 변경
  func updateStartPauseButtonImage(isRunning: Bool) {
    if isRunning { // 공부 중
      startPauseButton.backgroundColor = .gray100
      startPauseButton.tintColor = .gray900
      startPauseButton.setImage(UIImage(named: "pause"), for: .normal)
    } else { // 휴식 중
      startPauseButton.backgroundColor = .primary600
      startPauseButton.tintColor = .appWhite
      startPauseButton.setImage(UIImage(named: "play-white"), for: .normal)
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
