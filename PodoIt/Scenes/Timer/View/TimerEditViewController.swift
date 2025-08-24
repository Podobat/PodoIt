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
  private let backButton = UIButton().then {
    let image = UIImage(named: "arrow-left")?.withRenderingMode(.alwaysOriginal)
    $0.setImage(image, for: .normal)
  }

  private let titleLabel = UILabel().then {
    $0.attributedText = Typography.attributed("타이머 추가", style: .headingMd, color: .appBlack)
    $0.textAlignment = .center
  }

  private let emojiButton = UIButton(type: .system).then {
    let image = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
    $0.setImage(image, for: .normal)
    $0.tintColor = Palette.Primary.p600
    $0.backgroundColor = .appWhite
    $0.layer.cornerRadius = 12
    $0.clipsToBounds = true
  }

  private let nameTextField = UITextField().then {
    $0.placeholder = "타이머 이름을 적어주세요"
    $0.font = Typography.font(for: .bodyMd(weight: .medium))
    $0.textColor = .appBlack
    $0.backgroundColor = .appWhite
    $0.layer.cornerRadius = 8
    $0.setLeftPadding(16)
  }

  private let goalContainerView = UIView().then {
    $0.backgroundColor = .appWhite
    $0.layer.cornerRadius = 8
    $0.clipsToBounds = true
  }

  private let goalTitleLabel = UILabel().then {
    $0.attributedText = Typography.attributed(
      "목표 집중 시간",
      style: .labelLg(weight: .semibold),
      color: Palette.Gray.g500
    )
    $0.textAlignment = .left
  }

  private let goalValueArea = UIView().then {
    $0.backgroundColor = .gray50
    $0.layer.cornerRadius = 8
    $0.clipsToBounds = true
  }

  private let goalValueStack = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.distribution = .fill
    $0.spacing = 6
  }

  private let goalValueNumberLabel = UILabel().then {
    $0.attributedText = Typography.attributed(
      "50",
      style: .displayMd(weight: .bold),
      color: .appBlack
    )
  }

  private let goalValueUnitLabel = UILabel().then {
    $0.attributedText = Typography.attributed(
      "분",
      style: .headingLg,
      color: Palette.Gray.g500
    )
  }

  private let saveButton = UIButton(type: .system).then {
    $0.backgroundColor = Palette.Primary.p600
    $0.layer.cornerRadius = 12
    $0.clipsToBounds = true
    $0.setAttributedTitle(
      Typography.attributed("저장하기", style: .labelLg(weight: .semibold), color: .appWhite),
      for: .normal
    )
    $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
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
    for item in [backButton, titleLabel, emojiButton, nameTextField, goalContainerView, saveButton] {
      view.addSubview(item)
    }
    goalContainerView.addSubview(goalTitleLabel)
    goalContainerView.addSubview(goalValueArea)

    goalValueArea.addSubview(goalValueStack)
    goalValueStack.addArrangedSubview(goalValueNumberLabel)
    goalValueStack.addArrangedSubview(goalValueUnitLabel)
  }

  private func setupConstraints() {
    backButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(2)
      $0.leading.equalToSuperview().offset(16)
      $0.width.height.equalTo(28)
    }

    titleLabel.snp.makeConstraints {
      $0.centerY.equalTo(backButton)
      $0.centerX.equalToSuperview()
    }

    emojiButton.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(32)
      $0.leading.equalToSuperview().offset(20)
      $0.width.height.equalTo(56)
    }

    nameTextField.snp.makeConstraints {
      $0.centerY.equalTo(emojiButton)
      $0.leading.equalTo(emojiButton.snp.trailing).offset(8)
      $0.trailing.equalToSuperview().inset(20)
      $0.height.equalTo(56)
    }

    goalContainerView.snp.makeConstraints {
      $0.top.equalTo(emojiButton.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview().inset(20)
      $0.height.equalTo(113)
    }

    goalTitleLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(16)
      $0.top.equalToSuperview().offset(16)
    }

    goalValueArea.snp.makeConstraints {
      $0.top.equalTo(goalTitleLabel.snp.bottom).offset(8)
      $0.leading.equalToSuperview().offset(16)
      $0.trailing.equalToSuperview().inset(16)
      $0.bottom.equalToSuperview().inset(16)
    }

    goalValueStack.snp.makeConstraints {
      $0.center.equalToSuperview()
    }

    saveButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(20)
      $0.height.equalTo(48)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
    }
  }

  // MARK: - Dashed Circle

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

    let dashedLayer = CAShapeLayer()
    dashedLayer.strokeColor = Palette.Gray.g300.cgColor
    dashedLayer.fillColor = UIColor.clear.cgColor
    dashedLayer.lineDashPattern = [4, 2]
    dashedLayer.lineWidth = 1
    dashedLayer.path = UIBezierPath(ovalIn: dashedCircle.bounds).cgPath

    dashedCircle.layer.addSublayer(dashedLayer)
  }
}
