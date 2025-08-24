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

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .gray100
    setupView()
    setupConstraints()
    setupDashedCircle()
    backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
  }

  @objc private func backButtonTapped() {
    navigationController?.popViewController(animated: true)
  }

  // MARK: - Setup

  private func setupView() {
    for item in [backButton, titleLabel, emojiButton, nameTextField] {
      view.addSubview(item)
    }
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
