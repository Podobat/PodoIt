//
//  TimerRunViewController.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class TimerRunViewController: UIViewController {
  // MARK: - viewModel & disposeBag

  private let viewModel: TimerRunViewModel
  private let disposeBag = DisposeBag()

  // MARK: - init

  init(timerID: UUID, repo: TimerRepository) {
    // UUID를 받아올 때마다 새로운 VM을 생성
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

  // MARK: - viewDidLoad

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .appWhite
    configureUI()
    configureLayout()
    loadData()
    bind()
  }

  // MARK: - Data Loading

  private func loadData() {
    do {
      try viewModel.load()
      if let timer = viewModel.timer {
        configureAll(timer: timer)
      }
    } catch {
      print("타이머 데이터 로딩 실패: \(error)")
    }
  }

  // MARK: - configureUI

  private func configureUI() {
    view.addSubview(rootStack)
  }

  // MARK: - configureLayout

  private func configureLayout() {
    rootStack.snp.makeConstraints {
      $0.directionalEdges.equalTo(view.safeAreaLayoutGuide)
    }
  }

  // MARK: - Bindings

  /// Rx 바인딩 설정 (버튼 탭, 진행률 등)
  private func bind() {
    // 버튼 Tap을 스트림으로 받아서 viewModel의 토글 실행 (start/pause)
    buttonBarView.startPauseTap
      .asDriver()
      .drive(with: self) { vc, _ in
        vc.viewModel.startAndPause()
      }
      .disposed(by: disposeBag)

    // stop 버튼 tap하여 중지
    buttonBarView.stopButtonTap
      .asDriver()
      .drive(with: self) { vc, _ in
        vc.viewModel.stop()
        vc.navigationController?.popViewController(animated: true) // pop되면서 interval도 중지
      }
      .disposed(by: disposeBag)

    let activeTimerText: Driver<String> = viewModel.isRunningDriver
      .flatMapLatest { [weak self] isRunning in // 중첩을 펴서 최신의 Driver만 유지
        guard let self else { return Driver.just("00:00") }
        // 공부중이면 공부 시간 타이머, 휴식중이면 휴식 시간 타이머를 실행
        return isRunning ? self.viewModel.runningTimeText : self.viewModel.restTimeText
      }

    activeTimerText // 총 공부 진행시간 / 휴식 진행 시간 Text
      .asObservable() // .take(until:)가 Observable 연산자라서 변경
      .take(until: rx.methodInvoked(#selector(UIViewController.viewWillDisappear(_:))))
      .asDriver(onErrorJustReturn: "00:00")
      .drive(timerView.activeTimerLabel.rx.text)
      .disposed(by: disposeBag)

    // progressBar 진행
    viewModel.progress
      .asObservable()
      .take(until: rx.methodInvoked(#selector(UIViewController.viewWillDisappear(_:))))
      .asDriver(onErrorJustReturn: 0.0)
      .drive(with: self) { vc, progress in
        if progress >= 0.9999 { // 반올림 생각해서
          vc.middleView.updateProgressBar(progress: 1.0)
        } else {
          vc.middleView.progressBar.layoutIfNeeded() // 애니메이션 꼬임 방지용. 미리 레이아웃 최신상태로
          let animator = UIViewPropertyAnimator(duration: 1, curve: .linear) // 선형으로 1초마다 애니메이션 객체 생성
          animator.addAnimations {
            vc.middleView.progressBar.progress = progress // 매 틱 들어오는 진행률(progress) 값 바인딩
            vc.middleView.progressBar.layoutIfNeeded() // 안하면 툭툭 끊김
          }
          animator.startAnimation()
        }
      }
      .disposed(by: disposeBag)

    // 공부 중/휴식 중 상태에 따른 버튼 이미지, 색상 변경
    viewModel.isRunningDriver
      .drive(with: self) { vc, isRunning in
        // 공부 중/휴식 중 상태에 따른 버튼 이미지, 색상 변경
        vc.buttonBarView.updateStartPauseButtonImage(isRunning: isRunning)
      }
      .disposed(by: disposeBag)

    // 공부 목표시간을 Label에 바인딩 및 목표시간 달성 시 UI update
    viewModel.goalTimeText
      .asObservable()
      .take(until: rx.methodInvoked(#selector(UIViewController.viewWillDisappear(_:))))
      .asDriver(onErrorJustReturn: "00:00")
      .drive(with: self) { vc, goalTime in
        vc.timerView.updateGoalTime(goalTime: goalTime)
      }
      .disposed(by: disposeBag)
  }

  // MARK: UI Configuration

  private func configureAll(timer: TimerModel) {
    headerView.configure(model: timer)
  }

  deinit {
    print(" ---> [Deinit 확인!] 구독해제!")
  }
}
