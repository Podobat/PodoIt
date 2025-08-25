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

  private let saveButton = UIButton(type: .system).then {
    $0.setTitle("저장하기", for: .normal)
    $0.setTitleColor(.appWhite, for: .normal)
    $0.titleLabel?.font = Typography.font(for: .labelLg(weight: .semibold))
    $0.backgroundColor = .primary600
    $0.layer.cornerRadius = 12
    $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
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
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    configureSheet()
  }

  private func configureUI() {
    view.backgroundColor = .appWhite
    [titleLabel, tableView, saveButton].forEach { view.addSubview($0) }
  }

  private func configureLayout() {
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(37) // grabber + padding
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
    }

    tableView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(16)
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(CGFloat(Theme.allCases.count) * 56) // 셀 3개 → 168
    }

    saveButton.snp.makeConstraints {
      $0.top.equalTo(tableView.snp.bottom).offset(20)
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
      $0.height.equalTo(48)
    }
  }
  
  // MARK: - configureSheet

  private func configureSheet() {
    guard let sheet = sheetPresentationController else { return }
    let fit = UISheetPresentationController.Detent.custom(identifier: .init("fit")) { [weak self] ctx in
      guard let self = self else { return 300 }
      // 최소 높이 계산 전 최신의 레이아웃을 반영
      self.view.layoutIfNeeded()
      // 현재 레이아웃이 필요로 하는 최소 높이 계산
      let needed = self.view.systemLayoutSizeFitting(
        CGSize(width: self.view.bounds.width, height: .greatestFiniteMagnitude),
        withHorizontalFittingPriority: .required,  // 가로는 반드시 이 폭을 지킴.
        verticalFittingPriority: .fittingSizeLevel // 세로는 제약을 만족하는 '최소'높이를 맞춤
      ).height // '세로 길이'만 사용

      let bottom = self.view.safeAreaInsets.bottom // VC 하단 세이프 에어리어 값
      return min(max(needed - bottom, 240), ctx.maximumDetentValue) // 최대 높이랑 비교하여, 화면의 최대 높이를 넘어가지 않도록 조절
    }

    sheet.detents = [fit]
    sheet.prefersGrabberVisible = true // gabber 모습 보임
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
    cell.tintColor = .primary500
    cell.selectionStyle = .none
    return cell
  }
}
