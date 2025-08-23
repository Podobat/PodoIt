//
//  SettingHeaderView.swift
//  PodoIt
//
//  Created by 서광용 on 8/22/25.
//

import SnapKit
import UIKit

final class SettingHeaderView: UITableViewHeaderFooterView {
  static let id = "SettingHeaderView"

  private let titleLabel = UILabel().then {
    $0.attributedText = Typography.attributed(
      "설정",
      style: .headingLg,
      color: .appBlack // 다크모드 분기로 .appWhite? 아니면 .label사용?
    )
  }

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    configureUI()
    configureLayout()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureUI() {
    contentView.addSubview(titleLabel)
  }

  private func configureLayout() {
    titleLabel.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(12)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
  }
}
