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
    static let goalContainerHeightCollapsed: CGFloat = 112
    static let textFieldHeight: CGFloat = 56
    static let textFieldLeftPadding: CGFloat = 16
    static let topOffset: CGFloat = 32
    static let bottomSafeAreaInset: CGFloat = 20
    static let dashedCircleSize: CGFloat = 40
  }

  // MARK: - UI Components

  // 뒤로 가기 버튼
  private lazy var backButton = UIButton().then {
    let image = UIImage(named: "arrow-left")?.withRenderingMode(.alwaysOriginal)
    $0.setImage(image, for: .normal)
    $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
  }

  // 화면 상단 제목
  private let titleLabel = UILabel().then {
    $0.attributedText = Typography.attributed("타이머 추가", style: .headingMd, color: .appBlack)
    $0.textAlignment = .center
  }

  // 이모지 선택 버튼 (default : plus 버튼)
  private let emojiButton = UIButton(type: .system).then {
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
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  // 목표시간 영역 컨테이너
  private let goalContainerView = UIView().then {
    $0.backgroundColor = .appWhite
    $0.layer.cornerRadius = Metrics.cornerRadius
    $0.clipsToBounds = true
  }

  // 목표 집중 시간 label
  private let goalTitleLabel = UILabel().then {
    $0.attributedText = Typography.attributed(
      "목표 집중 시간",
      style: .labelLg(weight: .semibold),
      color: Palette.Gray.g500
    )
  }

  // 숫자/분 들어가는 회색 영역
  private let goalValueArea = UIView().then {
    $0.backgroundColor = .gray100
    $0.layer.cornerRadius = Metrics.cornerRadius
    $0.clipsToBounds = true
  }

  // 접힘 UI일 때 중앙에 보이는 숫자/단위 라벨
  private let collapsedNumberLabel = UILabel().then {
    $0.attributedText = Typography.attributed(
      "50",
      style: .displayMd(weight: .semibold),
      color: .appBlack
    )
    $0.textAlignment = .center
  }

  private let collapsedUnitLabel = UILabel().then {
    $0.attributedText = Typography.attributed(
      "분",
      style: .headingXl(weight: .bold),
      color: .appBlack
    )
    $0.textAlignment = .center
  }

  private lazy var collapsedValueStack = UIStackView(arrangedSubviews: [collapsedNumberLabel, collapsedUnitLabel]).then {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.spacing = 8
  }

  // 저장하기 버튼
  private let saveButton = UIButton(type: .system).then {
    $0.backgroundColor = Palette.Primary.p600
    $0.layer.cornerRadius = Metrics.buttonCornerRadius
    $0.clipsToBounds = true
    $0.setAttributedTitle(
      Typography.attributed("저장하기", style: .labelLg(weight: .semibold), color: .appWhite),
      for: .normal
    )
    $0.isEnabled = true
  }

  // MARK: - Constraints

  private var goalContainerHeightConstraint: Constraint?

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViewController()
    navigationController?.setNavigationBarHidden(true, animated: false)
  }

  // MARK: - Setup

  private func setupViewController() {
    view.backgroundColor = .gray100
    addSubviews()
    setupConstraints()
  }

  private func addSubviews() {
    let mainViews = [backButton, titleLabel, emojiButton, nameTextField, goalContainerView, saveButton]
    view.addSubviews(mainViews)

    goalContainerView.addSubviews([goalTitleLabel, goalValueArea])
    goalValueArea.addSubview(collapsedValueStack)
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
      goalContainerHeightConstraint = $0.height.equalTo(Metrics.goalContainerHeightCollapsed).constraint
    }

    goalTitleLabel.snp.makeConstraints {
      $0.leading.top.equalToSuperview().offset(16)
    }

    goalValueArea.snp.makeConstraints {
      $0.top.equalTo(goalTitleLabel.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalToSuperview().inset(16)
    }

    collapsedValueStack.snp.makeConstraints {
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

  // MARK: - Actions

  @objc private func backButtonTapped() {
    navigationController?.popViewController(animated: true)
  }
}
