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

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .appWhite
    configureUI()
    configureLayout()
    loadData()
    bind()
  }

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

    buttonBarView.stopButtonTap
      .withUnretained(self)
      .bind(onNext: { vc, _ in
        vc.viewModel.stop()
        vc.navigationController?.popViewController(animated: true) // pop되면서 interval도 중지
      })
      .disposed(by: disposeBag)

    viewModel.runningTimeText
      .asObservable() // .take(until:)가 Observable 연산자라서 변경
      // .take(until:): 원본 스트림을 유지하다가, 어떤 신호가 오면 즉시 "complete(종료)"시킴.
      // viewWillDisappear가 불릴 때 이벤트 방출. 신호받고 complete -> 구독이 dispose -> interval 스케줄링도 멈춤
      // 당장은 pop이라 없어도 문제 없겠지만, push하거나 modal 등으로 바뀔 수 있으니 유지.
      .take(until: rx.methodInvoked(#selector(UIViewController.viewWillDisappear(_:))))
      .asDriver(onErrorJustReturn: "0:00:00")
      .drive(timerView.runningTimeLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func configureAll(timer: TimerModel) {
    headerView.configure(model: timer)
  }
  
  deinit {
    print(" ---> [Deinit 확인!] 구독해제!")
  }
}
