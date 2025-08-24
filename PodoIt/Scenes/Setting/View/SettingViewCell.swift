//
//  SettingViewCell.swift
//  PodoIt
//
//  Created by 서광용 on 8/24/25.
//

import SnapKit
import UIKit

final class SettingViewCell: UITableViewCell {
  static let id = "SettingViewCell"
  
  private let itemLabel = UILabel()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
    configureLayout()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.addSubview(itemLabel)
  }
  
  private func configureLayout() {
    itemLabel.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(16)
      $0.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  func configure(_ item: SettingItem) {
    itemLabel.attributedText = Typography.attributed(item.title, style: .headingMd, color: .gray800)
  }
}
