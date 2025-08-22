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
  private let paddedContainer = PaddedContainerView()

  private let testLabel = UILabel().then {
    $0.text = "테스트 문장입니다."
    $0.attributedText = Typography.attributed(
      "테스트 문장입니다.",
      style: .displayMd(weight: .bold),
      color: Palette.Primary.p500
    )
    $0.textAlignment = .center
    $0.numberOfLines = 0
    $0.backgroundColor = Palette.Primary.p100
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
    view.addSubview(paddedContainer)

    paddedContainer.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(80)
    }

    paddedContainer.contentView.addSubview(testLabel)
    testLabel.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}
