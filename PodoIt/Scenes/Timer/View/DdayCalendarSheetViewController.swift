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
    static let grabberHeight: CGFloat = 5 // 회색바 높이
    static let grabberWidth: CGFloat = 40 // 회색바 너비
    static let horizontalPadding: CGFloat = 20 // 좌우 여백
    static let grabberTopInset: CGFloat = 16 // 회색바 상단 여백
    static let contentTopOffset: CGFloat = 40 // 콘텐츠 상단 여백
  }
  
  // MARK: - Properties
  
  var onDateSelected: ((Date) -> Void)?
  
  private let sheetTransitioningDelegate = SheetTransitioningDelegate()
  
  private let grabber = UIView().then {
    $0.backgroundColor = .gray300
    $0.layer.cornerRadius = 2.5
  }
  
  private let contentLabel = UILabel().then {
    $0.text = "디데이 날짜를 선택해 주세요"
    $0.font = Typography.font(for: .headingMd(weight: .semibold))
    $0.textColor = .appBlack
    $0.textAlignment = .center
  }
  
  // MARK: - Init
  
  init() {
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .custom
    transitioningDelegate = sheetTransitioningDelegate
    
    sheetTransitioningDelegate.contentHeight = .custom { size, insets in
      let height: CGFloat = 300
      return min(size.height - insets.top, height + insets.bottom)
    }
    sheetTransitioningDelegate.scrollView = nil
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
    view.addSubview(grabber)
    view.addSubview(contentLabel)
  }
  
  private func configureLayout() {
    grabber.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Metrics.grabberTopInset)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(Metrics.grabberWidth)
      $0.height.equalTo(Metrics.grabberHeight)
    }
    
    contentLabel.snp.makeConstraints {
      $0.top.equalTo(grabber.snp.bottom).offset(Metrics.contentTopOffset)
      $0.leading.trailing.equalToSuperview().inset(Metrics.horizontalPadding)
      $0.centerY.equalToSuperview()
    }
  }
}
