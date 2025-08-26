//
//  SettingViewController.swift
//  PodoIt
//
//  Created by 노가현 on 8/20/25.
//

import SnapKit
import UIKit

final class SettingViewController: UIViewController {
  private let viewModel = SettingViewModel()

  private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
    $0.backgroundColor = .appWhite
    $0.dataSource = self
    $0.delegate = self
    $0.register(SettingViewCell.self, forCellReuseIdentifier: SettingViewCell.id)
    $0.separatorInset = .zero // 구분선의 시스템 마진을 zero로
    $0.showsHorizontalScrollIndicator = false
    $0.isDirectionalLockEnabled = true
    $0.rowHeight = UITableView.automaticDimension
    $0.estimatedRowHeight = 56 // 예상 높이값
  }

  private let headerView = SettingHeaderView()
  private let footerView = SettingFooterView()
  private var didSetHeaderFooter = false

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureLayout()
  }

  // 오토레이아웃 제약 조건 반영 후, frame 계산이 끝난 후에 호출
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard !didSetHeaderFooter else { return }
    updateTableHeaderFooterHeight(headerView, assign: { tableView.tableHeaderView = $0 })
    updateTableHeaderFooterHeight(footerView, assign: { tableView.tableFooterView = $0 })
    didSetHeaderFooter = true
  }

  // MARK: - Private Methods

  private func configureUI() {
    self.navigationController?.isNavigationBarHidden = true
    view.backgroundColor = .appWhite
    view.addSubview(tableView)
  }

  private func configureLayout() {
    tableView.snp.makeConstraints {
      $0.directionalEdges.equalTo(view.safeAreaLayoutGuide)
    }
  }

  // MARK: - updateTableHeaderFooterHeight

  // header,footer 의 레이아웃을 기반으로 높이 계산 (UIView의 오토 레이아웃으로 적용)
  // 중복 코드가 많아서 하나로 사용
  private func updateTableHeaderFooterHeight(_ view: UIView, assign: (UIView) -> Void) {
    let size = view.systemLayoutSizeFitting(
      CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
    )
    view.frame.size.height = size.height
    assign(view)
  }
}

extension SettingViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = viewModel.items[indexPath.row]
    switch item {
    case .theme(let current):
      let sheetVC = ThemeSheetViewController(onSelect: { _ in /* 나중에 */ }, selectedTheme: current)
      sheetVC.modalPresentationStyle = .pageSheet
      present(sheetVC, animated: true)
    default: break
    }
  }
}

extension SettingViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingViewCell.id, for: indexPath) as? SettingViewCell else { return UITableViewCell() }
    let item = viewModel.items[indexPath.row]
    cell.configure(item)
    return cell
  }
}
