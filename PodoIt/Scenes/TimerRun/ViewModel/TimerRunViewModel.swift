//
//  TimerRunViewModel.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import Dependencies
import Foundation
import RxCocoa
import RxSwift

enum RestAddCase {
  case one
  case five
  case ten
  
  var seconds: Int {
    switch self {
    #if DEBUG // debug 상태에서는 +10/+20/+30초
      case .one: return 10
      case .five: return 20
      case .ten: return 30
    #else // 그 외에는 +1/+5+10분
      case .one: return 60
      case .five: return 300
      case .ten: return 600
    #endif
    }
  }
}

final class TimerRunViewModel {
  // MARK: - Dependencies

  @Dependency(\.timerRepository) private var repo
  private static let udSnapshotKey = "timer_key"
  
  // MARK: - State

  private(set) var timer: TimerModel
  private let disposeBag = DisposeBag()
  
  private(set) var state = TimerSessionState(
    intervalStart: Date(),
    isStudying: true,
    totalStudySeconds: 0,
  )
  
  // isStudyingRelay가 값이 바뀔 때마다 이벤트 방출
  private let isStudyingRelay = BehaviorRelay<Bool>(value: true) // accept로 변경 가능하니 노출 x
  var isStudyingDriver: Driver<Bool> { // UI 바인딩용. 호출때마다 Relay를 Driver로 감싼 스트림 반환
    isStudyingRelay.asDriver()
  }
  
  var isMuteDriver: Driver<Bool> {
    AudioSettings.shared.isMute.asDriver()
  }

  private(set) var goalTime: Double = 0 // 목표시간 (초). load()시에 분 -> 초 단위로 세팅됨
  
  #if DEBUG
    private let defaultRestSeconds: Double = 10 // 디버그 상태에서는 10초로 고정
  #else
    private let defaultRestSeconds: Double = 300 // 기본 휴식시간 5분 고정 (매 휴식마다 5분 초기화)
  #endif
  
  private var restAddSeconds: Double = 0 // 기본 휴식시간에 추가로 더 휴식하는 시간
  // 버튼/상태 변화시에 즉시 재계산을 위함
  private let restUpdateRelay = PublishRelay<Void>() // 초기값 없이 단순 이벤트 방출
  
  // 휴식 시간 계산을 위한 변수
  private var zeroMark: Bool = false // 남은 시간이 '처음 0이 된' 순간 (true: 0, false: 0이 되기 전)
  private var addedMark: Double? // 0상태에서 + 버튼이 눌린 순간의 restIntervalTime. (버튼을 누른 시점까지의 "총 휴식 경과시간")
  private var addSnapshot: Double = 0 // 0 도달 당시의 restAddSeconds 스냅샷 (0 도달 전까지 휴식한 시간과 구별하기 위함)
  
  // MARK: - Tick (공유 타이머 스트림)
  
  private lazy var tick: Observable<Int> = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .startWith(0) // startWith(0)을 안붙여주면, 첫 이벤트가 1초 뒤에 옴.
    .share(replay: 1, scope: .whileConnected) // share로 한 번에 여러곳에 공유. 가장 최근 이벤트 1개 방출 및 구독자가 존재할때만 스트림 유지
  
  // tick(1초) + 버튼 이벤트를 합쳐서 재계산하는 트리거
  // 버튼 누를 시 tick(1초)뒤가 아닌 즉시 시간이 재계산되게 하기 위해서
  private lazy var restTimeUpdateTrigger: Observable<Void> = Observable.merge(
    tick.map { _ in }, // Observable<Void>로 반환
    restUpdateRelay.asObservable()
  )
  
  // MARK: - Outputs (UI 바인딩용 Driver)

  lazy var goalTimeText: Driver<String> = makeGoalTimeText(tick: tick) // 공부 목표시간 (MM:SS)
  lazy var studyingTimeText: Driver<String> = makeStudyingTimeText(tick: tick) // 공부중인 시간 (H:MM:SS)

  lazy var totalRestTimeText: Driver<String> = makeTotalRestTimeText(tick: tick) // 총 "휴식 중인 시간"
  lazy var restingTimeText: Driver<String> = makeRestingTimeText(trigger: restTimeUpdateTrigger) // "남은 휴식시간" 방출 (기본 5분. MM:SS)

