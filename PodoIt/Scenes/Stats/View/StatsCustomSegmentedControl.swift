//
//  StatsCustomSegmentedControl.swift
//  PodoIt
//
//  Created by 김이든 on 8/23/25.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

// MARK: - SegmentChipView

private class SegmentChipView: UIControl {
  private let label = UILabel().then {
    $0.font = Typography.font(for: .labelLg(weight: .semibold)) // 폰트 설정
    $0.textAlignment = .center
  }

  init(text: String) {
    super.init(frame: .zero)
    label.text = text
    addSubview(label)
    label.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 23, bottom: 4, right: 23)) // Padding 설정
    }
    setSelected(false, animated: false)
    // UIControl 이벤트 기본 활성화
    isUserInteractionEnabled = true
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError()
  }

  // 선택 설정
  func setSelected(_ selected: Bool, animated: Bool) {
    let changes = {
      self.label.textColor = selected ? .gray900 : .gray500 // 색상 설정
      self.label.transform = selected ? .identity : CGAffineTransform(scaleX: 0.875, y: 0.875) // 텍스트 크기 수동 계산 labelMd/labelLg -> 14/16 = 0.875
    }
    if animated {
      UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: changes) // 애니메이션 설정
    } else {
      changes()
    }
  }
}

// MARK: - SegmentHighlightLayer

final class SegmentHighlightLayer: CALayer {
  override init() {
    super.init()
    setupLayer()
  }

  override init(layer: Any) {
    super.init(layer: layer)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError()
  }

  private func setupLayer() {
    backgroundColor = UIColor.appWhite.cgColor // Chip 색상
    shadowColor = UIColor.appBlack.cgColor // Shadow 색상
    shadowOffset = CGSize(width: 0, height: 2) // Shadow Offset X: 0, Y: 2
    shadowOpacity = 0.08 // Shadow opacity 8%
  }

  func updateFrame(_ frame: CGRect, animated: Bool) {
    let radius = frame.height / 2
    cornerRadius = radius

    let shadowPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: frame.size), cornerRadius: radius).cgPath
    self.shadowPath = shadowPath

    if animated {
      CATransaction.begin()
      CATransaction.setAnimationDuration(0.25)
      CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
      self.frame = frame
      CATransaction.commit()
    } else {
      self.frame = frame
    }
  }
}

// MARK: - CustomSegmentedControl

final class StatsCustomSegmentedControl: UIView {
  private let stackView = UIStackView()
  private var segments: [SegmentChipView] = []
  private let highlightLayer = SegmentHighlightLayer()

  private var didSetupInitialSelection = false

  private(set) var selectedIndex: Int = 0
  let tapIndexRelay = PublishRelay<Int>()

  private let disposeBag = DisposeBag()

  init(items: [String]) {
    super.init(frame: .zero)
    setupStackView()
    setupSegments(items)
    layer.insertSublayer(highlightLayer, at: 0)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = bounds.height / 2
    // highlight Layer 초기 1회 설정 체크
    guard !didSetupInitialSelection, !segments.isEmpty else { return }
    // stackView가 layout 계산 완료 후 실행
    stackView.layoutIfNeeded()
    setSelectedIndex(selectedIndex, animated: false)
    didSetupInitialSelection = true
  }

  // StackView 설정
  private func setupStackView() {
    backgroundColor = .gray100 // 백그라운드 색상
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fillEqually
    addSubview(stackView)
    stackView.snp.makeConstraints { $0.edges.equalToSuperview().inset(4) // Padding 설정
    }
  }

  // 탭 설정
  private func setupSegments(_ items: [String]) {
    for (i, text) in items.enumerated() { // (index, text)
      let segment = SegmentChipView(text: text) // 각 세그먼트 칩 생성
      segments.append(segment) // 배열에 저장
      stackView.addArrangedSubview(segment) // stackView에 추가
      // Rx로 터치 시 index 이벤트 전달
      segment.rx.controlEvent(.touchUpInside)
        .map { i }
        .subscribe(onNext: { [weak self] index in
          self?.setSelectedIndex(index, animated: true) // 선택 index 전달해서 선택 함수 실행
          self?.tapIndexRelay.accept(index) // 외부로 선택 index 전달
        })
        .disposed(by: disposeBag)
    }
  }

  // 선택 설정
  func setSelectedIndex(_ index: Int, animated: Bool) {
    guard index >= 0, index < segments.count else { return } // 유효한 index인지 체크
    // 이전 선택 해제
    segments[selectedIndex].setSelected(false, animated: animated)
    // 새 선택 적용
    segments[index].setSelected(true, animated: animated)
    // 현재 선택 index 갱신
    selectedIndex = index
    // highlightLayer 위치 업데이트
    updateHighlightLayerFrame(for: segments[index], animated: animated)
  }

  // 선택된 segment 위로 highlightLayer 이동
  private func updateHighlightLayerFrame(for segment: SegmentChipView, animated: Bool) {
    // segment 좌표를 self 좌표계로 변환
    guard let frame = segment.superview?.convert(segment.frame, to: self) else { return }
    // highlightLayer 위치 업데이트
    highlightLayer.updateFrame(frame, animated: animated)
  }
}
