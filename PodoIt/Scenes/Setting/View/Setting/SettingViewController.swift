//
//  SettingViewController.swift
//  PodoIt
//
//  Created by 노가현 on 8/20/25.
//

import RxCocoa
import RxSwift
import SafariServices
import SnapKit
import UIKit

final class SettingViewController: UIViewController {
  private let viewModel = SettingViewModel()
  private let appID = 6752013483
  private let disposeBag = DisposeBag()

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
    bind()
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

  // MARK: - Rx

  private func bind() {
    viewModel.isMuteDriver
      .drive(with: self) { vc, isMute in
        let isOn = !isMute

        // notification 셀을 찾아서 row에 담기
        if let row = vc.viewModel.items.firstIndex(where: {
          if case .notification = $0 { return true } else { return false } // 찾으면 true
        }) {
          let indexPath = IndexPath(row: row, section: 0)
          if let cell = vc.tableView.cellForRow(at: indexPath) as? SettingViewCell {
            cell.toggleSwitch.isOn = isOn // .notifictaion의 toggleSwitch안에 isOn값을 최신화
          }
          // viewModel도 isOn값 최신화
          vc.viewModel.items[row] = .notification(isOn: isOn)
        }
      }
      .disposed(by: disposeBag)
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
    case .feedback:
      guard let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSc7ek143AR7jBzxrNdbQsHJso4Nv4n_41v0ExHlXwsOHi6gfQ/viewform?usp=header") else { return }
      let safariViewController = SFSafariViewController(url: url)
      present(safariViewController, animated: true, completion: nil)
    case .review:
      guard
        let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)"), // App Store 앱 직행
        let webURL = URL(string: "https://apps.apple.com/app/id\(self.appID)") // 웹으로 이동(Safari 백업용)
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

    switch item {
    case .notification:
      cell.toggleSwitch.rx.isOn // ControlProperty<Bool> 타입: 값 + 변경 이벤트를 모두 가짐
        // 코드로 isOn을 세팅할 떄 발생하는 이벤트는 무시하고,
        // 사용자가 직접 토글한 경우만 받고 싶어서 .changed로 "값이 실제로 변경" 되었을 때만 필터링
        // ControlProperty<Bool> -> ControlEvent<Bool>로 타입이 변경됨
        .changed
        // 셀이 재상요되기 직전(prepareForReuse)까지만 이벤트를 받고,
        // 이후에는 자동으로 구독을 해제해서 중복 바인딩 방지
        // 즉, 이 셀 인스턴스가 재사용 되기 직전까지만 토글 이벤트를 받는다는 의미.
        .take(until: cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse)))
        .bind(with: self) { vc, isOn in
          vc.viewModel.updateIsMute(isOn: isOn)
        }
        .disposed(by: disposeBag)
    default:
      break
    }

    return cell
  }
}
