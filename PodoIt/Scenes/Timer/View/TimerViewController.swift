//
//  TimerViewController.swift
//  PodoIt
//
//  Created by 노가현 on 8/20/25.
//

import SnapKit
import Then
import UIKit

final class TimerViewController: UIViewController, UICollectionViewDelegateFlowLayout { // 사이즈 계산을 위해서 채택

  // MARK: - Constants

  private enum Layout {
    static let horizontalPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 16
    static let dividerHeight: CGFloat = 1
    static let emptyTopOffset: CGFloat = 240
    static let addButtonBottomOffset: CGFloat = -20
    static let addButtonHeight: CGFloat = 48
    static let minimumLineSpacing: CGFloat = 12
    static let sectionInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
    static let cellHeight: CGFloat = 96
  }

  // MARK: - Dummy Data

  private var timers: [TimerModel] = [
    .init(title: "MVP 발표 준비", iconName: "🔥", goalTime: 50),
    .init(title: "iOS 프로젝트", iconName: "💻", goalTime: 120),
    .init(title: "마이페이지 구현", iconName: "🐶", goalTime: 170),
    .init(title: "통계 페이지 구현", iconName: "🦊", goalTime: 200),
    .init(title: "타이머 페이지 구현", iconName: "🐤", goalTime: 380),
    .init(title: "면접 스터디", iconName: "🎉", goalTime: 120),
    .init(title: "알고리즘 준비", iconName: "🔗", goalTime: 520)
  ]

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

  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = Layout.minimumLineSpacing
    layout.sectionInset = Layout.sectionInset
    layout.estimatedItemSize = .zero // 고정 사이즈

    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .clear
    cv.register(TimerCell.self, forCellWithReuseIdentifier: TimerCell.reuseIdentifier)
    cv.dataSource = self
    cv.delegate = self
    return cv
  }()

  private func updateUI() {
    if timers.isEmpty {
      emptyStateView.isHidden = false
      collectionView.isHidden = true
    } else {
      emptyStateView.isHidden = true
      collectionView.isHidden = false
    }
  }

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateUI()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
  }

  @objc private func addButtonTapped() {
    let editVC = TimerEditViewController()
    editVC.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(editVC, animated: true)
  }

  // MARK: - UI Setup

  private func configureUI() {
    view.backgroundColor = .appWhite
    setupViews()
    setupConstraints()
  }

  private func setupViews() {
    for item in [headerView, backgroundContainerView, collectionView, emptyStateView, addButton] {
      view.addSubview(item)
    }
  }

  private func setupConstraints() {
    headerView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
      $0.leading.trailing.equalToSuperview()
    }

    backgroundContainerView.snp.makeConstraints {
      $0.top.equalTo(headerView.snp.bottom).offset(20)
      $0.leading.trailing.bottom.equalToSuperview()
    }

    collectionView.snp.makeConstraints {
      $0.top.equalTo(backgroundContainerView.snp.top)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(backgroundContainerView.snp.bottom)
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

  // MARK: - UICollectionViewDelegateFlowLayout

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize
  {
    guard let flow = collectionViewLayout as? UICollectionViewFlowLayout else {
      return CGSize(width: collectionView.bounds.width, height: Layout.cellHeight)
    }
    let width = collectionView.bounds.width - flow.sectionInset.left - flow.sectionInset.right
    return CGSize(width: width, height: Layout.cellHeight)
  }

  // 셀 탭 시 수정 화면 진입 같은 기본 동작(원하면 사용)
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let editVC = TimerEditViewController()
    editVC.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(editVC, animated: true)
  }
}

// MARK: - UICollectionViewDataSource

extension TimerViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    timers.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: TimerCell.reuseIdentifier,
      for: indexPath
    ) as? TimerCell else {
      return UICollectionViewCell()
    }

    let model = timers[indexPath.item]
    cell.configure(with: model)

    // 셀 → VC로 버튼 탭 이벤트 전달
    cell.onPlayTapped = { [weak self] in
      guard let self else { return }
    }

    return cell
  }
}
