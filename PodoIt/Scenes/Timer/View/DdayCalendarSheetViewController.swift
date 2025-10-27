//
//  DdayCalendarSheetViewController.swift
//  PodoIt
//
//  Created by 노가현 on 8/23/25.
//

import SnapKit
import Then
import UIKit

final class DdayCalendarSheetViewController: UIViewController {
  // MARK: - Metrics
  
  private enum Metrics {
    static let horizontalPadding: CGFloat = 20 // 좌우 여백
    static let contentTopOffset: CGFloat = 40 // 콘텐츠 상단 여백
    static let xButtonTopOffset: CGFloat = 16 // X 버튼 상단 여백
    static let xButtonLeading: CGFloat = 20 // X 버튼 좌측 여백
    static let contentTopOffsetFromX: CGFloat = 20 // 콘텐츠 X 버튼 아래 여백
    static let calendarHeight: CGFloat = 400 // 캘린더 높이
  }
  
  // MARK: - Properties
  
  var onDateSelected: ((Date) -> Void)?
  
  private let sheetTransitioningDelegate = SheetTransitioningDelegate()
  
  private let scrollView = UIScrollView()
  
  private let closeButton = UIButton(type: .system).then {
    let image = UIImage(named: "x")?.withRenderingMode(.alwaysTemplate)
    $0.setImage(image, for: .normal)
    $0.tintColor = .appBlack
  }
  
  private let contentLabel = UILabel().then {
    $0.text = "디데이 날짜를 선택해 주세요"
    $0.font = Typography.font(for: .headingMd(weight: .semibold))
    $0.textColor = .appBlack
    $0.textAlignment = .left
  }
  
  private lazy var datePicker: UIDatePicker = {
    let picker = UIDatePicker()
    picker.preferredDatePickerStyle = .inline
    picker.datePickerMode = .date
    picker.locale = Locale(identifier: "ko_KR")
    picker.calendar = Calendar(identifier: .gregorian)
    picker.minimumDate = Date()
    picker.tintColor = Palette.Primary.p700
    return picker
  }()
  
  // MARK: - Init
  
  init() {
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .custom
    transitioningDelegate = sheetTransitioningDelegate
    
    sheetTransitioningDelegate.contentHeight = .custom { size, insets in
      let height: CGFloat = 500 // 고정 높이
      return min(size.height - insets.top, height + insets.bottom)
    }
    sheetTransitioningDelegate.scrollView = scrollView
    sheetTransitioningDelegate.cornerRadius = 21
    sheetTransitioningDelegate.prefersGrabberVisible = false
    sheetTransitioningDelegate.usesTapGestureDismiss = true
    sheetTransitioningDelegate.usesPanGestureDismiss = true
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureLayout()
  }
  
  // MARK: - SetupUI
  
  private func configureUI() {
    view.backgroundColor = .appWhite
    view.addSubview(scrollView)
    view.addSubview(closeButton)
    scrollView.addSubview(contentLabel)
    scrollView.addSubview(datePicker)
    
    closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
  }
  
  private func configureLayout() {
    scrollView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.trailing.bottom.equalToSuperview()
    }
    
    closeButton.snp.makeConstraints {
      $0.top.equalToSuperview().offset(Metrics.xButtonTopOffset)
      $0.leading.equalToSuperview().offset(Metrics.xButtonLeading)
      $0.width.height.equalTo(24)
    }
    
    contentLabel.snp.makeConstraints {
      $0.top.equalTo(closeButton.snp.bottom).offset(Metrics.contentTopOffsetFromX)
      $0.leading.equalTo(view).offset(20)
      $0.trailing.equalTo(view).offset(-20)
      $0.width.equalTo(view).offset(-40)
    }
    
    datePicker.snp.makeConstraints {
      $0.top.equalTo(contentLabel.snp.bottom).offset(-5)
      $0.centerX.equalTo(view)
      $0.leading.equalTo(view).offset(4)
      $0.trailing.equalTo(view).offset(-20)
      $0.height.equalTo(Metrics.calendarHeight)
      $0.bottom.equalToSuperview().offset(-40)
    }
  }
  
  @objc private func closeButtonTapped() {
    dismiss(animated: true)
  }
  
  @objc private func dateChanged() {
    onDateSelected?(datePicker.date)
  }
}
