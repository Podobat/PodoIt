//
//  TimerRunViewController.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import RxSwift
import SnapKit
import Then
import UIKit

final class TimerRunViewController: UIViewController {
  private let viewModel: TimerRunViewModel
  private let disposeBag = DisposeBag()

  init(timerID: UUID, repo: TimerRepository) {
    self.viewModel = TimerRunViewModel(timerID: timerID, repo: repo)
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Components

  private let headerView = HeaderSectionView()
  private let animationView = AnimationSectionView()
  private let timerView = TimerSectionView()
  private let middleView = MiddleSectionView()
  private let buttonBarView = ButtonSectionView()

  private lazy var rootStack = UIStackView(arrangedSubviews: [
    headerView, animationView, timerView, middleView, buttonBarView
  ]).then {
    $0.axis = .vertical
    $0.alignment = .fill
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .appWhite
    configureUI()
    configureLayout()
    bind()
  }

  private func configureUI() {
    view.addSubview(rootStack)
  }

  private func configureLayout() {
    rootStack.snp.makeConstraints {
      $0.directionalEdges.equalTo(view.safeAreaLayoutGuide)
    }
  }

  private func bind() {
    // 버튼 Tap을 스트림으로 받아서 viewModel의 토글 실행 (start/pause)
    buttonBarView.startPauseTap
      .withUnretained(self)
      .bind(onNext: { vc, _ in
        vc.viewModel.startAndPause()
      })
      .disposed(by: disposeBag)

    // 여기서 ViewModel의 text 구독
    // .drive로 받아서, 타이머 섹션의 텍스트에다가 바인딩.
    // 디스포즈백!
  }
}
