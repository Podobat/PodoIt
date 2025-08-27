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
    static let goalContainerHeightExpanded: CGFloat = 312
    static let textFieldHeight: CGFloat = 56
    static let textFieldLeftPadding: CGFloat = 16
    static let topOffset: CGFloat = 32
    static let bottomSafeAreaInset: CGFloat = 20
    static let dashedCircleSize: CGFloat = 40

    // Picker
    static let inlinePickerMinWidth: CGFloat = 90
    static let pickerRowHeight: CGFloat = 48
    static let unitRightInset: CGFloat = 16
    static let unitLeftSpacing: CGFloat = 8
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
      style: .labelMd(weight: .semibold),
      color: Palette.Gray.g500
    )
  }

  // 숫자/분 들어가는 회색 영역
  private let goalValueArea = UIView().then {
    $0.backgroundColor = .gray100
    $0.layer.cornerRadius = Metrics.cornerRadius
    $0.clipsToBounds = true
    $0.isUserInteractionEnabled = true // 탭 제스처
  }

  // 분 선택 피커
  private lazy var minutePicker = UIPickerView().then {
    $0.dataSource = self
    $0.delegate = self
    $0.backgroundColor = .clear
    $0.showsSelectionIndicator = false
  }

  // 분 고정 유닛
  private let unitLabel = UILabel().then {
    $0.attributedText = Typography.attributed("분", style: .headingXl(weight: .semibold), color: .gray600)
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    $0.setContentHuggingPriority(.required, for: .horizontal)
  }

  // 접힘 상태에서 중앙값 표시
  private let collapsedValueLabel = UILabel().then {
    $0.textAlignment = .center
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
  private var minutePickerMinHeightConstraint: Constraint?
  private var isPickerExpanded = false

  // MARK: - Data

  private let minuteOptions: [Int] = Array(stride(from: 5, through: 180, by: 5))
  private var selectedMinutes: Int = 50

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .gray100
    navigationController?.setNavigationBarHidden(true, animated: false)
    addSubviews()
    setupConstraints()

    goalTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    goalTitleLabel.setContentHuggingPriority(.required, for: .vertical)
    goalValueArea.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    minutePicker.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    unitLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

    if let idx = minuteOptions.firstIndex(of: selectedMinutes) {
      minutePicker.selectRow(idx, inComponent: 0, animated: false)
    }

    goalValueArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(togglePicker)))
    applyCollapsedUI(animated: false)
    updateCollapsedLabelText()
  }

  // 점선 원 뷰
  private let dashedCircleView = UIView().then {
    $0.backgroundColor = .clear
  }

  private func addSubviews() {
    let mainViews = [backButton, titleLabel, emojiButton, nameTextField, goalContainerView, saveButton]
    view.addSubviews(mainViews)

    goalContainerView.addSubviews([goalTitleLabel, goalValueArea])
    goalValueArea.addSubviews([minutePicker, unitLabel, collapsedValueLabel])

    emojiButton.addSubview(dashedCircleView)
    dashedCircleView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.size.equalTo(Metrics.dashedCircleSize)
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    // CAShapeLayer 점선 원 그리기
    dashedCircleView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

    let shapeLayer = CAShapeLayer()
    let path = UIBezierPath(
      ovalIn: CGRect(origin: .zero,
                     size: CGSize(width: Metrics.dashedCircleSize,
                                  height: Metrics.dashedCircleSize))
    )
    shapeLayer.path = path.cgPath
    shapeLayer.strokeColor = Palette.Gray.g200.cgColor
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.lineWidth = 1
    shapeLayer.lineDashPattern = [4, 2] // 4pt 그려지고 2pt 띄움
    dashedCircleView.layer.addSublayer(shapeLayer)
  }

  private func setupConstraints() {
    setupHeaderConstraints()
    setupFormConstraints()
  }

  private func setupHeaderConstraints() {
    backButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
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

    unitLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().inset(Metrics.unitRightInset)
    }

    minutePicker.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview()
      $0.trailing.equalTo(unitLabel.snp.leading).offset(-Metrics.unitLeftSpacing)
      $0.top.greaterThanOrEqualToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
      $0.width.greaterThanOrEqualTo(Metrics.inlinePickerMinWidth)

      minutePickerMinHeightConstraint = $0.height
        .greaterThanOrEqualTo(Metrics.pickerRowHeight * 3)
        .constraint
    }

    minutePickerMinHeightConstraint?.deactivate()

    collapsedValueLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.leading.greaterThanOrEqualToSuperview().offset(16)
      $0.trailing.lessThanOrEqualToSuperview().inset(16)
    }

    saveButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(Metrics.horizontalPadding)
      $0.height.equalTo(Metrics.buttonHeight)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Metrics.bottomSafeAreaInset)
    }
  }

  // MARK: - Collapsed/Expanded

  // 펼침/접힘에 따라 ValueArea의 배경/모서리를 토글
  private func updateValueAreaStyle(isCollapsed: Bool) {
    if isCollapsed {
      goalValueArea.backgroundColor = .gray100
      goalValueArea.layer.cornerRadius = Metrics.cornerRadius
      goalValueArea.clipsToBounds = true
    } else {
      goalValueArea.backgroundColor = .clear
      goalValueArea.layer.cornerRadius = 0
      goalValueArea.clipsToBounds = false
    }
  }

  private func updateCollapsedLabelText() {
    // 숫자(마지막 글자에만 kerning 8)
    let number = NSMutableAttributedString(
      attributedString: Typography.attributed(
        "\(selectedMinutes)", style: .displayMd(weight: .semibold), color: .appBlack
      )
    )
    if number.length > 0 {
      number.addAttribute(.kern, value: 8, range: NSRange(location: number.length - 1, length: 1))
    }

    // 단위
    let unit = Typography.attributed("분", style: .headingXl(weight: .semibold), color: .gray600)

    number.append(unit)
    collapsedValueLabel.attributedText = number
  }

  private func applyCollapsedUI(animated: Bool) {
    isPickerExpanded = false
    unitLabel.isHidden = true
    minutePicker.isHidden = true
    collapsedValueLabel.isHidden = false

    minutePickerMinHeightConstraint?.deactivate()
    goalContainerHeightConstraint?.update(offset: Metrics.goalContainerHeightCollapsed)
    updateValueAreaStyle(isCollapsed: true)

    let changes = { self.view.layoutIfNeeded() }
    animated ? UIView.animate(withDuration: 0.25, animations: changes) : changes()
  }

  private func applyExpandedUI(animated: Bool) {
    isPickerExpanded = true
    unitLabel.isHidden = false
    minutePicker.isHidden = false
    collapsedValueLabel.isHidden = true

    minutePickerMinHeightConstraint?.activate()
    goalContainerHeightConstraint?.update(offset: Metrics.goalContainerHeightExpanded)
    updateValueAreaStyle(isCollapsed: false)

    let changes = { self.view.layoutIfNeeded() }
    animated ? UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: changes) : changes()
  }

  // MARK: - Actions

  @objc private func backButtonTapped() {
    navigationController?.popViewController(animated: true)
  }

  @objc private func togglePicker() {
    isPickerExpanded ? applyCollapsedUI(animated: true) : applyExpandedUI(animated: true)
  }
}

// MARK: - UIPickerView DataSource & Delegate

extension TimerEditViewController: UIPickerViewDataSource, UIPickerViewDelegate {
  func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { minuteOptions.count }
  func pickerView(_ pickerView: UIPickerView,
                  viewForRow row: Int,
                  forComponent component: Int,
                  reusing view: UIView?) -> UIView
  {
    let label = (view as? UILabel) ?? UILabel()
    label.text = "\(minuteOptions[row])"
    label.font = Typography.font(for: .displayMd(weight: .semibold))
    label.textColor = .appBlack
    label.textAlignment = .center
    label.adjustsFontForContentSizeCategory = true

    label.isAccessibilityElement = true
    label.accessibilityLabel = "\(minuteOptions[row])분"

    return label
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectedMinutes = minuteOptions[row]
    if !isPickerExpanded { updateCollapsedLabelText() }
  }

  func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
    Metrics.pickerRowHeight
  }
}
