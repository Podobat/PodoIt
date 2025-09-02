//
//  TimerRunViewModel.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import Foundation
import RxSwift
import RxCocoa

final class TimerRunViewModel {
  // MARK: - Dependencies

  private let timerID: UUID
  private let repo: TimerRepository
  
  // MARK: - State

  private(set) var timer: TimerModel?
  private let disposeBag = DisposeBag()
  
  private(set) var state = TimerSessionState(
    sessionStart: Date(),
    stateStart: Date(),
    isRunning: true,
    studySeconds: 0,
    restSeconds: 0
  )
  
  // isRunningRelay가 값이 바뀔 때마다 이벤트 방출
  private let isRunningRelay = BehaviorRelay<Bool>(value: true) // accept로 변경 가능하니 노출 x
  var isRunningDriver: Driver<Bool> { // UI 바인딩용. 호출때마다 Relay를 Driver로 감싼 스트림 반환
    isRunningRelay.asDriver()
  }
  
  // 목표시간 (초). load()시에 분 -> 초 단위로 세팅됨
  private(set) var goalTime: Int = 0
  
  // MARK: - Tick (공유 타이머 스트림)
  
  // tick을 여러군데에서 쓰일 것 같기에 빼둠.
  private lazy var tick: Observable<Int> = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .startWith(0) // startWith(0)을 안붙여주면, 첫 이벤트가 1초 뒤에 옴.
    .share(replay: 1, scope: .whileConnected) // share로 한 번에 여러곳에 공유. 가장 최근 이벤트 1개 방출 및 구독자가 존재할때만 스트림 유지
  
  // MARK: - Outputs (UI 바인딩용 Driver)

  lazy var runningTimeText: Driver<String> = makeRunningTimeText(tick: tick) // UI바인딩용. 공부시간을 방출
  lazy var goalTimeText: Driver<String> = makeGoalTimeText(tick: tick)
  lazy var progress: Driver<Float> = makeProgress(tick: tick) // UI바인딩용. progress 진행률 방출
  
  // MARK: - init

  init(timerID: UUID, repo: TimerRepository) {
    self.timerID = timerID
    self.repo = repo
  }
  
  // MARK: - Data Loading
  
  // 받아온 UUID를 기준으로 SwiftData에서 데이터를 바인딩
  func load() throws {
    guard let entity = try repo.fetch(by: timerID) else {
      throw RepositoryError.entityNotFound
    }
    self.timer = entity
    self.goalTime = entity.goalTime * 60 // Int값을 초 단위로 변경
  }
  
  // MARK: - Actions

  /// 시작/일시정지 버튼 토글
  func startAndPause() {
    // 여기에서 타이머 작동 로직
    // isRunning: Bool의 상태값을 기준으로, start/pause 상태로 관리
    
    let now = Date()
    // 이번 구간의 시간(현재 시간 - 현재 구간(공부/휴식))
    let time = Int(now.timeIntervalSince(state.stateStart))
    
    // 상태에 따라서 시간 누적
    if state.isRunning {
      state.studySeconds += time // 공부 시간 누적
      print("현재까지 총 공부 시간: \(state.studySeconds)")
    } else {
      state.restSeconds += time // 휴식 시간 누적
      print("현재까지 총 휴식 시간: \(state.restSeconds)")
    }
    
    state.isRunning.toggle()
    isRunningRelay.accept(state.isRunning) // 변경된 상태 저장
    state.stateStart = now // 공부 <-> 휴식 상태가 바뀌니, 그 구간의 새 시각
  }
  
  /// 정지
  @MainActor
  func stop() {
    let now = Date()
    let lastTime = Int(now.timeIntervalSince(state.stateStart))
    
    if state.isRunning {
      state.studySeconds += lastTime
    } else {
      // 혹시 필요할까 싶어서 총 휴식 시간도 누적계산
      state.restSeconds += lastTime
    }
    save()
  }
  
