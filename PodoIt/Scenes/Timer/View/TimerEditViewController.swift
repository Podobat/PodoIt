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
  // MARK: - Test Configuration

  // 빌드타입별 테스트 모드 설정
  #if DEBUG
  private static let isTestMode = true
  #else
  private static let isTestMode = false
  #endif

  // ViewModel 주입
  private let viewModel: TimerEditViewModel

  // 편집 모드 여부
  private var isEditMode: Bool { viewModel.editing != nil }

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
    // 단위 라벨을 박스 중앙으로부터 고정 오프셋
    static let unitCenterFixedOffset: CGFloat = 44
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

  // 상단 우측 삭제 버튼
  private lazy var deleteButton = UIButton(type: .system).then {
    let image = UIImage(named: "trash")
    $0.setImage(image, for: .normal)
    $0.tintColor = Palette.Gray.g900
    $0.isHidden = true // 편집 모드에서만 노출
    $0.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
  }

  // 이모지 선택 버튼 (default : plus 버튼)
  private let emojiButton = UIButton(type: .system).then {
    let image = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
    $0.setImage(image, for: .normal)
    $0.tintColor = Palette.Primary.p600
    $0.backgroundColor = .appWhite
    $0.layer.cornerRadius = Metrics.buttonCornerRadius
    $0.clipsToBounds = true
    $0.contentEdgeInsets = .zero
    $0.isUserInteractionEnabled = true
    $0.addTarget(self, action: #selector(emojiButtonTapped), for: .touchUpInside)
    $0.addTarget(self, action: #selector(emojiButtonTouchDown), for: .touchDown)
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
    // 에러 테두리 대비 초기 상태
    $0.layer.borderWidth = 0
    $0.layer.borderColor = UIColor.clear.cgColor
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

  // 통합 타임 피커
  private lazy var timePicker = UIPickerView().then {
    $0.dataSource = self
    $0.delegate = self
    $0.backgroundColor = .clear
    $0.showsSelectionIndicator = false
  }

  private lazy var unitLabel = UILabel().then { [isTest = TimerEditViewController.isTestMode] in
    let unit = isTest ? "초" : "분"
    $0.attributedText = Typography.attributed(unit, style: .headingXl(weight: .semibold), color: .appBlack)
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    $0.setContentHuggingPriority(.required, for: .horizontal)
  }

//  // 분 선택 피커
//  private lazy var minutePicker = UIPickerView().then {
//    $0.dataSource = self
//    $0.delegate = self
//    $0.backgroundColor = .clear
//    $0.showsSelectionIndicator = false
//  }

//  // 분 고정 유닛
//  private let unitLabel = UILabel().then {
//    $0.attributedText = Typography.attributed("분", style: .headingXl(weight: .semibold), color: .gray600)
//    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
//    $0.setContentHuggingPriority(.required, for: .horizontal)
//  }

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
    $0.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
  }

  // 점선 원 뷰
  private let dashedCircleView = UIView().then {
    $0.backgroundColor = .clear
  }

  // 이모지 입력용 숨겨진 텍스트필드
  private lazy var emojiInputField = EmojiTextField().then {
    $0.autocorrectionType = .no
    $0.spellCheckingType = .no
    $0.autocapitalizationType = .none
    $0.returnKeyType = .done
    $0.tintColor = .clear // 커서 숨김
    $0.textColor = .clear // 텍스트 숨김
    $0.backgroundColor = .clear
    $0.isHidden = true
    $0.delegate = self
    $0.addTarget(self, action: #selector(emojiTextChanged), for: .editingChanged)
  }

  // MARK: - Constraints

  private var goalContainerHeightConstraint: Constraint?
  // private var minutePickerMinHeightConstraint: Constraint?
  private var timePickerMinHeightConstraint: Constraint?
  private var isPickerExpanded = false
  private var currentSelectedRow: Int = 0
  private var unitLeadingConstraint: Constraint?

  // MARK: - Data

  private lazy var timeOptions: [Int] = {
    if TimerEditViewController.isTestMode {
      // 테스트 모드: 30초부터 10분까지 30초 간격 (초 단위)
      return Array(stride(from: 30, through: 600, by: 30))
    } else {
      // 프로덕션 모드: 5분부터 3시간까지 5분 간격 (분 단위)
      return Array(stride(from: 5, through: 180, by: 5))
    }
  }()

  private lazy var selectedTime: Int = TimerEditViewController.isTestMode ? 120 : 50 // 테스트: 120초(2분) / 프로덕션: 50분

//  // MARK: - Data
//
//  private let minuteOptions: [Int] = Array(stride(from: 5, through: 180, by: 5))
//  private var selectedMinutes: Int = 50

  // 이모지 상태
  private var selectedEmoji: String?

  // MARK: - Init

  init(viewModel: TimerEditViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .gray100
    navigationController?.setNavigationBarHidden(true, animated: false)
    addSubviews()
    setupConstraints()
    setupGestures()

    nameTextField.delegate = self
    // 이름 필드 변경 실시간 감지 → 비면 빨간 스트로크
    nameTextField.addTarget(self, action: #selector(nameEditingChanged), for: .editingChanged)

    goalTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    goalTitleLabel.setContentHuggingPriority(.required, for: .vertical)
    goalValueArea.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    // minutePicker.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    timePicker.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    unitLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

    if let idx = timeOptions.firstIndex(of: selectedTime) {
      timePicker.selectRow(idx, inComponent: 0, animated: false)
      currentSelectedRow = idx
      updateUnitLabelPosition()
    }

//    if let idx = minuteOptions.firstIndex(of: selectedMinutes) {
//      minutePicker.selectRow(idx, inComponent: 0, animated: false)
//    }

    // 편집 모드 처리 (타이틀/프리필/휴지통 표시)
    setupEditMode()

    applyCollapsedUI(animated: false)
    updateCollapsedLabelText()

    updateSaveButtonStyle()
  }

  private func setupEditMode() {
    deleteButton.isHidden = !isEditMode

    if let editing = viewModel.editing {
      titleLabel.attributedText = Typography.attributed("타이머 수정", style: .headingMd, color: .appBlack)
      nameTextField.text = editing.title

      if TimerEditViewController.isTestMode {
        selectedTime = editing.goalTime * 60
      } else {
        selectedTime = editing.goalTime
      }

      if let editIdx = timeOptions.firstIndex(of: selectedTime) {
        timePicker.selectRow(editIdx, inComponent: 0, animated: false)
        currentSelectedRow = editIdx
        updateUnitLabelPosition()
      } else if let nearest = timeOptions.min(by: { abs($0 - selectedTime) < abs($1 - selectedTime) }),
                let idx = timeOptions.firstIndex(of: nearest)
      {
        selectedTime = nearest
        timePicker.selectRow(idx, inComponent: 0, animated: false)
        currentSelectedRow = idx
        updateUnitLabelPosition()
      }

//      selectedMinutes = editing.goalTime
//      if let editIdx = minuteOptions.firstIndex(of: selectedMinutes) {
//        minutePicker.selectRow(editIdx, inComponent: 0, animated: false)
//      }
      // 이모지 프리필
      if !editing.iconName.isEmpty {
        setEmojiOnButton(editing.iconName)
      }
    }
    updateSaveButtonStyle()
  }

  private func setupGestures() {
    goalValueArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(togglePicker)))

    // 이모지 버튼 롱프레스 리셋
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(resetEmoji))
    emojiButton.addGestureRecognizer(longPressGesture)

    // 화면 탭으로 이모지 키보드 닫기
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboards))
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
  }

