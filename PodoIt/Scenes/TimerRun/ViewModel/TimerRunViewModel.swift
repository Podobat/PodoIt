//
//  TimerRunViewModel.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import Foundation
import RxCocoa
import RxSwift

enum RestAddCase {
  case one
  case five
  case ten
  
  var seconds: Int {
    switch self {
    case .one: return 60
    case .five: return 300
    case .ten: return 600
    }
  }
}

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
    totalStudySeconds: 0,
    totalRestSeconds: 0 // UserDefaults 써서 앱 껐다 켜졌을때 시간 계산에 사용됨. 그 전에는 사용 x
  )
  
  // isRunningRelay가 값이 바뀔 때마다 이벤트 방출
  private let isRunningRelay = BehaviorRelay<Bool>(value: true) // accept로 변경 가능하니 노출 x
  var isRunningDriver: Driver<Bool> { // UI 바인딩용. 호출때마다 Relay를 Driver로 감싼 스트림 반환
    isRunningRelay.asDriver()
  }
  
  // 목표시간 (초). load()시에 분 -> 초 단위로 세팅됨
  private(set) var goalTime: Int = 0
  private var defaultRestSeconds: Int = 300 // 기본 휴식시간 5분 고정 (매 휴식마다 5분 초기화)
  var restAddSeconds = 0 // 기본 휴식시간에 추가로 더 휴식하는 시간
  
  // MARK: - Tick (공유 타이머 스트림)
  
  // tick을 여러군데에서 쓰일 것 같기에 빼둠.
  private lazy var tick: Observable<Int> = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .startWith(0) // startWith(0)을 안붙여주면, 첫 이벤트가 1초 뒤에 옴.
    .share(replay: 1, scope: .whileConnected) // share로 한 번에 여러곳에 공유. 가장 최근 이벤트 1개 방출 및 구독자가 존재할때만 스트림 유지
  
  // MARK: - Outputs (UI 바인딩용 Driver)
  
  lazy var goalTimeText: Driver<String> = makeGoalTimeText(tick: tick) // 공부 목표시간 (MM:SS)
  lazy var runningTimeText: Driver<String> = makeRunningTimeText(tick: tick) // 공부중인 시간 (H:MM:SS)

  lazy var totalRestTimeText: Driver<String> = makeTotalRestTimeText(tick: tick) // 총 "휴식 중인 시간"
  lazy var restTimeText: Driver<String> = makeRestTimeText(tick: tick) // "남은 휴식시간" 방출 (기본 5분. MM:SS)

  lazy var progress: Driver<Float> = makeProgress(tick: tick) // progress 진행률 방출
  
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
      state.totalStudySeconds += time // 공부 시간 누적
      print("현재까지 총 공부 시간: \(state.totalStudySeconds)")
    } else {
      state.totalRestSeconds += time // 휴식 시간 누적
      print("현재까지 총 휴식 시간: \(state.totalRestSeconds)")
    }
    
    state.isRunning.toggle()
    state.stateStart = now // 공부 <-> 휴식 상태가 바뀌니, 그 구간의 새 시각
    isRunningRelay.accept(state.isRunning) // 변경된 상태 저장
  }
  
  /// 정지
  @MainActor
  func stop() {
    let now = Date()
    let lastTime = Int(now.timeIntervalSince(state.stateStart))
    
    if state.isRunning {
      state.totalStudySeconds += lastTime
    } else {
      // 혹시 필요할까 싶어서 총 휴식 시간도 누적계산
      state.totalRestSeconds += lastTime
    }
    // 총 공부시간이 60초 이상일 경우에만 save()
    guard state.totalStudySeconds > 59 else { return }
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
        time: TimerRunViewModel.formatHMMSS(seconds: state.totalStudySeconds) // 총 공부 시간
      )
      print("""
      [데이터 저장 완료]
      아이콘 이름: \(timer.iconName)
      타이머 이름: \(timer.title)
      총 공부 시간: \(TimerRunViewModel.formatHMMSS(seconds: state.totalStudySeconds))
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
        let remainingStudyTime = max(vm.goalTime - totalStudyTime, 0) // 남은 시간은 목표시간 - 총 공부시간
        return TimerRunViewModel.formatMMSS(seconds: remainingStudyTime)
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
        return TimerRunViewModel.formatHMMSS(seconds: totalStudyTime)
      }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: "0:00:00") // 에러나면 기본으로 "0:00:00" 방출
  }
  
  // MARK: - makeRestTimeText, makeTotalRestTimeText 중복 로직 리팩토링 예정

  /// UI의 라벨에 바인딩할 "남은 휴식 시간" 문자열 Driver 생성
  private func makeRestTimeText(tick: Observable<Int>) -> Driver<String> {
    return tick.withUnretained(self)
      .map { vm, _ in // 300초 - 휴식시간, 0
        let now = Date()
        let elapsedRestTime = vm.state.isRunning ? 0 : Int(now.timeIntervalSince(vm.state.stateStart)) // 이번 세션에 실시간으로 휴식중인 시간 (공부중인 시간 제외)
        // 매 섹션마다 휴식시간 5분으로 초기화
        // 300초(기본 값) - 이번 세션에 휴식중인 시간 + 추가된 휴식 시간(restAddSeconds), (음수라면 0으로 max)
        let remainingRestTime = max(vm.defaultRestSeconds - elapsedRestTime + vm.restAddSeconds, 0)
        return TimerRunViewModel.formatMMSS(seconds: remainingRestTime)
      }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: "00:00")
  }
  
  /// UI의 라벨에 바인딩할 "총 휴식중인 시간" 문자열 Driver 생성
  private func makeTotalRestTimeText(tick: Observable<Int>) -> Driver<String> {
    return tick.withUnretained(self)
      .map { vm, _ in // now(현재) - stateStart(휴식 섹션 시작한 시간)
        let now = Date()
        let elapsedRestTime = vm.state.isRunning ? 0 : Int(now.timeIntervalSince(vm.state.stateStart))
        let totalRestTime = min(elapsedRestTime, 1800) // 쉬는 시간 최대 30분(1800초)
        return TimerRunViewModel.formatMMSS(seconds: totalRestTime)
      }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: "00:00")
  }

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
  private static func formatHMMSS(seconds: Int) -> String {
    let h = seconds / 3600
    let m = (seconds % 3600) / 60
    let s = seconds % 60
    return String(format: "%d:%02d:%02d", h, m, s) // 0:12:53, 1:50:49, 12:49:39등으로 포맷
  }
  
  /// 시간 포맷터 ("mm:ss")
  private static func formatMMSS(seconds: Int) -> String {
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
    let totalStudyTime = state.totalStudySeconds + runningTime
    return totalStudyTime
  }
}
