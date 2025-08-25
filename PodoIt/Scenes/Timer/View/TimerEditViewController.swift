//
//  TimerEditViewController.swift
//  PodoIt
//
//  Created by 노가현 on 8/23/25.
//

import SnapKit
import Then
import UIKit

final class TimerEditViewController: UIViewController {
  // MARK: - Metrics

  private enum Metrics {
    static let cornerRadius: CGFloat = 8
    static let buttonCornerRadius: CGFloat = 12
    static let horizontalPadding: CGFloat = 20
    static let verticalSpacing: CGFloat = 12
    static let buttonHeight: CGFloat = 48
    static let emojiButtonSize: CGFloat = 56
    static let goalContainerHeight: CGFloat = 113
    static let textFieldHeight: CGFloat = 56
    static let textFieldLeftPadding: CGFloat = 16
    static let topOffset: CGFloat = 32
    static let bottomSafeAreaInset: CGFloat = 20
    static let dashedCircleSize: CGFloat = 40
    static let dashPattern: [NSNumber] = [4, 2]
  }

  // MARK: - UI Components

  // 뒤로 가기 버튼
  private lazy var backButton = UIButton().then {
    let image = UIImage(named: "arrow-left")?.withRenderingMode(.alwaysOriginal)
    $0.setImage(image, for: .normal)
    $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
  }

  // 화면 상단 제목
  private lazy var titleLabel = UILabel().then {
    $0.attributedText = Typography.attributed("타이머 추가", style: .headingMd, color: .appBlack)
    $0.textAlignment = .center
  }

  // 이모지 선택 버튼 (default : plus 버튼)
  private lazy var emojiButton = UIButton(type: .system).then {
    let image = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
    $0.setImage(image, for: .normal)
    $0.tintColor = Palette.Primary.p600
    $0.backgroundColor = .appWhite
    $0.layer.cornerRadius = Metrics.buttonCornerRadius
    $0.clipsToBounds = true
  }

  // 타이머 이름 입력 필드
  private let nameTextField = UITextField().then {
    $0.placeholder = "타이머 이름을 적어주세요"
    $0.font = Typography.font(for: .bodyMd(weight: .medium))
    $0.textColor = .appBlack
    $0.backgroundColor = .appWhite
    $0.layer.cornerRadius = Metrics.cornerRadius
    $0.setLeftPadding(Metrics.textFieldLeftPadding)
  }

  // 목표시간 영역 컨테이너
  private lazy var goalContainerView = UIView().then {
    $0.backgroundColor = .appWhite
    $0.layer.cornerRadius = Metrics.cornerRadius
    $0.clipsToBounds = true
  }

  // 목표 집중 시간 label
  private lazy var goalTitleLabel = UILabel().then {
    $0.attributedText = Typography.attributed(
      "목표 집중 시간",
      style: .labelLg(weight: .semibold),
      color: Palette.Gray.g500
    )
  }

  // 숫자/분 들어가는 회색 영역
  private let goalValueArea = UIView().then {
    $0.backgroundColor = .gray50
    $0.layer.cornerRadius = Metrics.cornerRadius
    $0.clipsToBounds = true
  }

  // 목표시간 표시 스택 (숫자 + 단위)
  private lazy var goalValueStack = UIStackView().then {
    $0.addArrangedSubviews([goalValueNumberLabel, goalValueUnitLabel])
    $0.axis = .horizontal
    $0.alignment = .center
    $0.distribution = .fill
    $0.spacing = 6
  }

  // 목표시간 숫자 (default: 50)
  private let goalValueNumberLabel = UILabel().then {
    $0.attributedText = Typography.attributed(
      "50",
      style: .displayMd(weight: .bold),
      color: .appBlack
    )
  }

  // 목표시간 단위 (분으로 고정)
  private let goalValueUnitLabel = UILabel().then {
    $0.attributedText = Typography.attributed(
      "분",
      style: .headingLg,
      color: Palette.Gray.g500
    )
  }

  // 저장하기 버튼
  private lazy var saveButton = UIButton(type: .system).then {
    $0.backgroundColor = Palette.Primary.p600
    $0.layer.cornerRadius = Metrics.buttonCornerRadius
    $0.clipsToBounds = true
    $0.setAttributedTitle(
      Typography.attributed("저장하기", style: .labelLg(weight: .semibold), color: .appWhite),
      for: .normal
    )
    $0.isEnabled = true
    // 저장 액션 추가 예정
    // $0.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViewController()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // 레이아웃이 완료된 후 점선 원 추가
    if emojiButton.layer.sublayers?.contains(where: { $0 is CAShapeLayer }) == false {
      addDashedCircleToEmojiButton()
    }
  }

  // MARK: - Private Methods

  private func setupViewController() {
    view.backgroundColor = .gray100
    addSubviews()
    setupConstraints()
  }