  lazy var progress: Driver<Float> = makeProgress(tick: tick) // progress 진행률 방출
  lazy var isOverOneMinute: Driver<Bool> = makeIsOverOneMinute(tick: tick) // 1분 이상인지 아닌지에 따른 Bool값
  
  // MARK: - init

  init(timer: TimerModel) {
    self.timer = timer
    goalTime = Double(timer.goalTime) * 60 // Int값을 초 단위로 변경
  }
  
  // MARK: - Data Loading
  
  func setupTimer() {
    if state.isStudying {
      scheduleGoalEndNotification() // 공부 목표 시간 알림 예약
    }
    // 앱 진입 후 바로 스냅샷 저장
    saveSessionUDSnapshot()
  }
  
  // MARK: - UserDefaults 저장/불러오기/삭제
  
  /// UserDefaults에 데이터 저장
  private func saveSessionUDSnapshot() {
    let snapshot = TimerSessionUDSnapshot(
      timerID: timer.timerID,
      isStudying: state.isStudying,
      intervalStart: state.intervalStart,
      totalStudySeconds: state.totalStudySeconds,
      restAddSeconds: self.restAddSeconds,
      zeroMark: self.zeroMark,
      addedMark: self.addedMark,
      addSnapshot: self.addSnapshot
    )
    
    if let data = try? JSONEncoder().encode(snapshot) {
      UserDefaults.standard.set(data, forKey: Self.udSnapshotKey) // Self는 현재 타입을 의미해서 TimerRunViewModel.ud..와 동일
    }
  }
  
  /// UserDefaults에 데이터 불러오기
  private func fetchSessionUDSnapshot() {
    guard let savedData = UserDefaults.standard.object(forKey: Self.udSnapshotKey) as? Data else { return } // UD 가져옴
    guard let snapshotData = try? JSONDecoder().decode(TimerSessionUDSnapshot.self, from: savedData) else { return } // UD 디코딩
    
    // 주입받은 timerID가 스냅샷의 ID와 다르게 되면 무시하도록. (안전을 위해)
    guard snapshotData.timerID == timer.timerID else { return }
    
    // 상태 복원
    self.state.isStudying = snapshotData.isStudying
    self.state.intervalStart = snapshotData.intervalStart
    self.state.totalStudySeconds = snapshotData.totalStudySeconds
    
    self.restAddSeconds = snapshotData.restAddSeconds
    self.zeroMark = snapshotData.zeroMark
    self.addedMark = snapshotData.addedMark
    self.addSnapshot = snapshotData.addSnapshot
    
    self.isStudyingRelay.accept(snapshotData.isStudying) // 공부중인지 UI가 알아야 바뀌니까 accept
    // 상태 복원 후 알림을 현재 상태에 맞게 재예약
    rescheduleNotifications()
  }
  
  /// UserDefaults 데이터 삭제
  private func deleteSessionUDSnapshot() {
    UserDefaults.standard.removeObject(forKey: Self.udSnapshotKey)
  }
  
  // MARK: 앱 라이프 사이클에 따른 UD Snapshot
  
  /// 앱이 백그라운드로 갈 때 호출해서 데이터 저장
  func saveUDOnBackground() {
    saveSessionUDSnapshot()
  }
  
  /// 외부에서 fetch하기 위한 메서드
  func loadUDSaved() {
    fetchSessionUDSnapshot()
  }
  
  // MARK: - Actions
  
  /// 타이머 음소거
  func toggleMute() {
    let newValue = !AudioSettings.shared.isMute.value // 값 toggle
    AudioSettings.shared.isMute.accept(newValue) // 버튼 UI 변경을 위한 Bool값 스트림
    
    // 음소거 토글시, 현재 상태에 따라 알림 재예약
    rescheduleNotifications()
  }
  
  /// 휴식 시간 추가 (+1/+5/+10) 후 즉시 라벨 갱신
  func addRestTime(seconds: Int) {
    restAddSeconds += Double(seconds)
    
    // 현재 구간의 tick 기반 경과 시간
    let now = Date()
    // 휴식 구간 기준 경과시간(addedMark 계산용). 공부중에는 휴식이 아니라서 0처리
    let restIntervalTime = state.isStudying ? 0 : now.timeIntervalSince(state.intervalStart)
    
    if zeroMark == true, addedMark == nil { // 이미 0에 도달했다면
      addedMark = restIntervalTime // 추가를 누른 시점 기준까지 "총 휴식한 시간"을 저장.
    }
    
    restUpdateRelay.accept(()) // Void라서 넣지 않고 신호만 보냄. 즉시 갱신
    if state.isStudying == false { // 휴식 중
      scheduleRestEndNotification() // 휴식시간이 늘어나니, 휴식 시간 재계산 후 알림 예약
    }
    // 휴식 시간이 늘어날 때마다 스냅샷 저장
    saveSessionUDSnapshot()
  }

