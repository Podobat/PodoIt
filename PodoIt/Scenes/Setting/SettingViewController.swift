//
//  SettingViewController.swift
//  PodoIt
//
//  Created by 노가현 on 8/20/25.
//

import SnapKit
import SwiftUI
import UIKit

final class SettingViewController: UIViewController {
  private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
    $0.dataSource = self
    $0.delegate = self
    $0.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    $0.separatorInset = .zero // 구분선의 시스템 마진을 zero로
    $0.alwaysBounceHorizontal = false
    $0.showsHorizontalScrollIndicator = false
    $0.isDirectionalLockEnabled = true
  }

  private let headerView = SettingHeaderView()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureLayout()
  }

  // 오토레이아웃 제약 조건 반영 후, frame 계산이 끝난 후에 호출
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateTableHeaderHeight()
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

  private func updateTableHeaderHeight() {
    // 헤더의 레이아웃을 기반으로 높이 계산 (UIView의 오토 레이아웃으로 적용)
    let size = headerView.systemLayoutSizeFitting(
      CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
    )
    headerView.frame.size.height = size.height

    tableView.tableHeaderView = headerView
  }
}

extension SettingViewController: UITableViewDelegate {}

extension SettingViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    3
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = "테스트"
    return cell
  }
}

#Preview {
  SettingViewController()
}
