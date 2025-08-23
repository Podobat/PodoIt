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
    $0.register(SettingHeaderView.self, forHeaderFooterViewReuseIdentifier: SettingHeaderView.id)
    $0.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    $0.separatorInset = .zero // 구분선의 시스템 마진을 zero로
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureLayout()
  }

  // MARK: - Private Methods

  private func configureUI() {
    view.backgroundColor = .systemBackground
    view.addSubview(tableView)
  }

  private func configureLayout() {
    tableView.snp.makeConstraints {
      $0.directionalEdges.equalTo(view.safeAreaLayoutGuide)
    }
  }
}

extension SettingViewController: UITableViewDelegate {
  // 섹션 헤더에 커스텀 뷰 보여줌
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingHeaderView.id) as? SettingHeaderView else { return UIView() }
    return header
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return UITableView.automaticDimension
  }
}

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