  /// 시작/일시정지 버튼 토글
  func startAndPause() {
    // 여기에서 타이머 작동 로직
    addIntervalTime() // 현재 구간 기준으로 공부 시간을 totalStudySeconds에 누적
    state.isStudying.toggle()
    state.intervalStart = Date() // 공부 <-> 휴식 상태가 바뀌니, 그 구간의 새 시각
    isStudyingRelay.accept(state.isStudying) // 변경된 상태 저장
    restAddSeconds = 0 // 추가한 휴가시간이 다음 휴식때 이어지지 않도록, 추가한 휴가시간 초기화
    
    // 상태 변화마다 값 원점으로 초기화
    zeroMark = false
    addedMark = nil
    addSnapshot = 0
    
    // 상태 전환때마다 알림 재예약
    rescheduleNotifications()
    // 상태 전환 후 스냅샷 저장
    saveSessionUDSnapshot()
  }
  
  /// 정지
  @MainActor
  func stop() {
    addIntervalTime()
    // 세션 종료: 모든 알림을 캔슬
    cancelGoalEndNotification()
    cancelRestEndNotification()
    
    // UD 스냅샷을 삭제(초기화)해서 다음 세션에 문제 없도록
    deleteSessionUDSnapshot()
    
    // 총 공부시간이 60초 이상일 경우에만 save()
    guard state.totalStudySeconds > 59 else { return }
    save()
  }
  
  /// SwiftData의 StatsModel에 데이터 저장
  @MainActor
  private func save() {
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
  
  private func makeIsOverOneMinute(tick: Observable<Int>) -> Driver<Bool> {
    return tick.withUnretained(self)
      .map { vm, _ in
        let totalStudyTime = vm.totalStudyTime()
        return totalStudyTime >= 60
      }
      .distinctUntilChanged() // 이전값과 새 값이 같으면 방출안하고 무시
      .asDriver(onErrorJustReturn: false)
  }
  
  /// 목표시간 스트림
  private func makeGoalTimeText(tick: Observable<Int>) -> Driver<String> {
    return tick.withUnretained(self)
      .map { vm, _ in
        let totalStudyTime = vm.totalStudyTime()
        let remainingStudyTime = max(vm.goalTime - totalStudyTime, 0) // 남은 시간은 목표시간 - 총 공부시간
        return TimerRunViewModel.formatMMSS(seconds: remainingStudyTime)
      }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: "00:00")
  }
  
