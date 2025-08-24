//
//  SettingViewController.swift
//  PodoIt
//
//  Created by 노가현 on 8/20/25.
//

import SnapKit
import UIKit

final class SettingViewController: UIViewController {
  private let items: [SettingItem] = [.notification(isOn: false), .theme(current: .system), .inquiry, .review]

  private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
    $0.dataSource = self
    $0.delegate = self
    $0.register(SettingViewCell.self, forCellReuseIdentifier: SettingViewCell.id)
    $0.separatorInset = .zero // 구분선의 시스템 마진을 zero로
    $0.alwaysBounceHorizontal = false
    $0.showsHorizontalScrollIndicator = false
    $0.isDirectionalLockEnabled = true
  }

  private let headerView = SettingHeaderView()
  private let footerView = SettingFooterView()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureLayout()
  }

  // 오토레이아웃 제약 조건 반영 후, frame 계산이 끝난 후에 호출
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateTableHeaderFooterHeight(headerView, assign: { tableView.tableHeaderView = $0 })
    updateTableHeaderFooterHeight(footerView, assign: { tableView.tableFooterView = $0 })
  }

  // MARK: - Private Methods

  private func configureUI() {
    self.navigationController?.isNavigationBarHidden = true
    view.backgroundColor = .systemBackground
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

extension SettingViewController: UITableViewDelegate {}

extension SettingViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingViewCell.id, for: indexPath) as? SettingViewCell else { return UITableViewCell() }
    let item = items[indexPath.row]
    cell.configure(item)
    return cell
  }
}
