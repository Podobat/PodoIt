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
  // MARK: - Metrics

  private enum Metrics {
    static let verticalPadding: CGFloat = 4
    static let horizontalPadding: CGFloat = 23
  }

  // MARK: - Properties
  
  private let label = UILabel.makeAttributed(
    text: "", style: .labelLg(weight: .semibold), color: .appBlack, alignment: .center
  )

  // MARK: - Init

  init(text: String) {
    super.init(frame: .zero)
    label.text = text
    addSubview(label)
    label.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(
        UIEdgeInsets(
          top: Metrics.verticalPadding,
          left: Metrics.horizontalPadding,
          bottom: Metrics.verticalPadding,
          right: Metrics.horizontalPadding
        )
      ) // Padding 설정
    }
    chipSelected(false, animated: false)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError()
  }

  // MARK: - Methods

  // 선택 설정
  func chipSelected(_ selected: Bool, animated: Bool) {
    let changes = {
      if let text = self.label.attributedText?.string {
        self.label.attributedText = Typography.attributed(
          text,
          style: .labelLg(weight: .semibold),
          color: selected ? .gray900 : .gray500
        )
      } // 색상 설정
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
  // MARK: - Init

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

  // MARK: - Methods

  private func setupLayer() {
    backgroundColor = UIColor.appWhite.cgColor // Chip 색상
    shadowColor = UIColor.appBlack.cgColor // Shadow 색상
    shadowOffset = CGSize(width: 0, height: 2) // Shadow 위치 X: 0, Y: 2
    shadowOpacity = 0.08 // Shadow 불투명도 8%
    shadowRadius = 16 // Shadow 블러
  }

  func updateFrame(_ frame: CGRect, animated: Bool) {
    let radius = frame.height / 2
    cornerRadius = radius
    shadowPath = UIBezierPath(roundedRect: .init(origin: .zero, size: frame.size),
                              cornerRadius: radius).cgPath

    if animated {
      CATransaction.begin()
      CATransaction.setAnimationDuration(0.25)
      CATransaction.setAnimationTimingFunction(.init(name: .easeInEaseOut))
      self.frame = frame
      CATransaction.commit()
    } else {
      CATransaction.begin()
      CATransaction.setDisableActions(true) // 불필요한 암묵적 애니메이션 방지
      self.frame = frame
      CATransaction.commit()
    }
  }
}

// MARK: - CustomSegmentedControl

final class StatsCustomSegmentedControl: UIView {
  // MARK: - Properties

  private let stackView = UIStackView()
  private var segments: [SegmentChipView] = []
  private let highlightLayer = SegmentHighlightLayer()

  private var didLayoutOnce = false

  private(set) var selectedIndex: Int = 0
  private let selectedIndexRelay = BehaviorRelay<Int>(value: 0)
  var selectedIndexChanged: Observable<Int> { selectedIndexRelay.distinctUntilChanged() }

  private let disposeBag = DisposeBag()

  // MARK: - Init

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

  // MARK: - Methods

  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = bounds.height / 2
    guard !didLayoutOnce else { return }
    // stackView가 layout 계산 완료 후 실행
    didLayoutOnce = true
    stackView.layoutIfNeeded()
    setSelectedIndex(selectedIndex, animated: false)
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
        .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
        .subscribe(onNext: { [weak self] _ in
          self?.setSelectedIndex(i, animated: true) // 선택 index 전달해서 선택 함수 실행
        })
        .disposed(by: disposeBag)
    }
  }

  // 선택된 segment 위로 highlightLayer 이동
  private func moveHighlight(for segment: SegmentChipView, animated: Bool) {
    // segment 좌표를 self 좌표계로 변환
    guard let frame = segment.superview?.convert(segment.frame, to: self) else { return }
    // highlightLayer 위치 업데이트
    highlightLayer.updateFrame(frame, animated: animated)
  }

  // 이미 선택되어 있는 탭 불가
  private func updateInteractionStates() {
    for (i, chip) in segments.enumerated() {
      chip.isUserInteractionEnabled = (i != selectedIndex)
    }
  }

  // 선택 설정
  func setSelectedIndex(_ index: Int, animated: Bool) {
    guard index >= 0, index < segments.count else { return } // 유효한 index인지 체크
    // 이전 선택 해제
    segments[selectedIndex].chipSelected(false, animated: animated)
    // 새 선택 적용
    segments[index].chipSelected(true, animated: animated)
    // 현재 선택 index 갱신
    selectedIndex = index
    // highlightLayer 위치 업데이트
    moveHighlight(for: segments[index], animated: animated)
    updateInteractionStates()
    selectedIndexRelay.accept(index)
  }
}
