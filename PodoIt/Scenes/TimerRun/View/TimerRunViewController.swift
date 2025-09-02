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
      .withUnretained(self)
      .bind(onNext: { vc, _ in
        vc.viewModel.startAndPause()
      })
      .disposed(by: disposeBag)

    // stop 버튼 tap하여 중지
    buttonBarView.stopButtonTap
      .withUnretained(self)
      .bind(onNext: { vc, _ in
        vc.viewModel.stop()
        vc.navigationController?.popViewController(animated: true) // pop되면서 interval도 중지
      })
      .disposed(by: disposeBag)

    // 총 공부시간 "0:00:00" 진행
    viewModel.runningTimeText
      .asObservable() // .take(until:)가 Observable 연산자라서 변경
      // .take(until:): 원본 스트림을 유지하다가, 어떤 신호가 오면 즉시 "complete(종료)"시킴.
      // viewWillDisappear가 불릴 때 이벤트 방출. 신호받고 complete -> 구독이 dispose -> interval 스케줄링도 멈춤
      // 당장은 pop이라 없어도 문제 없겠지만, push하거나 modal 등으로 바뀔 수 있으니 유지.
      .take(until: rx.methodInvoked(#selector(UIViewController.viewWillDisappear(_:))))
      .asDriver(onErrorJustReturn: "0:00:00")
      .drive(timerView.runningTimeLabel.rx.text)
      .disposed(by: disposeBag)

    // progressBar 진행
    viewModel.progress
      .asObservable()
      .take(until: rx.methodInvoked(#selector(UIViewController.viewWillDisappear(_:))))
      .asDriver(onErrorJustReturn: 0.0)
      .drive(onNext: { [middleView] progress in
        if progress >= 0.9999 { // 반올림 생각해서
          middleView.updateProgressBar(progress: 1.0)
        } else {
          middleView.progressBar.layoutIfNeeded() // 애니메이션 꼬임 방지용. 미리 레이아웃 최신상태로
          let animator = UIViewPropertyAnimator(duration: 1, curve: .linear) // 선형으로 1초마다 애니메이션 객체 생성
          animator.addAnimations {
            middleView.progressBar.progress = progress // 매 틱 들어오는 진행률(progress) 값 바인딩
            middleView.progressBar.layoutIfNeeded() // 안하면 툭툭 끊김
          }
          animator.startAnimation()
        }
      })
      .disposed(by: disposeBag)

    viewModel.isRunningDriver
      .drive(with: self) { vc, isRunning in
        // 공부 중/휴식 중 상태에 따른 버튼 이미지, 색상 변경
        vc.buttonBarView.updateStateStartPauseButtonImage(isRunning: isRunning)
      }
      .disposed(by: disposeBag)

    viewModel.goalTimeText
      .asObservable()
      .take(until: rx.methodInvoked(#selector(UIViewController.viewWillDisappear(_:))))
      .asDriver(onErrorJustReturn: "00:00")
      .drive(timerView.goalTimeLabel.rx.text)
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
