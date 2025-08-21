//
//  TimerViewController.swift
//  PodoIt
//
//  Created by 노가현 on 8/20/25.
//

import SnapKit
import Then
import UIKit

final class TimerViewController: UIViewController {
  private let testLabel = UILabel().then {
    $0.text = "테스트 문장입니다."
    $0.attributedText = Typography.attributed(
      "테스트 문장입니다.",
      style: .title1,
      color: Palette.Violet.v500
    )
    $0.textAlignment = .center
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }

  // MARK: - Private Methods

  private func configureUI() {
    view.backgroundColor = .systemBackground
    title = "타이머"
    view.addSubview(testLabel)

    testLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
}
