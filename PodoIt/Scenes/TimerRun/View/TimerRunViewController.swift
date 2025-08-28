//
//  TimerRunViewController.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import UIKit

final class TimerRunViewController: UIViewController {
  private let viewModel: TimerRunViewModel

  init(timerID: UUID, repo: TimerRepository) {
    self.viewModel = TimerRunViewModel(timerID: timerID, repo: repo)
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .purple
    do {
      try viewModel.load()
      if let timer = viewModel.timer {
        print(timer.timerID)
        print(timer.title)
        print(timer.iconName)
        print(timer.goalTime)
      }
    } catch {
      print("실패: \(error.localizedDescription)")
    }
  }
}