  /// UI의 라벨에 바인딩할 공부시간 문자열 Driver 생성
  private func makeStudyingTimeText(tick: Observable<Int>) -> Driver<String> {
    return tick.withUnretained(self)
      .map { vm, _ in
        let totalStudyTime = vm.totalStudyTime()
        // 총 공부 시간을 "h:mm:ss" 형태 문자열로 반환
        return TimerRunViewModel.formatHMMSS(seconds: totalStudyTime)
      }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: "0:00:00") // 에러나면 기본으로 "0:00:00" 방출
  }
  
  /// UI의 라벨에 바인딩할 "총 휴식중인 시간" 문자열 Driver 생성
  private func makeTotalRestTimeText(tick: Observable<Int>) -> Driver<String> {
    return tick.withUnretained(self)
      .map { vm, _ in // now(현재) - stateStart(휴식 섹션 시작한 시간)
        let now = Date()
        let restIntervalTime = vm.state.isStudying ? 0 : now.timeIntervalSince(vm.state.intervalStart)
        return TimerRunViewModel.formatMMSS(seconds: restIntervalTime)
      }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: "00:00")
  }

  /// UI의 라벨에 바인딩할 "남은 휴식 시간" 문자열 Driver 생성
  private func makeRestingTimeText(trigger: Observable<Void>) -> Driver<String> {
    return trigger.withUnretained(self)
      .map { vm, _ in // 300초 - 휴식시간, 0
        let now = Date()
        let restIntervalTime = vm.state.isStudying ? 0 : now.timeIntervalSince(vm.state.intervalStart) // 이번 세션에 실시간으로 휴식중인 시간 (공부중인 시간 제외)
        
        // MARK: 3) 0이후. 이미 값이 0이라면 처리

        if vm.zeroMark == true { // 값이 있으면(이미 0인 상태)
          // 아직 시간이 추가하지 않았다면 "00:00" 유지
          guard let restTimeAtAdd = vm.addedMark else {
            return "00:00"
          }
          
          /// 휴식시간 추가 후 흐른 시간
          // 추가 버튼을 누른 순간까지 휴식했던 시간(restTimeAtAdd)부터 지금까지 흐른 시간
          // 305초에 +1분하고 지금까지 320초가 흘렀다면, 320 - 305 = 15초가 흘렀다는 것
          let addRun = max(restIntervalTime - restTimeAtAdd, 0)
          
          /// 0이 된 시점 이후 새로 추가된 총 휴식 시간
          // restAddSeconds는 값이 누적되니, 누적된 값이 0으로 다 소진되면, 그 값을 addSnapshot에 넣어서, 추가된 휴식 시간만 쉬도록 보장
          let addSum = max(vm.restAddSeconds - vm.addSnapshot, 0)
          
          /// 화면에 보여줄 남은 추가 휴식시간
          // 추가된 총 휴식시간(addSum)에서 이미 지난 시간(addRun)을 뺸 값.
          let remaining = max(addSum - addRun, 0)
          
          if remaining == 0 { // 0초가 되면
            vm.addedMark = nil // 추가버튼 눌린 시점 초기화
            vm.addSnapshot = vm.restAddSeconds // 다음 번의 누적값에서 0되기 전의 추가 시간 제외하기 위해, 현재의 restAddSeconds값 보관
          }
          return TimerRunViewModel.formatMMSS(seconds: remaining)
        }
      
        // MARK: 1) 기본 시간 0분 안된. 일반적인 기본 카운트다운 (0 되기 전 추가 휴식시간 포함)

        // 기본 300초(5분) + 추가된 휴식 시간 - 휴식중인 시간
        let base = max(vm.defaultRestSeconds + vm.restAddSeconds - restIntervalTime, 0)
        if base > 0 { // 0되기 전에는 이 값을 반환
          return TimerRunViewModel.formatMMSS(seconds: base)
        }
        
        // MARK: 2) 0으로 막 진입. 스냅샷 준비. 값은 00:00 반환

        vm.zeroMark = true // 값이 처음 0된 순간. true 상태로 변경
        vm.addSnapshot = vm.restAddSeconds // 0진입 전 추가한 시간 누적량 스냅샷
        return "00:00"
      }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: "00:00")
  }

  /// UIProgressView 진행률
  private func makeProgress(tick: Observable<Int>) -> Driver<Float> {
    return tick.withUnretained(self)
      .map { vm, _ in
        let totalStudyTime = vm.totalStudyTime()
        let progressValue = totalStudyTime / vm.goalTime
        return min(Float(progressValue), 1.0)
      }
      .distinctUntilChanged() // 1.0 이후 추가 방출없음. 동일값이라 무시
      .asDriver(onErrorJustReturn: 0.0)
  }
  
  // MARK: - Formatters

  /// 시간 포맷터 ("h:mm:ss")
  private static func formatHMMSS(seconds: Double) -> String {
    let sec = Int(seconds.rounded()) // 반올림 처리까지
    let h = sec / 3600
    let m = (sec % 3600) / 60
    let s = sec % 60
    return String(format: "%d:%02d:%02d", h, m, s) // 0:12:53, 1:50:49, 12:49:39등으로 포맷
  }
  
  /// 시간 포맷터 ("mm:ss")
  private static func formatMMSS(seconds: Double) -> String {
    let sec = Int(seconds.rounded())
    // 값이 3600이 들어옴
    // 이 3600을 60으로 나눠서(/) 그 값을 포맷팅
    let m = sec / 60
    let s = sec % 60
    return String(format: "%02d:%02d", m, s)
  }
}

extension TimerRunViewModel {
  /// 현재 구간(state.intervalStart 기준)의 경과 시간을 누적
  /// - 총 공부 시간을 저장
  private func addIntervalTime(now: Date = Date()) {
    let intervalTime = now.timeIntervalSince(state.intervalStart)
    
    // 상태에 따라서 시간 누적
    if state.isStudying {
      state.totalStudySeconds += intervalTime // 공부 시간 누적
      print("현재까지 총 공부 시간: \(state.totalStudySeconds)")
    }
  }
  