  private func addSubviews() {
    let mainViews = [backButton, titleLabel, emojiButton, nameTextField, goalContainerView, saveButton]
    view.addSubviews(mainViews)

    let goalContainerSubviews = [goalTitleLabel, goalValueArea]
    goalContainerView.addSubviews(goalContainerSubviews)

    goalValueArea.addSubview(goalValueStack)
  }

  private func setupConstraints() {
    setupHeaderConstraints()
    setupFormConstraints()
    setupSaveButtonConstraints()
  }

  private func setupHeaderConstraints() {
    backButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(2)
      $0.leading.equalToSuperview().offset(16)
      $0.size.equalTo(28)
    }

    titleLabel.snp.makeConstraints {
      $0.centerY.equalTo(backButton)
      $0.centerX.equalToSuperview()
    }
  }

  private func setupFormConstraints() {
    emojiButton.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(Metrics.topOffset)
      $0.leading.equalToSuperview().offset(Metrics.horizontalPadding)
      $0.size.equalTo(Metrics.emojiButtonSize)
    }

    nameTextField.snp.makeConstraints {
      $0.centerY.equalTo(emojiButton)
      $0.leading.equalTo(emojiButton.snp.trailing).offset(8)
      $0.trailing.equalToSuperview().inset(Metrics.horizontalPadding)
      $0.height.equalTo(Metrics.textFieldHeight)
    }

    goalContainerView.snp.makeConstraints {
      $0.top.equalTo(emojiButton.snp.bottom).offset(Metrics.verticalSpacing)
      $0.leading.trailing.equalToSuperview().inset(Metrics.horizontalPadding)
      $0.height.equalTo(Metrics.goalContainerHeight)
    }

    setupGoalContainerConstraints()
  }

  private func setupGoalContainerConstraints() {
    goalTitleLabel.snp.makeConstraints {
      $0.leading.top.equalToSuperview().offset(16)
    }

    goalValueArea.snp.makeConstraints {
      $0.top.equalTo(goalTitleLabel.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalToSuperview().inset(16)
    }

    goalValueStack.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }

  private func setupSaveButtonConstraints() {
    saveButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(Metrics.horizontalPadding)
      $0.height.equalTo(Metrics.buttonHeight)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Metrics.bottomSafeAreaInset)
    }
  }

  private func addDashedCircleToEmojiButton() {
    let dashedLayer = CAShapeLayer()
    dashedLayer.strokeColor = Palette.Gray.g300.cgColor
    dashedLayer.fillColor = UIColor.clear.cgColor
    dashedLayer.lineDashPattern = Metrics.dashPattern
    dashedLayer.lineWidth = 1

    // 중앙에 배치할 원의 frame 계산
    let centerX = emojiButton.bounds.midX
    let centerY = emojiButton.bounds.midY
    let radius = Metrics.dashedCircleSize / 2
    let circleFrame = CGRect(
      x: centerX - radius,
      y: centerY - radius,
      width: Metrics.dashedCircleSize,
      height: Metrics.dashedCircleSize
    )

    dashedLayer.path = UIBezierPath(ovalIn: circleFrame).cgPath
    emojiButton.layer.addSublayer(dashedLayer)
  }

  @objc private func backButtonTapped() {
    navigationController?.popViewController(animated: true)
  }

  // MARK: - Setup

  private func setupView() {
    // 메인 뷰에 추가
    for item in [backButton, titleLabel, emojiButton, nameTextField, goalContainerView, saveButton] {
      view.addSubview(item)
    }
    // 목표시간 컨테이너에 하위 뷰 추가
    goalContainerView.addSubview(goalTitleLabel)
    goalContainerView.addSubview(goalValueArea)

    // 목표시간 값 표시 스택
    goalValueArea.addSubview(goalValueStack)
    goalValueStack.addArrangedSubview(goalValueNumberLabel)
    goalValueStack.addArrangedSubview(goalValueUnitLabel)
  }

  // MARK: - Dashed Circle (이모지 버튼 안쪽 점선 원)

  private func setupDashedCircle() {
    let dashedCircle = UIView()
    dashedCircle.backgroundColor = .clear
    dashedCircle.isUserInteractionEnabled = false

    emojiButton.addSubview(dashedCircle)
    dashedCircle.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.height.equalTo(40)
    }

    dashedCircle.layoutIfNeeded()

    // 점선 원 레이어
    let dashedLayer = CAShapeLayer()
    dashedLayer.strokeColor = Palette.Gray.g300.cgColor
    dashedLayer.fillColor = UIColor.clear.cgColor
    dashedLayer.lineDashPattern = [4, 2]
    dashedLayer.lineWidth = 1
    dashedLayer.path = UIBezierPath(ovalIn: dashedCircle.bounds).cgPath

    dashedCircle.layer.addSublayer(dashedLayer)
  }
}
