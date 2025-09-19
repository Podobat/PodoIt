//
//  TimerCell.swift
//  PodoIt
//
//  Created by 노가현 on 8/25/25.
//

import SnapKit
import Then
import UIKit

final class TimerCell: UICollectionViewCell, UIGestureRecognizerDelegate {
  static let reuseIdentifier = "TimerCell"

  #if DEBUG
  private static let showSecondsInList = true
  #else
  private static let showSecondsInList = false
  #endif

  // MARK: - Metrics

  private enum Metrics {
    static let cornerRadius: CGFloat = 16
    static let emojiFrame: CGFloat = 28
    static let emojiFont: CGFloat = 18
    static let playOuterSize: CGFloat = 56
    static let playSize: CGFloat = 24
    static let stackHPadding: CGFloat = 16
    static let stackVPadding: CGFloat = 20
    static let interItemSpacing: CGFloat = 10
    static let titleMetaSpacing: CGFloat = 8
    static let metaAfterFocusVal: CGFloat = 18
    static let metaAfterToday: CGFloat = 10
    static let buttonTrailingSpacing: CGFloat = 8
  }

  // MARK: - UI

  private let emojiFrameView = UIView().then {
    $0.backgroundColor = .gray100
    $0.layer.cornerRadius = Metrics.emojiFrame / 2
    $0.clipsToBounds = true
  }

  private let iconLabel = UILabel().then {
    $0.font = .systemFont(ofSize: Metrics.emojiFont) // 20x20
    $0.textAlignment = .center
  }

  private let titleLabel = UILabel().then {
    $0.font = Typography.font(for: .headingMd)
    $0.textColor = .appBlack
    $0.numberOfLines = 1
    $0.lineBreakMode = .byTruncatingTail
    // 텍스트 스택이 버튼과 충돌 안 나도록 우선순위 명시
    $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
  }

  private let focusPrefixLabel = UILabel().then {
    $0.font = Typography.font(for: .bodyMd(weight: .medium))
    $0.textColor = .gray400
    $0.text = "집중"
  }

  private let focusValueLabel = UILabel().then {
    $0.font = Typography.font(for: .bodyMd(weight: .semibold))
    $0.textColor = .gray700
  }

  private let todayLabel = UILabel().then {
    $0.font = Typography.font(for: .bodyMd(weight: .medium))
    $0.textColor = .gray400
    $0.text = "오늘"
  }

  private let todayValueLabel = UILabel().then {
    let base = Typography.font(for: .bodyMd(weight: .semibold))
    let mono = UIFont.monospacedDigitSystemFont(ofSize: base.pointSize, weight: .semibold)
    $0.font = mono
    $0.textColor = .gray700
    $0.adjustsFontForContentSizeCategory = true // Dynamic Type 대응
  }

  private lazy var metaStack = UIStackView().then {
    $0.addArrangedSubviews([focusPrefixLabel, focusValueLabel, todayLabel, todayValueLabel])
    $0.axis = .horizontal
    $0.alignment = .lastBaseline
    $0.spacing = 8
    $0.setCustomSpacing(Metrics.metaAfterFocusVal, after: focusValueLabel)
    $0.setCustomSpacing(Metrics.metaAfterToday, after: todayLabel)
  }

