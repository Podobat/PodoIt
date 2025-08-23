//
//  TimerViewController.swift
//  PodoIt
//
//  Created by 노가현 on 8/20/25.
//

import SnapKit
import Then
import UIKit

final class TimerViewController: UIViewController {
  // MARK: - Constants

  private enum Layout {
    static let horizontalPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 16
    static let dividerHeight: CGFloat = 1
    static let emptyTopOffset: CGFloat = 240
    static let addButtonBottomOffset: CGFloat = -20
    static let addButtonHeight: CGFloat = 48
  }

  // MARK: - UI Components

  private let headerView = TimerHeaderView()
  private let emptyStateView = EmptyStateView()

  private let backgroundContainerView = UIView().then {
    $0.backgroundColor = .gray100
  }

  private let addButton = UIButton(type: .system).then {
    let image = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
    $0.setImage(image, for: .normal)
    $0.setTitle("추가하기", for: .normal)
    $0.titleLabel?.font = Typography.font(for: .labelLg(weight: .semibold))
    $0.setTitleColor(.appWhite, for: .normal)
    $0.tintColor = .appWhite
    $0.backgroundColor = Palette.Primary.p600
    $0.layer.cornerRadius = 24
    $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    $0.semanticContentAttribute = .forceLeftToRight
    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
  }

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }

  // MARK: - UI Setup

  private func configureUI() {
    view.backgroundColor = .appWhite
    setupViews()
    setupConstraints()
  }

  private func setupViews() {
    for item in [headerView, backgroundContainerView, emptyStateView, addButton] {
      view.addSubview(item)
    }
  }

  private func setupConstraints() {
    headerView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
      $0.leading.trailing.equalToSuperview()
    }

    backgroundContainerView.snp.makeConstraints {
      $0.top.equalTo(headerView.snp.bottom).offset(Layout.sectionSpacing)
      $0.leading.trailing.bottom.equalToSuperview()
    }

    emptyStateView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(backgroundContainerView.snp.top).offset(Layout.emptyTopOffset)
    }

    addButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(Layout.addButtonBottomOffset)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(Layout.addButtonHeight)
    }
  }
}
