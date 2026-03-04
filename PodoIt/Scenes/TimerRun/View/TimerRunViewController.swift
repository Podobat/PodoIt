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

  init(timer: TimerModel) {
    self.viewModel = TimerRunViewModel(timer: timer)
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Components

  private let headerSectionView = HeaderSectionView()
  private let animationSectionView = AnimationSectionView()
  private let timerSectionView = TimerSectionView()
  private let progressRestSectionView = ProgressRestSectionView()
  private let buttonSectionView = ButtonSectionView()

  private lazy var rootStack = UIStackView(arrangedSubviews: [
    headerSectionView, animationSectionView, timerSectionView, progressRestSectionView, buttonSectionView
  ]).then {
    $0.axis = .vertical
    $0.alignment = .fill
  }

  // MARK: - viewDidLoad

  override func viewDidLoad() {
    super.viewDidLoad()
    self.hidesBottomBarWhenPushed = true
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    configureUI()
    configureLayout()
    configureTimer()
    bind()
  }

  // MARK: - Data Loading

  private func configureTimer() {
    viewModel.loadUDSaved() // UD 데이터 불러오기 (없으면 내부 return)
    viewModel.setupTimer()
    configureAll(timer: viewModel.timer)
  }

  // MARK: - configureUI

  private func configureUI() {
    view.backgroundColor = .appWhite
    view.addSubview(rootStack)
  }

  // MARK: - configureLayout

  private func configureLayout() {
    rootStack.snp.makeConstraints {
      $0.directionalEdges.equalTo(view.safeAreaLayoutGuide)
    }

    buttonSectionView.snp.makeConstraints {
      $0.height.equalTo(100)
    }
  }

  // MARK: - Bindings

  /// Rx 바인딩 설정 (버튼 탭, 진행률 등)
  private func bind() {
    let addOne = progressRestSectionView.plusOneMinuteButtonTap.asSignal().map { RestAddCase.one }
    let addFive = progressRestSectionView.plusFiveMinuteButtonTap.asSignal().map { RestAddCase.five }
    let addTen = progressRestSectionView.plusTenMinuteButtonTap.asSignal().map { RestAddCase.ten }

    // 세 스트림을 하나로 합침
    let restAddSignal = Signal.merge(addOne, addFive, addTen)

    // restAddSignal이 "어떤 버튼이 눌렸는지"를 인식해서 값을 반환
    restAddSignal
      .withUnretained(self)
      .emit(onNext: { vc, addTime in
        vc.viewModel.addRestTime(seconds: addTime.seconds) // 반한된 값(60, 300, 600초)을 할당함
      })
      .disposed(by: disposeBag)

    // 버튼 Tap을 스트림으로 받아서 viewModel의 토글 실행 (start/pause)
    buttonSectionView.startPauseTap
      .asSignal()
      .throttle(.seconds(1)) // 1초 안에 여러번 눌러도 1번만 실행됨
      .emit(with: self) { vc, _ in
        vc.viewModel.startAndPause()
      }
      .disposed(by: disposeBag)

    // stop 버튼 tap하여 중지
    buttonSectionView.stopButtonTap
      .asSignal()
    // stopButtonTap 순간마다 viewModel.isOverOneMunute 최신값을 뽑아 emit으로 UI 바인딩
      .withLatestFrom(viewModel.isOverOneMinute.asObservable().asSignal(onErrorJustReturn: false))
      .emit(with: self) { vc, isOver in
        let type: PodoAlertController.StopAlertType = isOver ? .over1Min : .under1Min
        PodoAlertController
          .presentStopTimerAlert(from: vc, title: type.title, onConfirm: {
            vc.viewModel.stop()
            vc.navigationController?.popViewController(animated: true)
          })
      }
      .disposed(by: disposeBag)

    // muteButton tap하여 음소거 true/false
    headerSectionView.muteButtonTap
      .asSignal()
      .do(onNext: { [weak self] _ in
        self?.viewModel.toggleMute()
      })
      .withLatestFrom(viewModel.isMuteDriver.asObservable().asSignal(onErrorJustReturn: false))
      .emit(with: self) { vc, isMute in
        vc.showToastBelow(
          isMute ? "알림이 꺼졌어요." : "알림이 켜졌어요.",
          icon: UIImage(named: isMute ? "circle-bang" : "circle-check-green"),
          above: vc.animationSectionView
        )
      }
      .disposed(by: disposeBag)

    // progressBar 진행
    viewModel.progress
      .drive(with: self) { vc, progress in
        if progress >= 0.9999 { // 반올림 생각해서
          vc.progressRestSectionView.updateProgressBar(progress: 1.0)
        } else {
          vc.progressRestSectionView.progressBar.layoutIfNeeded() // 애니메이션 꼬임 방지용. 미리 레이아웃 최신상태로
          let animator = UIViewPropertyAnimator(duration: 1, curve: .linear) // 1초동안 선형으로 진행되는 animator 생성
          animator.addAnimations {
            vc.progressRestSectionView.progressBar.progress = progress // 매 틱 들어오는 진행률(progress) 값 바인딩
            vc.progressRestSectionView.progressBar.layoutIfNeeded() // progress 변경이 다음 runloop로 밀리지 않게해서 애니메이션 끊김을 방지
          }
          animator.startAnimation()
        }
      }
      .disposed(by: disposeBag)

    // isMute 상태값에 따른 아이콘 변경
    viewModel.isMuteDriver // 음소거(mute)의 Bool 상태
      .distinctUntilChanged()
      .drive(with: self) { vc, isMute in
        // 아이콘 초기값 바로 반영
        vc.headerSectionView.updateMuteIcon(isMute: isMute)
      }
      .disposed(by: disposeBag)

    // 공부/휴식 상태에 따라서 목표시간 또는 휴식시간 UI를 업데이트
    // combineLatest: 여러개의 Driver 스트림을 합쳐서 하나로 만들어줌
    Driver.combineLatest(
      viewModel.isStudyingDriver, // 공부/휴식 중 상태 (Bool)
      viewModel.goalTimeText, // 공부 목표시간 (MM:SS)
      viewModel.studyingTimeText, // 공부중인 시간 (H:MM:SS)
      viewModel.totalRestTimeText, // 총 "휴식 중인 시간" (MM:SS)
      viewModel.restingTimeText // "남은 휴식시간" (기본 5분. MM:SS)
    )
    .drive(with: self) { vc, data in
      let (isStudying, goalTime, studyingTime, totalRestTime, restingTime) = data
      // 공부/휴식 중 상태에 따른 버튼 UI 업데이트
      vc.buttonSectionView.updateStartPauseButtonImage(isStudying: isStudying)
      vc.progressRestSectionView.updateIsHiddenView(isStudying: isStudying)
      vc.animationSectionView.updateAnimationsIsHidden(isStudying: isStudying)

      if isStudying { // 공부중
        vc.timerSectionView.updateGoalTimeUI(goalTime: goalTime, studyingTime: studyingTime)
      } else { // 휴식중
        vc.timerSectionView.updateRestTimeUI(totalRestTime: totalRestTime, restingTime: restingTime)
      }
    }
    .disposed(by: disposeBag)
  }

  // MARK: UI Configuration

  private func configureAll(timer: TimerModel) {
    headerSectionView.configure(model: timer)
  }

  deinit {
#if DEBUG
    print(" ---> [Deinit 확인!] 구독해제!")
#endif
  }
}
