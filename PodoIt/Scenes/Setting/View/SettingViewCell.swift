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
    // 셀은 재사용되니 문제 생기지 않도록 초기화
    selectionStyle = .none // 셀 선택 하이라이트 안보이도록
    accessoryType = .none
    accessoryView = nil
    
    switch item.accessory {
    case .toggle(let isOn):
      let toggleSwitch = UISwitch()
      toggleSwitch.isOn = isOn
      toggleSwitch.onTintColor = .primary600
      accessoryView = toggleSwitch
    case .value(let theme):
      let valueLabel = UILabel.makeAttributed(
        text: theme.displayName,
        style: .labelMd(weight: .medium),
        color: .gray500,
        alignment: .right
      )
      valueLabel.sizeToFit() // 라벨 크기를 텍스트 내용에 맞도록
      accessoryView = valueLabel
    case .disclosure:
      accessoryType = .disclosureIndicator // 시스템에서 제공하는 ">" 표시
      accessoryView = nil
    }
  }
}