  private lazy var playButton = UIButton(type: .system).then {
    let image = UIImage(named: "play-fill")?.withRenderingMode(.alwaysOriginal)
    $0.setImage(image, for: .normal)
    $0.backgroundColor = .gray100
    $0.layer.cornerRadius = Metrics.cornerRadius
    $0.layer.cornerCurve = .continuous
    $0.clipsToBounds = true

    // 아이콘만 24로 보여주고 버튼은 56x56
    // 시스템이 중앙에 배치해줌
    $0.contentHorizontalAlignment = .center
    $0.contentVerticalAlignment = .center

    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    $0.setContentHuggingPriority(.required, for: .horizontal)

    $0.addTarget(self, action: #selector(handlePlayTapped), for: .touchUpInside)
  }

  // MARK: - Swipe Action UI

  private let mainContentView = UIView().then {
    $0.backgroundColor = .appWhite
    $0.layer.cornerRadius = Metrics.cornerRadius
    $0.layer.cornerCurve = .continuous
    $0.clipsToBounds = true
  }

  private let swipeActionView = UIView().then {
    $0.backgroundColor = .error
    $0.layer.cornerRadius = Metrics.cornerRadius
    $0.layer.cornerCurve = .continuous
    $0.clipsToBounds = true
  }

  private let deleteIconView = UIImageView().then {
    let image = UIImage(named: "trash")?.withRenderingMode(.alwaysTemplate)
    $0.image = image
    $0.tintColor = .appWhite
    $0.contentMode = .scaleAspectFit
    $0.isHidden = true
  }

  private let deleteButton = UIButton(type: .system).then {
    $0.backgroundColor = .clear
    $0.addTarget(self, action: #selector(handleDeleteTapped), for: .touchUpInside)
  }

  var onPlayTapped: (() -> Void)?
  var onDeleteTapped: (() -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
    setupUI()
    setupShadow()
    setupPanGesture()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func prepareForReuse() {
    super.prepareForReuse()
    resetSwipeAction()
    resetLabels()
  }

  private func setupUI() {
    setupContentView()
    addSubviews()
    setupConstraints()
  }

  private func setupContentView() {
    contentView.backgroundColor = .clear
    contentView.layer.cornerRadius = Metrics.cornerRadius
    contentView.layer.cornerCurve = .continuous
    contentView.clipsToBounds = true

    selectedBackgroundView = UIView().then {
      $0.backgroundColor = UIColor.gray100.withAlphaComponent(0.5)
    }
  }

  private func addSubviews() {
    contentView.addSubviews([swipeActionView, mainContentView])
    mainContentView.addSubviews([emojiFrameView, titleLabel, metaStack, playButton])
    emojiFrameView.addSubview(iconLabel)
    swipeActionView.addSubviews([deleteIconView, deleteButton])
  }

  private func setupConstraints() {
    // 스와이프 액션 뷰 - 전체 영역
    swipeActionView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    // 메인 액션 뷰 - 스와이프
    mainContentView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    emojiFrameView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(Metrics.stackHPadding)
      $0.top.equalToSuperview().inset(Metrics.stackVPadding)
      $0.size.equalTo(Metrics.emojiFrame)
    }

    iconLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }

    titleLabel.snp.makeConstraints {
      $0.leading.equalTo(emojiFrameView.snp.trailing).offset(Metrics.interItemSpacing)
      $0.centerY.equalTo(emojiFrameView)
      $0.trailing.lessThanOrEqualTo(playButton.snp.leading).offset(-Metrics.buttonTrailingSpacing)
    }

    metaStack.snp.makeConstraints {
      $0.leading.equalTo(emojiFrameView)
      $0.top.equalTo(emojiFrameView.snp.bottom).offset(Metrics.titleMetaSpacing)
      $0.trailing.lessThanOrEqualTo(playButton.snp.leading).offset(-Metrics.buttonTrailingSpacing)
      $0.bottom.lessThanOrEqualTo(mainContentView).inset(Metrics.stackVPadding)
    }

    playButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(16)
      $0.centerY.equalToSuperview()
      $0.size.equalTo(Metrics.playOuterSize)
    }

    // 빨간색 프레임 영역의 가운데 정렬

    deleteIconView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.centerX.equalTo(swipeActionView.snp.trailing).offset(-40)
      $0.size.equalTo(32)
    }

