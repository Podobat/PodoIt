//
//  ThemeSheetViewController.swift
//  PodoIt
//
//  Created by 서광용 on 8/25/25.
//

import SnapKit
import UIKit

final class ThemeSheetViewController: UIViewController {
  
  private enum Layout {
    static let titleTop: CGFloat = 37 // grabber + padding
    
    static let sideInset: CGFloat = 20
    static let vSpacingSmall: CGFloat = 16
    static let vSpacing: CGFloat = 20
    
    static let rowHeight: CGFloat = 56
    static let buttonHeight: CGFloat = 48
    
    static let buttonCornerRadius: CGFloat = 12
    static let sheetCornerRadius: CGFloat = 16
    
    static let buttonContentV: CGFloat = 12
    static let buttonContentH: CGFloat = 16
    
    static let cellVInset: CGFloat = 16
    static let cellHInset: CGFloat = 20
    
    static let minDetent: CGFloat = 240 // 시트 최소 높이
  }
  
  private let onSelect: (Theme) -> Void // 선택 결과 전달
  private var selectedTheme: Theme // 현재 선택된 테마
  private let checkImage = UIImage(named: "check")?.withRenderingMode(.alwaysTemplate) // tintColor 적용을 위해 Template로 렌더링
  
  private let titleLabel = UILabel.makeAttributed(
    text: "테마 변경",
    style: .headingLg,
    color: .appBlack,
    alignment: .center
  )

  private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
    $0.backgroundColor = .appWhite
    $0.dataSource = self
    $0.delegate = self
    $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    $0.isScrollEnabled = false // 스크롤 방지
    $0.separatorStyle = .none
    $0.rowHeight = UITableView.automaticDimension
    $0.estimatedRowHeight = Layout.rowHeight
  }

  private lazy var saveButton = UIButton(type: .system).then {
    $0.setTitle("저장하기", for: .normal)
    $0.setTitleColor(.appWhite, for: .normal)
    $0.titleLabel?.font = Typography.font(for: .labelLg(weight: .semibold))
    $0.backgroundColor = .primary600
    $0.layer.cornerRadius = 12
    $0.contentEdgeInsets = UIEdgeInsets(
      top: Layout.buttonContentV,
      left: Layout.buttonContentH,
      bottom: Layout.buttonContentV,
      right: Layout.buttonContentH
    ) // 버튼 내부와 경계 사이 여백
    $0.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
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
    configureSheet() // 레이아웃 계산이 끝난 후, 실제 뷰 크기에 맞춰서 높이 설정
  }

  private func configureUI() {
    view.backgroundColor = .appWhite
    [titleLabel, tableView, saveButton].forEach { view.addSubview($0) }
  }

  private func configureLayout() {
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Layout.titleTop)
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Layout.sideInset)
    }

    tableView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(Layout.vSpacingSmall)
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(CGFloat(Theme.allCases.count) * Layout.rowHeight) // 셀 3개 → 168
    }

    saveButton.snp.makeConstraints {
      $0.top.equalTo(tableView.snp.bottom).offset(Layout.vSpacing)
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Layout.sideInset)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Layout.sideInset)
      $0.height.equalTo(Layout.buttonHeight)
    }
  }
  
  // MARK: - configureSheet

  private func configureSheet() {
    guard let sheet = sheetPresentationController else { return }
    let fit = UISheetPresentationController.Detent.custom(identifier: .init("fit")) { [weak self] ctx in // Detent가 멈추는 높이
      guard let self = self else { return 300 }
      // 최소 높이 계산 전 최신의 레이아웃을 반영
      self.view.layoutIfNeeded()
      // 현재 레이아웃이 필요로 하는 최소 높이 계산
      let needed = self.view.systemLayoutSizeFitting(
        CGSize(width: self.view.bounds.width, height: .greatestFiniteMagnitude), // 세로 입력 상한 없애고, "내용에 맞게" 최소 높이를 구함
        withHorizontalFittingPriority: .required,  // 가로는 반드시 이 폭을 지킴.
        verticalFittingPriority: .fittingSizeLevel // 세로는 제약을 만족하는 '최소'높이를 찾음
      ).height // '세로 길이'만 사용

      // 홈 인디게이터 때문에 추가로 나오는 하단 safe area만큼을 구함.
      // needed가 겹쳐서 계산될 수 있기에, 그만큼을 빼줌
      let bottom = self.view.safeAreaInsets.bottom
      return min(max(needed - bottom, Layout.minDetent), ctx.maximumDetentValue) // 시스템이 허용하는 최대 높이와 비교, 화면의 최대 높이를 넘어가지 않도록 조절
    }

    sheet.detents = [fit] // fit 하나의 detents 단계만 가짐. (.large 등이 있지만, 하나만 지원)
    sheet.prefersGrabberVisible = true // gabber(표시 막대) 모습 보임
    sheet.preferredCornerRadius = Layout.sheetCornerRadius
  }
  
  @objc private func saveButtonTapped() {
    onSelect(selectedTheme)
    dismiss(animated: true)
  }
}

extension ThemeSheetViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let oldIndex = Theme.allCases.firstIndex(of: selectedTheme) else { return } // selectedTheme과 같은 값이 몇 번째 인덱스인지
    let newIndex = indexPath.row // 내가 현재 누른 인덱스 위치
    if oldIndex == newIndex { return } // 동일 항목을 누른다면 무시
    selectedTheme = Theme.allCases[newIndex] // 새로운 Theme 값으로 매칭
    // 변경된 부분들만 셀 리로드
    tableView.reloadRows(at: [
        IndexPath(row: oldIndex, section: 0),
        IndexPath(row: newIndex, section: 0)
    ],with: .none
    )
  }
}

extension ThemeSheetViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Theme.allCases.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let theme = Theme.allCases[indexPath.row]
    var config = cell.defaultContentConfiguration()
    config.attributedText = Typography.attributed(theme.displayName, style: .bodyLg(weight: .medium), color: .gray900)
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
    cell.accessoryView = (theme == selectedTheme) ? imageView : .none
    cell.selectionStyle = .none
    return cell
  }
}