  /// SwiftData의 StatsModel에 데이터 저장
  @MainActor
  private func save() {
    guard let timer = self.timer else {
      print("세이브 실패. 타이머 데이터가 없습니다.")
      return
    }
    do {
      try SwiftDataManager.shared.insertStats(
        icon: timer.iconName, // 타이머 아이콘
        category: timer.title, // 타이머 이름
        time: TimerRunViewModel.format(seconds: state.studySeconds) // 총 공부 시간
      )
      print("""
        [데이터 저장 완료]
        아이콘 이름: \(timer.iconName)
        타이머 이름: \(timer.title)
        총 공부 시간: \(TimerRunViewModel.format(seconds: state.studySeconds))
        """)
    } catch {
      print("데이터 저장 실패: \(RepositoryError.saveFailed)")
    }
  }

  // MARK: Stream

  /// 목표시간 스트림
  private func makeGoalTimeText(tick: Observable<Int>) -> Driver<String> {
    return tick.withUnretained(self)
      .map { vm, _ in
        let totalStudyTime = vm.totalStudyTime()
        let remaining = max(vm.goalTime - totalStudyTime, 0) // 남은 시간은 목표시간 - 총 공부시간
        return TimerRunViewModel.formatGoalTime(seconds: remaining)
      }
      .distinctUntilChanged() // 이전값과 새 값이 같으면 방출안하고 무시
      .asDriver(onErrorJustReturn: "00:00")
  }
  
  /// UI의 라벨에 바인딩할 공부시간 문자열 Driver 생성
  private func makeRunningTimeText(tick: Observable<Int>) -> Driver<String> {
    return tick.withUnretained(self)
      .map { vm, _ in
        let totalStudyTime = vm.totalStudyTime()
        // 총 공부 시간을 "h:mm:ss" 형태 문자열로 반환
        return TimerRunViewModel.format(seconds: totalStudyTime)
      }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: "0:00:00") // 에러나면 기본으로 "0:00:00" 방출
  }
  
  // MARK: progress 스트림

  /// UIProgressView 진행률
  private func makeProgress(tick: Observable<Int>) -> Driver<Float> {
    return tick.withUnretained(self)
      .map { vm, _ in
        let totalStudyTime = vm.totalStudyTime()
        let progressValue = Float(totalStudyTime) / Float(vm.goalTime)
        return min(progressValue, 1.0)
      }
      .distinctUntilChanged() // 1.0 이후 추가 방출없음. 동일값이라 무시
      .asDriver(onErrorJustReturn: 0.0)
  }
  
  // MARK: - Formatters

  /// 시간 포맷터 ("h:mm:ss")
  private static func format(seconds: Int) -> String {
    let h = seconds / 3600
    let m = (seconds % 3600) / 60
    let s = seconds % 60
    return String(format: "%d:%02d:%02d", h, m, s) // 0:12:53, 1:50:49, 12:49:39등으로 포맷
  }
  
  /// 목표 시간 포맷터 ("mm:ss")
  private static func formatGoalTime(seconds: Int) -> String {
    // 값이 3600이 들어옴
    // 이 3600을 60으로 나눠서(/) 그 값을 포맷팅
    let m = seconds / 60
    let s = seconds % 60
    return String(format: "%02d:%02d", m, s)
  }
}

extension TimerRunViewModel {
  // 최신의 총 공부 시간을 반환
  private func totalStudyTime(now: Date = Date()) -> (Int) {
    // 공부중이면 stateStart부터 지금까지 흐른 초(seconds)를 계산 / 휴식중이면 실시간 경과는 0인 상태
    let runningTime = state.isRunning ? Int(now.timeIntervalSince(state.stateStart)) : 0
    // 최신의 누적된 총 공부 시간 = 누적된 총 공부시간 + 진행중 공부 경과시간 계산
    let totalStudyTime = state.studySeconds + runningTime
    return totalStudyTime
  }
}