    deleteButton.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.trailing.equalToSuperview()
      $0.width.equalTo(80)
    }
  }

  private func setupShadow() {
    layer.masksToBounds = false
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.04
    layer.shadowRadius = 24
    layer.shadowOffset = CGSize(width: 0, height: 2)

    // 고정형 카드면 켜기
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale

    // 초기 path
    layer.shadowPath = UIBezierPath(
      roundedRect: contentView.bounds,
      cornerRadius: Metrics.cornerRadius
    ).cgPath
  }

  private func resetLabels() {
    [iconLabel, titleLabel, focusValueLabel, todayValueLabel].forEach { $0.text = nil }
  }

  @objc private func handlePlayTapped() {
    onPlayTapped?()
  }

  // MARK: - Swipe Action
  
  private var panGesture: UIPanGestureRecognizer!
  private var originalTransform: CGAffineTransform = .identity
  private var isSwipeActionVisible = false
  
  private func setupPanGesture() {
    panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    panGesture.delegate = self
    addGestureRecognizer(panGesture)
  }
  
  @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: self)
    let velocity = gesture.velocity(in: self)
    
    switch gesture.state {
    case .began:
      originalTransform = mainContentView.transform
      
    case .changed:
      // 왼쪽으로만 스와이프
      let maxTranslation: CGFloat = -80
      let clampedTranslation = max(translation.x, maxTranslation)
      mainContentView.transform = CGAffineTransform(translationX: clampedTranslation, y: 0)
      
      // 스와이프 액션 표시
      // 삭제 아이콘
      let shouldShowAction = translation.x < -30
      if shouldShowAction != isSwipeActionVisible {
        isSwipeActionVisible = shouldShowAction
        deleteIconView.isHidden = !shouldShowAction
      }
      
    case .ended, .cancelled:
      // 스와이프 거리, 속도에 따라 액션 결정
      if translation.x < -50 || velocity.x < -500 {
        // 삭제 액션
        showSwipeAction()
      } else {
        // 원래 위치로
        resetSwipeAction()
      }
      
    default:
      break
    }
  }
  
  private func showSwipeAction() {
    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
      self.mainContentView.transform = CGAffineTransform(translationX: -80, y: 0)
    }
  }
  
  private func resetSwipeAction() {
    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
      self.mainContentView.transform = .identity
    }
    deleteIconView.isHidden = true
    isSwipeActionVisible = false
  }

  @objc private func handleDeleteTapped() {
    onDeleteTapped?()
  }

  // MARK: - Public Methods

  func configure(with timer: TimerModel, today: String = "00:00:00") {
    setupAccessibility(timer: timer, today: today)
    updateContent(timer: timer, today: today)
  }

//  private func setupAccessibility(timer: TimerModel, today: String) {
//    isAccessibilityElement = true
//    accessibilityLabel = "\(timer.title), 집중 목표 \(timer.goalTime)분, 오늘 \(today)"
//  }

  private func setupAccessibility(timer: TimerModel, today: String) {
    isAccessibilityElement = true
    if Self.showSecondsInList {
      let secs = timer.goalTime * 60
      accessibilityLabel = "\(timer.title), 집중 목표 \(secs)초, 오늘 \(today)"
    } else {
      accessibilityLabel = "\(timer.title), 집중 목표 \(timer.goalTime)분, 오늘 \(today)"
    }
  }

  private func updateContent(timer: TimerModel, today: String) {
    iconLabel.text = timer.iconName
    titleLabel.text = timer.title

    #if DEBUG
    if Self.showSecondsInList, let secs = DebugGoalSecondsStore.get(for: timer.timerID) {
      focusValueLabel.text = "\(secs)초"
    } else {
      focusValueLabel.text = "\(timer.goalTime)분"
    }
    #else
    focusValueLabel.text = "\(timer.goalTime)분"
    #endif

    todayValueLabel.text = today
  }

//    if Self.showSecondsInList {
//      let secs = timer.goalTime * 60
//      focusValueLabel.text = "\(secs)초"
//    } else {
//      focusValueLabel.text = "\(timer.goalTime)분"
//    }
//
//    todayValueLabel.text = today
//  }

//  private func updateContent(timer: TimerModel, today: String) {
//    iconLabel.text = timer.iconName
//    titleLabel.text = timer.title
//    focusValueLabel.text = "\(timer.goalTime)분"
//    todayValueLabel.text = today
//  }
}

// MARK: - UIView Extension

extension UIView {
  func addSubviews(_ views: [UIView]) {
    views.forEach(addSubview)
  }
}

// MARK: - UIStackView Extension

extension UIStackView {
  func addArrangedSubviews(_ views: [UIView]) {
    views.forEach(addArrangedSubview)
  }
}

#if DEBUG
enum DebugGoalSecondsStore {
  private static let keyPrefix = "debug.goalSeconds."

  static func set(_ secs: Int, for id: String) {
    UserDefaults.standard.set(secs, forKey: keyPrefix + id)
  }

  static func get(for id: String) -> Int? {
    UserDefaults.standard.object(forKey: keyPrefix + id) as? Int
  }

  static func remove(for id: String) {
    UserDefaults.standard.removeObject(forKey: keyPrefix + id)
  }

  static func set(_ secs: Int, for id: UUID) {
    set(secs, for: id.uuidString)
  }

  static func get(for id: UUID) -> Int? {
    get(for: id.uuidString)
  }

  static func remove(for id: UUID) {
    remove(for: id.uuidString)
  }
}
#endif
