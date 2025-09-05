//
//  SettingViewController.swift
//  PodoIt
//
//  Created by 노가현 on 8/20/25.
//

import SafariServices
import SnapKit
import UIKit

final class SettingViewController: UIViewController {
  private let viewModel = SettingViewModel()
  private let myAppID = 6752013483

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
      let sheetVC = ThemeSheetViewController(onSelect: { [weak self] newTheme in
        guard let self else { return }
        // ViewModel에서 상태 업데이트 및 UserDefaults에 값 저장
        self.viewModel.applyTheme(newTheme)
        if let row = self.viewModel.items.firstIndex(where: { // 조건에 만족하는 첫 번째 인덱스를 찾음
          if case .theme = $0 { return true } else { return false } // items 배열원소가 .theme 케이스면 true
        }) { // UI 갱신. Theme 셀만 리로드 (혹여나 백업으로 reloadData)
          self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
        } else {
          self.tableView.reloadData()
        }
      }, selectedTheme: current)
      sheetVC.modalPresentationStyle = .pageSheet
      present(sheetVC, animated: true)
    case .inquiry:
      guard let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSc7ek143AR7jBzxrNdbQsHJso4Nv4n_41v0ExHlXwsOHi6gfQ/viewform?usp=header") else { return }
      let safariViewController = SFSafariViewController(url: url)
      present(safariViewController, animated: true, completion: nil)
    case .review:
      guard
        let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id\(myAppID)"), // App Store 앱 직행
        let webURL = URL(string: "https://apps.apple.com/app/id\(self.myAppID)") // 웹으로 이동(Safari 백업용)
      else { return }

      // 먼저 App Store 시도 → 실패하면 Safari로 연결
      UIApplication.shared.open(appStoreURL, options: [:]) { success in
        if !success {
          UIApplication.shared.open(webURL)
        }
      }
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
