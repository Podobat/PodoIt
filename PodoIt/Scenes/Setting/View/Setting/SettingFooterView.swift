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

  private let versionLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    configureLayout()
    appVersion()
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

  // MARK: - appVersion

  private func appVersion() {
    guard
      let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
      let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    else { return }

    #if DEBUG
      let text = "v\(version) (\(build))"
    #else
      let text = "v\(version)"
    #endif

    versionLabel.attributedText = Typography.attributed(
      text,
      style: .captionLg(weight: .regular),
      color: .gray400
    )
  }
}
