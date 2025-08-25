//
//  ThemeSheetViewController.swift
//  PodoIt
//
//  Created by 서광용 on 8/25/25.
//

import SnapKit
import UIKit

final class ThemeSheetViewController: UIViewController {
  private let onSelect: (Theme) -> Void // 선택 결과 전달
  private var selectedTheme: Theme // 현재 선택된 테마

  private let titleLabel = UILabel.makeAttributed(
    text: "테마 변경",
    style: .headingLg,
    color: .appBlack,
    alignment: .center
  )

  private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
    $0.dataSource = self
    $0.delegate = self
    $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    $0.isScrollEnabled = false
    $0.separatorStyle = .none
    $0.rowHeight = UITableView.automaticDimension
    $0.estimatedRowHeight = 56
  }

  init(onSelect: @escaping (Theme) -> Void, selectedTheme: Theme) {
    self.onSelect = onSelect
    self.selectedTheme = selectedTheme
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureLayout()
    configureSheet()
  }

  private func configureUI() {
    view.backgroundColor = .appWhite
    [titleLabel, tableView].forEach { view.addSubview($0) }
  }

  private func configureLayout() {
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(37) // grabber + padding
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
    }

    tableView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(16)
      $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }

  // MARK: - configureSheet

  private func configureSheet() {
    guard let sheet = sheetPresentationController else { return }

    // iOS 16+ 커스텀 detent: 처음 높이를 337pt로
    let fixed337 = UISheetPresentationController.Detent.custom(identifier: .init("fixed337")) { content in
      // large 보다 클 수 없으니 캡핑
      min(337, content.maximumDetentValue)
    }

    sheet.detents = [fixed337, .large()] // 시작은 337, 올리면 large
    sheet.selectedDetentIdentifier = .init("fixed337") // 처음 나타날 때 337pt 높이
    sheet.prefersGrabberVisible = true // 위 아래로 잡아당기는 grabber(작은 막대) 표시
    sheet.preferredCornerRadius = 16
  }
}

extension ThemeSheetViewController: UITableViewDelegate {}

extension ThemeSheetViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Theme.allCases.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let theme = Theme.allCases[indexPath.row]
    var config = UIListContentConfiguration.valueCell()
    config.attributedText = Typography.attributed(theme.displayName, style: .bodyLg(weight: .medium), color: .gray900)
    config.directionalLayoutMargins = NSDirectionalEdgeInsets(
      top: 16,
      leading: 20,
      bottom: 16,
      trailing: 20
    )

    cell.contentConfiguration = config
    cell.accessoryType = (theme == selectedTheme) ? .checkmark : .none
    return cell
  }
}
