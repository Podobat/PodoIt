//
//  SettingFooterView.swift
//  PodoIt
//
//  Created by 서광용 on 8/23/25.
//

import SnapKit
import UIKit

final class SettingFooterView: UIView {
  private enum Layout {
    static let horizontalPadding: CGFloat = 20
    static let verticalPadding: CGFloat = 16
  }

  private let versionLabel = UILabel.makeAttributed(
    text: "ver.1.0.0",
    style: .captionLg(weight: .regular),
    color: .gray400
  )

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
    addSubview(versionLabel)
  }

  private func configureLayout() {
    versionLabel.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(Layout.verticalPadding)
      $0.leading.trailing.equalToSuperview().inset(Layout.horizontalPadding)
    }
  }
}
