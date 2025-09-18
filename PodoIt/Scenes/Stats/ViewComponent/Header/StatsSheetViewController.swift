//
//  CategorySheetViewController.swift
//  PodoIt
//
//  Created by 김이든 on 9/1/25.
//

import SnapKit
import UIKit

final class CategorySheetViewController: UIViewController {
  // MARK: - Metrics

  private enum Metrics {
    static let rowHeight: CGFloat = 56
    static let cellVInset: CGFloat = 16
    static let cellHInset: CGFloat = 20
    static let minDetent: CGFloat = 0 // 최소 모달 크기 수정 가능
    static let sheetTopInset: CGFloat = 21
    static let grabberHeight: CGFloat = 5
    static let grabberWidth: CGFloat = 40
  }

  // MARK: - Properties

  private let onSelect: (StatsCategoryModel) -> Void // 선택 결과 전달
  private var selectedCategory: StatsCategoryModel // 현재 선택된 카테고리
  private let categories: [StatsCategoryModel]

  private let checkImage = UIImage.check.withRenderingMode(.alwaysTemplate)

  private let grabber = UIView().then {
    $0.backgroundColor = .gray300
    $0.layer.cornerRadius = 2.5
  }

  private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
    $0.backgroundColor = .clear
    $0.dataSource = self
    $0.delegate = self
    $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    $0.separatorStyle = .none
    $0.rowHeight = UITableView.automaticDimension
    $0.estimatedRowHeight = Metrics.rowHeight
  }

  private let sheetTransitioningDelegate = SheetTransitioningDelegate()

  // MARK: - Init

  init(
    categories: [StatsCategoryModel],
    selectedCategory: StatsCategoryModel = .all,
    onSelect: @escaping (StatsCategoryModel) -> Void
  ) {
    // "전체"를 맨 앞에 추가, 이미 있다면 중복 방지
    var list = categories
    list.removeAll(where: { $0.name == "전체" })
    list.insert(.all, at: 0)

    self.categories = list
    self.selectedCategory = selectedCategory
    self.onSelect = onSelect
    super.init(nibName: nil, bundle: nil)
    self.modalPresentationStyle = .custom
    self.transitioningDelegate = sheetTransitioningDelegate

    let height = CGFloat(categories.count) * Metrics.rowHeight + Metrics.sheetTopInset
    self.sheetTransitioningDelegate.contentHeight = .custom {
      min($0.height - $1.top, height + $1.bottom)
    }
    self.sheetTransitioningDelegate.scrollView = tableView
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
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
    view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    view.backgroundColor = .appWhite
    view.addSubview(grabber)
    view.addSubview(tableView)
  }

  private func configureLayout() {
    grabber.snp.makeConstraints {
      $0.top.equalToSuperview().inset(8)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(Metrics.grabberWidth)
      $0.height.equalTo(Metrics.grabberHeight)
    }

    tableView.snp.makeConstraints {
      $0.top.equalTo(grabber.snp.bottom).offset(8)
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }

  // MARK: - Sheet 설정

  private func configureSheet() {
    guard let sheet = sheetPresentationController else { return }
    // fit = tableView 내용에 맞춰 크기 잡기
    let fit = UISheetPresentationController.Detent.custom(identifier: .init("fit")) { [weak self] ctx in // Detent가 멈추는 높이
      guard let self = self else { return 300 }
      self.view.layoutIfNeeded()

      // 테이블 전체 높이
      let contentHeight = self.tableView.contentSize.height

      // safeArea 반영
      let totalHeight = contentHeight + Metrics.sheetTopInset

      return min(max(totalHeight, Metrics.minDetent), ctx.maximumDetentValue) // 시스템이 허용하는 최대 높이와 비교, 화면의 최대 높이를 넘어가지 않도록 조절
    }

    sheet.detents = [fit]
    sheet.prefersGrabberVisible = true
  }
}

// MARK: - UITableViewDelegate

extension CategorySheetViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let newCategory = categories[indexPath.row]
    guard newCategory != selectedCategory else { return }

    // 이전 선택값 인덱스
    let oldIndex = categories.firstIndex(of: selectedCategory)
    selectedCategory = newCategory

    // 변경된 셀만 리로드
    var reloads = [indexPath]
    if let oldIndex {
      reloads.append(IndexPath(row: oldIndex, section: 0))
    }
    tableView.reloadRows(at: reloads, with: .none)

    onSelect(newCategory)
    dismiss(animated: true)
  }
}

// MARK: - UITableViewDataSource

extension CategorySheetViewController: UITableViewDataSource {
  func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return categories.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let category = categories[indexPath.row]

    var config = cell.defaultContentConfiguration()

    // 전체는 아이콘 없이 텍스트만
    if let icon = category.icon {
      config.text = "\(icon)  " + "\(category.name)".limited(to: 15)
    } else {
      config.text = category.name
    }

    config.attributedText = Typography.attributed(
      config.text ?? "",
      style: .bodyLg(weight: .medium),
      color: .gray900
    )
    config.directionalLayoutMargins = NSDirectionalEdgeInsets(
      top: Metrics.cellVInset,
      leading: Metrics.cellHInset,
      bottom: Metrics.cellVInset,
      trailing: Metrics.cellHInset
    )

    let imageView = UIImageView(image: checkImage)
    imageView.tintColor = .primary500

    cell.backgroundColor = .clear
    cell.contentConfiguration = config
    cell.accessoryView = (category == selectedCategory) ? imageView : .none
    cell.selectionStyle = .none
    return cell
  }
}
