//
//  SettingHeaderView.swift
//  PodoIt
//
//  Created by 서광용 on 8/22/25.
//

import SnapKit
import UIKit

final class SettingHeaderView: UIView {
  private let titleLabel = UILabel.makeAttributed(text: "설정", style: .headingMd(weight: .bold), color: .appBlack)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    configureLayout()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(titleLabel)
  }
  
  private func configureLayout() {
    titleLabel.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(12)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
  }
}
