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

  private enum Layout {
    static let rowHeight: CGFloat = 56
    static let cellVInset: CGFloat = 16
    static let cellHInset: CGFloat = 20
    static let sheetCornerRadius: CGFloat = 16
    static let minDetent: CGFloat = 0 // 최소 모달 크기 수정 가능
    static let sheetTopInset: CGFloat = 21
  }

  // MARK: - Properties

  private let onSelect: (StatsCategoryModel) -> Void // 선택 결과 전달
  private var selectedCategory: StatsCategoryModel // 현재 선택된 카테고리
  private let categories: [StatsCategoryModel]
  private let checkImage = UIImage(named: "check")?.withRenderingMode(.alwaysTemplate) // tintColor 적용을 위해 Template로 렌더링

  private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
    $0.backgroundColor = .appWhite
    $0.dataSource = self
    $0.delegate = self
    $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    $0.separatorStyle = .none
    $0.rowHeight = UITableView.automaticDimension
    $0.estimatedRowHeight = Layout.rowHeight
  }

  // MARK: - Init

  init(
    categories: [StatsCategoryModel],
    selectedCategory: StatsCategoryModel = .all,
    onSelect: @escaping (StatsCategoryModel) -> Void
  ) {
    // name 기준으로 중복 제거(순서 보존)
    var seen = Set<String>()
    let deduped: [StatsCategoryModel] = categories.filter { item in
      let inserted = seen.insert(item.name).inserted
      return inserted
    }

    // "전체" 항목은 항상 첫 번째에 위치
    var unique = deduped
    unique.removeAll(where: { $0.name == "전체" }) // 중복 방지
    unique.insert(.all, at: 0)

    self.categories = unique
    self.selectedCategory = selectedCategory
    self.onSelect = onSelect
    super.init(nibName: nil, bundle: nil)
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

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    configureSheet()
  }

  // MARK: - SetupUI

  private func configureUI() {
    view.backgroundColor = .appWhite
    view.addSubview(tableView)
  }

  private func configureLayout() {
    tableView.snp.makeConstraints {
      $0.edges.equalTo(view.safeAreaLayoutGuide).inset(UIEdgeInsets(top: Layout.sheetTopInset, left: 0, bottom: 0, right: 0))
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
      let totalHeight = contentHeight + Layout.sheetTopInset

      return min(max(totalHeight, Layout.minDetent), ctx.maximumDetentValue) // 시스템이 허용하는 최대 높이와 비교, 화면의 최대 높이를 넘어가지 않도록 조절
    }

    sheet.detents = [fit]
    sheet.prefersGrabberVisible = true
    sheet.preferredCornerRadius = Layout.sheetCornerRadius
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
      config.text = "\(icon)  " + "\(category.name)".limited(to: 15, addEllipsis: true)
    } else {
      config.text = category.name
    }

    config.attributedText = Typography.attributed(
      config.text ?? "",
      style: .bodyLg(weight: .medium),
      color: .gray900
    )
    config.directionalLayoutMargins = NSDirectionalEdgeInsets(
      top: Layout.cellVInset,
      leading: Layout.cellHInset,
      bottom: Layout.cellVInset,
      trailing: Layout.cellHInset
    )

    let imageView = UIImageView(image: checkImage)
    imageView.tintColor = .primary500

    cell.backgroundColor = .appWhite
    cell.contentConfiguration = config
    cell.accessoryView = (category == selectedCategory) ? imageView : .none
    cell.selectionStyle = .none
    return cell
  }
}
