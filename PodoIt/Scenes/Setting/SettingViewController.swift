//
//  SettingViewController.swift
//  PodoIt
//
//  Created by 노가현 on 8/20/25.
//

import UIKit

final class SettingViewController: UIViewController {
  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }

  // MARK: - Private Methods

  private func configureUI() {
    view.backgroundColor = .systemBackground
    title = "설정"
  }
}
