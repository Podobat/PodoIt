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
  // MARK: - UI Components

  // 뒤로 가기 버튼
  private let backButton = UIButton().then {
    let image = UIImage(named: "arrow-left")?.withRenderingMode(.alwaysOriginal)
    $0.setImage(image, for: .normal)
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
    $0.layer.cornerRadius = 12
    $0.clipsToBounds = true
  }

  // 타이머 이름 입력 필드
  private let nameTextField = UITextField().then {
    $0.placeholder = "타이머 이름을 적어주세요"
    $0.font = Typography.font(for: .bodyMd(weight: .medium))
    $0.textColor = .appBlack
    $0.backgroundColor = .appWhite
    $0.layer.cornerRadius = 8
    $0.setLeftPadding(16)
  }

  // 목표시간 영역 컨테이너
  private let goalContainerView = UIView().then {
    $0.backgroundColor = .appWhite
    $0.layer.cornerRadius = 8
    $0.clipsToBounds = true
  }

  // 목표 집중 시간 label
  private let goalTitleLabel = UILabel().then {
    $0.attributedText = Typography.attributed(
      "목표 집중 시간",
      style: .labelLg(weight: .semibold),
      color: Palette.Gray.g500
    )
    $0.textAlignment = .left
  }

  // 숫자/분 들어가는 회색 영역
  private let goalValueArea = UIView().then {
    $0.backgroundColor = .gray50
    $0.layer.cornerRadius = 8
    $0.clipsToBounds = true
  }

  // 목표시간 표시 스택 (숫자 + 단위)
  private let goalValueStack = UIStackView().then {
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
  private let saveButton = UIButton(type: .system).then {
    $0.backgroundColor = Palette.Primary.p600
    $0.layer.cornerRadius = 12
    $0.clipsToBounds = true
    $0.setAttributedTitle(
      Typography.attributed("저장하기", style: .labelLg(weight: .semibold), color: .appWhite),
      for: .normal
    )
    $0.isEnabled = true
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .gray100
    setupView()
    setupConstraints()
    setupDashedCircle()
    backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    // saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
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

  private func setupConstraints() {
    // 뒤로가기 버튼
    backButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(2)
      $0.leading.equalToSuperview().offset(16)
      $0.width.height.equalTo(28)
    }

    // 상단 타이틀
    titleLabel.snp.makeConstraints {
      $0.centerY.equalTo(backButton)
      $0.centerX.equalToSuperview()
    }

    // 이모지 버튼
    emojiButton.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(32)
      $0.leading.equalToSuperview().offset(20)
      $0.width.height.equalTo(56)
    }

    // 타이머 이름 입력 필드
    nameTextField.snp.makeConstraints {
      $0.centerY.equalTo(emojiButton)
      $0.leading.equalTo(emojiButton.snp.trailing).offset(8)
      $0.trailing.equalToSuperview().inset(20)
      $0.height.equalTo(56)
    }

    // 목표시간 컨테이너
    goalContainerView.snp.makeConstraints {
      $0.top.equalTo(emojiButton.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview().inset(20)
      $0.height.equalTo(113)
    }

    // 목표시간 제목
    goalTitleLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(16)
      $0.top.equalToSuperview().offset(16)
    }

    // 목표시간 값 영역
    goalValueArea.snp.makeConstraints {
      $0.top.equalTo(goalTitleLabel.snp.bottom).offset(8)
      $0.leading.equalToSuperview().offset(16)
      $0.trailing.equalToSuperview().inset(16)
      $0.bottom.equalToSuperview().inset(16)
    }

    // 목표시간 스택 중앙 배치
    goalValueStack.snp.makeConstraints {
      $0.center.equalToSuperview()
    }

    // 저장하기 버튼
    saveButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(20)
      $0.height.equalTo(48)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
    }
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
