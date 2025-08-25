//
//  StatsViewController.swift
//  PodoIt
//
//  Created by 노가현 on 8/20/25.
//

import UIKit

final class StatsViewController: UIViewController {
  // MARK: - Properties

  private let headerView = StatsHeaderView()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }

  // MARK: - Private Methods

  private func configureUI() {
    view.backgroundColor = .appWhite
    navigationController?.setNavigationBarHidden(true, animated: false)
    setupViews()
    setupConstraints()
  }

  private func setupViews() {
    [headerView].forEach { view.addSubview($0) }
  }

  private func setupConstraints() {
    headerView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.leading.trailing.equalToSuperview()
    }
  }
}