//    goalValueArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(togglePicker)))
//    applyCollapsedUI(animated: false)
//    updateCollapsedLabelText()
//
//    // 저장 버튼 액션 연결
//    saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
//
//    // 이모지 버튼 액션 + 롱프레스 리셋
//    emojiButton.addTarget(self, action: #selector(emojiButtonTapped), for: .touchUpInside)
//    let long = UILongPressGestureRecognizer(target: self, action: #selector(resetEmoji))
//    emojiButton.addGestureRecognizer(long)

//    // 편집 모드 프리필
//    if let editing = viewModel.editing {
//      titleLabel.attributedText = Typography.attributed("타이머 수정", style: .headingMd, color: .appBlack)
//      nameTextField.text = editing.title
//      selectedMinutes = editing.goalTime
//      if let idx = minuteOptions.firstIndex(of: selectedMinutes) {
//        minutePicker.selectRow(idx, inComponent: 0, animated: false)
//      }
//      updateCollapsedLabelText()
//      // emojiButton.setTitle(editing.iconName, for: .normal)
//    }

  private func addSubviews() {
    let mainViews = [backButton, titleLabel, emojiButton, nameTextField, goalContainerView, saveButton, deleteButton]
    view.addSubviews(mainViews)

    view.addSubview(emojiInputField)

    goalContainerView.addSubviews([goalTitleLabel, goalValueArea])
    // goalValueArea.addSubviews([minutePicker, unitLabel, collapsedValueLabel])
    goalValueArea.addSubviews([timePicker, unitLabel, collapsedValueLabel])

    emojiButton.addSubview(dashedCircleView)
    dashedCircleView.isUserInteractionEnabled = false
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

    deleteButton.snp.makeConstraints {
      $0.centerY.equalTo(backButton)
      $0.trailing.equalToSuperview().inset(20)
      $0.size.equalTo(24)
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

    timePicker.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
      $0.top.greaterThanOrEqualToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
      $0.width.greaterThanOrEqualTo(Metrics.inlinePickerMinWidth)

      timePickerMinHeightConstraint = $0.height
        .greaterThanOrEqualTo(Metrics.pickerRowHeight * 3)
        .constraint
    }

    timePickerMinHeightConstraint?.deactivate()

//    minutePicker.snp.makeConstraints {
//      $0.centerY.equalToSuperview()
//      $0.leading.equalToSuperview()
//      $0.trailing.equalTo(unitLabel.snp.leading).offset(-Metrics.unitLeftSpacing)
//      $0.top.greaterThanOrEqualToSuperview()
//      $0.bottom.lessThanOrEqualToSuperview()
//      $0.width.greaterThanOrEqualTo(Metrics.inlinePickerMinWidth)
//
//      minutePickerMinHeightConstraint = $0.height
//        .greaterThanOrEqualTo(Metrics.pickerRowHeight * 3)
//        .constraint
//    }
//
//    minutePickerMinHeightConstraint?.deactivate()

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

    emojiInputField.snp.makeConstraints {
      $0.size.equalTo(0)
      $0.top.equalTo(view.snp.bottom)
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

//  private func updateCollapsedLabelText() {
//    // 숫자(마지막 글자에만 kerning 8)
//    let number = NSMutableAttributedString(
//      attributedString: Typography.attributed(
//        "\(selectedMinutes)", style: .displayMd(weight: .semibold), color: .appBlack
//      )
//    )
//    if number.length > 0 {
//      number.addAttribute(.kern, value: 8, range: NSRange(location: number.length - 1, length: 1))
//    }

  private func updateCollapsedLabelText() {
    let valueText: String
    let unitText: String

    if TimerEditViewController.isTestMode {
      valueText = "\(selectedTime)" // 초 값
      unitText = "초"
    } else {
      valueText = "\(selectedTime)" // 분 값
      unitText = "분"
    }

    let number = NSMutableAttributedString(
      attributedString: Typography.attributed(
        valueText, style: .displayMd(weight: .semibold), color: .appBlack
      )
    )
    if number.length > 0 {
      number.addAttribute(.kern, value: 8, range: NSRange(location: number.length - 1, length: 1))
    }

    // 단위
//    let unit = Typography.attributed("분", style: .headingXl(weight: .semibold), color: .gray600)
//    number.append(unit)
//    collapsedValueLabel.attributedText = number

    let unit = Typography.attributed(unitText, style: .headingXl(weight: .semibold), color: .appBlack)
    number.append(unit)
    collapsedValueLabel.attributedText = number
  }

  private func applyCollapsedUI(animated: Bool) {
    isPickerExpanded = false
    unitLabel.isHidden = true
    timePicker.isHidden = true
    collapsedValueLabel.isHidden = false

    timePickerMinHeightConstraint?.deactivate()
    goalContainerHeightConstraint?.update(offset: Metrics.goalContainerHeightCollapsed)
    updateValueAreaStyle(isCollapsed: true)

    let changes = { self.view.layoutIfNeeded() }
    animated ? UIView.animate(withDuration: 0.25, animations: changes) : changes()
  }

  private func applyExpandedUI(animated: Bool) {
    isPickerExpanded = true
    unitLabel.isHidden = false
    timePicker.isHidden = false
    collapsedValueLabel.isHidden = true

    timePickerMinHeightConstraint?.activate()
    goalContainerHeightConstraint?.update(offset: Metrics.goalContainerHeightExpanded)
    updateValueAreaStyle(isCollapsed: false)

    updateUnitLabelPosition()

    let changes = { self.view.layoutIfNeeded() }
    animated ? UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: changes) : changes()
  }

//  private func applyCollapsedUI(animated: Bool) {
//    isPickerExpanded = false
//    unitLabel.isHidden = true
//    minutePicker.isHidden = true
//    collapsedValueLabel.isHidden = false
//
//    minutePickerMinHeightConstraint?.deactivate()
//    goalContainerHeightConstraint?.update(offset: Metrics.goalContainerHeightCollapsed)
//    updateValueAreaStyle(isCollapsed: true)
//
//    let changes = { self.view.layoutIfNeeded() }
//    animated ? UIView.animate(withDuration: 0.25, animations: changes) : changes()
//  }
//
//  private func applyExpandedUI(animated: Bool) {
//    isPickerExpanded = true
//    unitLabel.isHidden = false
//    minutePicker.isHidden = false
//    collapsedValueLabel.isHidden = true
//
//    minutePickerMinHeightConstraint?.activate()
//    goalContainerHeightConstraint?.update(offset: Metrics.goalContainerHeightExpanded)
//    updateValueAreaStyle(isCollapsed: false)
//
//    let changes = { self.view.layoutIfNeeded() }
//    animated ? UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: changes) : changes()
//  }

  // MARK: - Validation UI

  private func errorStrokeColor() -> CGColor {
    (UIColor(named: "error") ?? .systemRed).cgColor
  }

  private func setNameFieldError(_ show: Bool, animated: Bool = true) {
    let updates = {
      self.nameTextField.layer.borderWidth = show ? 1 : 0
      self.nameTextField.layer.borderColor = show ? self.errorStrokeColor() : UIColor.clear.cgColor
      self.nameTextField.layer.cornerRadius = Metrics.cornerRadius
    }
    if animated {
      UIView.animate(withDuration: 0.15, animations: updates)
    } else {
      updates()
    }
  }

  private func validateNameField() {
    let text = (nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    setNameFieldError(text.isEmpty)
  }

  // 폼 유효성 검사 : 제목 공백/중복 체크
  private func isFormValid() -> Bool {
    let title = (nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    return !title.isEmpty
  }

  // 저장 버튼 스타일 동기화
  private func updateSaveButtonStyle() {
    let valid = isFormValid()
    saveButton.isEnabled = valid

    if valid {
      saveButton.backgroundColor = Palette.Primary.p600
      saveButton.setAttributedTitle(
        Typography.attributed("저장하기", style: .labelLg(weight: .semibold), color: .appWhite),
        for: .normal
      )
    } else {
      saveButton.backgroundColor = Palette.Gray.g200
      saveButton.setAttributedTitle(
        Typography.attributed("저장하기", style: .labelLg(weight: .semibold), color: Palette.Gray.g400),
        for: .normal
      )
    }
  }

  // MARK: - Actions

  @objc private func dismissKeyboards() {
    view.endEditing(true)
  }

  @objc private func backButtonTapped() {
    navigationController?.popViewController(animated: true)
  }

  @objc private func togglePicker() {
    isPickerExpanded ? applyCollapsedUI(animated: true) : applyExpandedUI(animated: true)
  }

  @objc private func saveTapped() {
    let title = (nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    // 아이콘 결정 우선순위: selectedEmoji → attributedTitle.string → 기본값
    let attributed = emojiButton.attributedTitle(for: .normal)?.string
    let icon = selectedEmoji ?? (attributed?.isEmpty == false ? attributed! : "🟣")
    // let minutes = selectedMinutes

    guard !title.isEmpty else {
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
      setNameFieldError(true, animated: true)
      nameTextField.becomeFirstResponder()
      updateSaveButtonStyle()
      return
    }

    // 중복 제목
    if viewModel.hasDuplicateTitle(title) {
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
      setNameFieldError(true, animated: true)
      nameTextField.becomeFirstResponder()
      showToast("중복된 이름이 있어요.", icon: UIImage(named: "bang"), above: saveButton)
      updateSaveButtonStyle()
      return
    }

    setNameFieldError(false, animated: true)

    let minutes: Int = TimerEditViewController.isTestMode
      ? max(1, Int(ceil(Double(selectedTime) / 60.0)))
      : selectedTime

    do {
      try viewModel.save(title: title, iconName: icon, goalMinutes: minutes)

      #if DEBUG
      if let id = viewModel.editing?.timerID {
        let secs = TimerEditViewController.isTestMode ? selectedTime : (minutes * 60)
        DebugGoalSecondsStore.set(secs, for: id)
      }
      #endif

      navigationController?.popViewController(animated: true)
    } catch {
      print("save error:", error)
    }

//    do {
//      try viewModel.save(title: title, iconName: icon, goalMinutes: minutes)
//      navigationController?.popViewController(animated: true)
//    } catch {
//      print("save error:", error)
//    }
  }

  @objc private func deleteButtonTapped() {
    guard isEditMode else { return }

    PodoAlertController.presentDeleteTimerAlert(from: self) { [weak self] in
      guard let self else { return }
      do {
        try self.viewModel.delete()
        self.navigationController?.popViewController(animated: true)
      } catch {
        print("delete error:", error)
      }
    }
  }

  // MARK: - Emoji input

  @objc private func emojiButtonTouchDown() {
    print("emojiButton touchDown detected")
  }

  @objc private func emojiButtonTapped() {
    emojiInputField.becomeFirstResponder()
  }

  @objc private func dismissEmojiKeyboard() {
    emojiInputField.resignFirstResponder()
  }

  @objc private func emojiTextChanged(_ sender: UITextField) {
    let text = sender.text ?? ""
    guard let firstGrapheme = text.first else { return }
    let emoji = String(firstGrapheme)

    setEmojiOnButton(emoji)

    // 햅틱 & 정리
    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    sender.text = ""
    sender.resignFirstResponder()

    updateSaveButtonStyle()
  }

  private func setEmojiOnButton(_ emoji: String) {
    selectedEmoji = emoji

    // 이미지 제거 후 타이틀로 이모지 표시
    emojiButton.setImage(nil, for: .normal)
    emojiButton.setAttributedTitle(
      Typography.attributed(emoji, style: .headingXl(weight: .semibold), color: .appBlack),
      for: .normal
    )
    emojiButton.tintColor = Palette.Primary.p600
    dashedCircleView.isHidden = true

    // 살짝 튀는 애니메이션
    UIView.animate(withDuration: 0.08, animations: {
      self.emojiButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }) { _ in
      UIView.animate(withDuration: 0.18) {
        self.emojiButton.transform = .identity
      }
    }
  }

  @objc private func resetEmoji(_ gr: UILongPressGestureRecognizer) {
    guard gr.state == .began else { return }
    let image = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
    emojiButton.setAttributedTitle(nil, for: .normal)
    emojiButton.setImage(image, for: .normal)
    emojiButton.tintColor = Palette.Primary.p600
    dashedCircleView.isHidden = false
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    updateSaveButtonStyle()
  }

  // 이름 편집 중 실시간 검증 (지우면 빨간 스트로크)
  @objc private func nameEditingChanged(_ sender: UITextField) {
    // 한글 조합 중이면 패스
    if let marked = sender.markedTextRange,
       sender.position(from: marked.start, offset: 0) != nil
    {
      return
    }
    validateNameField()
    updateSaveButtonStyle()
  }
}

// MARK: - UIPickerView DataSource & Delegate

extension TimerEditViewController: UIPickerViewDataSource, UIPickerViewDelegate {
  func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
  // func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { minuteOptions.count }
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    timeOptions.count
  }

  func pickerView(_ pickerView: UIPickerView,
                  viewForRow row: Int,
                  forComponent component: Int,
                  reusing view: UIView?) -> UIView
  {
    let container: UIView
    let numberLabel: UILabel

    if let reused = view as? UIView, let n = reused.viewWithTag(4001) as? UILabel {
      container = reused
      numberLabel = n
    } else {
      container = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width, height: Metrics.pickerRowHeight))
      container.autoresizingMask = [.flexibleWidth]

      numberLabel = UILabel()
      numberLabel.tag = 4001
      numberLabel.textAlignment = .center
      numberLabel.adjustsFontForContentSizeCategory = true
      container.addSubview(numberLabel)
    }

    let valueText = "\(timeOptions[row])"
    numberLabel.attributedText = Typography.attributed(valueText, style: .displayMd(weight: .semibold), color: .appBlack)

    // 숫자 라벨을 좌측으로 delta만큼
    let unitText = TimerEditViewController.isTestMode ? "초" : "분"
    let unitFont = Typography.font(for: .headingXl(weight: .semibold))
    let unitWidth = (unitText as NSString).size(withAttributes: [.font: unitFont]).width
    let delta = (unitWidth + Metrics.unitLeftSpacing) / 2.0

    numberLabel.snp.remakeConstraints { make in
      make.centerY.equalToSuperview()
      make.centerX.equalToSuperview().offset(-delta)
    }

    container.isAccessibilityElement = true
    container.accessibilityLabel = "\(valueText)\(unitText)"
    return container
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    // selectedMinutes = minuteOptions[row]
    selectedTime = timeOptions[row]
    currentSelectedRow = row
    pickerView.reloadComponent(0)
    updateUnitLabelPosition()
    if !isPickerExpanded { updateCollapsedLabelText() }
    updateSaveButtonStyle()
  }

  func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
    Metrics.pickerRowHeight
  }
}