  /// 최신의 총 공부 시간을 반환
  /// - 1초마다 바뀌는 현재의 공부 시간이 필요할때 사용
  private func totalStudyTime(now: Date = Date()) -> (Double) {
    // 공부중이면 stateStart부터 지금까지 흐른 초(seconds)를 계산 / 휴식중이면 실시간 경과는 0인 상태
    let studyIntervalTime = state.isStudying ? now.timeIntervalSince(state.intervalStart) : 0
    // 최신의 누적된 총 공부 시간 = 누적된 총 공부시간 + 진행중 공부 경과시간 계산
    return Double(state.totalStudySeconds) + studyIntervalTime
  }
  
  /// 목표시간 끝나기까지 남은 시간을 계산 (UserNotification 예약을 위해)
  private func remainingStudySeconds() -> Double {
    let total = totalStudyTime()
    return max(Double(goalTime) - total, 0)
  }
  
  /// 남은 휴식 시간 끝나기까지 남은 시간을 계산 (UserNotification 예약을 위해)
  private func remainingRestSeconds(now: Date = Date()) -> Double {
    let restIntervalTime = state.isStudying ? 0 : now.timeIntervalSince(state.intervalStart)
    
    // 위의 makeRestingTimeText로직과 동일
    // 0 이후 추가 시간 카운트다운
    if zeroMark {
      // 값 추가 안하면 0초로 유지
      guard let addedTick = addedMark else { return 0 }
      
      let addRun = max(restIntervalTime - Double(addedTick), 0) // 추가 이후 경과 시간
      let addSum = max(restAddSeconds - addSnapshot, 0) // 추가된 총 휴식시간
      return max(addSum - addRun, 0)
    }
    
    // 기본 카운트다운 (0되기 전): 기본 5분 + 추가시간 - 경과한 시간
    let base = max(defaultRestSeconds + restAddSeconds - restIntervalTime, 0)
    if base > 0 { return base }
    
    // 막 0에 진입한 순간
    return 0
  }
  
  /// 목표시간 Notification 예약
  private func scheduleGoalEndNotification() {
    let sec = remainingStudySeconds()
    NotificationScheduler
      .scheduleEnd(
        id: NotificationID.goalTimeEnd,
        title: NotificationTitle.goalTimeEnd,
        body: NotificationBody.goalTimeEnd,
        date: Date().addingTimeInterval(TimeInterval(sec)), // 지금시각 + 남은 초remainingStudySeconds(초) = 울릴 시간 구함
        isMuted: AudioSettings.shared.isMute.value
      )
  }
  
  /// 휴식시간 Notification 예약
  private func scheduleRestEndNotification() {
    let sec = remainingRestSeconds()
    NotificationScheduler
      .scheduleEnd(
        id: NotificationID.restingTimeEnd,
        title: NotificationTitle.restingTimeEnd,
        body: NotificationBody.restingTimeEnd,
        date: Date().addingTimeInterval(TimeInterval(sec)),
        isMuted: AudioSettings.shared.isMute.value
      )
  }
  
  /// 현재 상태(state.isStudying)에 맞게 알림을 정리/재예약
  private func rescheduleNotifications() {
    // 항상 둘 다 취소해서 상태 꼬임/중복 예약을 방지
    cancelGoalEndNotification()
    cancelRestEndNotification()
    
    // 현재 상태에 맞는 알림만 예약
    if state.isStudying {
      scheduleGoalEndNotification()
    } else {
      scheduleRestEndNotification()
    }
  }
  
  /// 목표시간 Notification 예약 취소
  private func cancelGoalEndNotification() { NotificationScheduler.cancel(id: NotificationID.goalTimeEnd) }
  
  /// 휴식 Notification 예약 취소
  private func cancelRestEndNotification() { NotificationScheduler.cancel(id: NotificationID.restingTimeEnd) }
  
  /// SceneDelegate에서 의존성때문에 인스턴스 생성을 못하니, 타입 메서드로 선언해서 가져다사용
  static func fetchSavedTimerID() -> UUID? {
    guard let data = UserDefaults.standard.object(forKey: self.udSnapshotKey) as? Data,
          let snapshot = try? JSONDecoder().decode(TimerSessionUDSnapshot.self, from: data) else { return nil }
    return snapshot.timerID
  }
}