// MARK: - Unit Label Positioning

private extension TimerEditViewController {
  func updateUnitLabelPosition() {
    // 박스 중앙에서 고정 오프셋 위치에 단위 배치
    let offset = Metrics.unitCenterFixedOffset

    unitLabel.snp.remakeConstraints {
      $0.centerY.equalTo(goalValueArea)
      $0.leading.equalTo(goalValueArea.snp.centerX).offset(offset)
    }

    // 레이아웃 반영
    view.layoutIfNeeded()
  }
}

// MARK: - UITextFieldDelegate (15자 제한)

extension TimerEditViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }

  // 이름 필드 15자 제한
  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool
  {
    // 다른 텍스트필드는 제한 X
    guard textField === nameTextField else { return true }

    // 한글 등 조합 중(회색 밑줄 상태)일 땐 제한 적용 X
    if let marked = textField.markedTextRange,
       textField.position(from: marked.start, offset: 0) != nil
    {
      return true
    }

    let limit = 15
    let current = textField.text ?? ""

    // NSRange -> String.Range
    guard let swiftRange = Range(range, in: current) else { return true }

    // 바뀐 뒤 텍스트 가정
    let proposed = current.replacingCharacters(in: swiftRange, with: string)

    // 15자 이하면 허용
    if proposed.count <= limit { return true }

    // 초과 시 : 남은 길이만 허용 (붙여넣기 대비)
    let replacingCount = current[swiftRange].count
    let remaining = limit - (current.count - replacingCount)

    guard remaining > 0 else {
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
      return false
    }

    // 남은 칸만큼 replacement 자르기
    let allowedPrefix = String(string.prefix(remaining))
    let truncated = current.replacingCharacters(in: swiftRange, with: allowedPrefix)
    textField.text = truncated

    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    return false // 우리가 직접 세팅했으니 시스템 변경은 막음
  }
}

// MARK: - Emoji 전용 텍스트필드

/// 이모지 입력을 우선으로 띄우는 전용 텍스트필드
final class EmojiTextField: UITextField {
  // 일부 케이스에서 키보드 전환 보장을 위해 빈 문자열 반환이 안전
  override var textInputContextIdentifier: String? { "" }

  // 가능한 경우 이모지 입력 모드를 우선 반환
  override var textInputMode: UITextInputMode? {
    if let emojiMode = UITextInputMode.activeInputModes.first(where: { $0.primaryLanguage == "emoji" }) {
      return emojiMode
    }
    return super.textInputMode
  }
}
