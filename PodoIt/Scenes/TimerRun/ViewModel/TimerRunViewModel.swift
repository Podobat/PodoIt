//
//  TimerRunViewModel.swift
//  PodoIt
//
//  Created by 서광용 on 8/28/25.
//

import Foundation
import RxCocoa
import RxSwift

final class TimerRunViewModel {
  private let timerID: UUID
  private let repo: TimerRepository
  
  private(set) var timer: TimerModel?
  private let disposeBag = DisposeBag()
  
  private var sessionStart = Date() // 공부 시작한 시간 기록
  private var stateStart = Date() // 현재 구간(공부/휴식)이 시작된 시간 기록
  private var isRunning = true // 공부 중(true)/휴식 중(false)
  
  private var studySeconds = 0 // 지금까지 누적된 총 공부 시간(초)
  private var restSeconds = 0 // 지금까지 누적된 총 휴식 시간(초)
  
  lazy var runningTimeText: Driver<String> = makeRunningTimeText() // UI바인딩용. 공부시간을 방출
  
  // MARK: 시간 포맷터 ("h:mm:ss")
  
  private static func format(seconds: Int) -> String {
    let h = seconds / 3600
    let m = (seconds % 3600) / 60
    let s = seconds % 60
    return String(format: "%d:%02d:%02d", h, m, s) // 0:12:53, 1:50:49, 12:49:39등으로 포맷
  }
  
  // MARK: 공부시간 스트림
  
  // UI의 라벨에 바인딩할 공부시간 문자열 Driver 생성
  private func makeRunningTimeText() -> Driver<String> {
    // 1초마다 아래의 map 블록 실행되며 runningTime부터 다시 계산.
    // startWith(0)을 안붙여주면, 첫 이벤트가 1초 뒤에 옴.
    let tick = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
      .startWith(0)
    
    return tick.withUnretained(self)
      .map { vm, _ in
        let now = Date()
        // 공부중이면 stateStart부터 지금까지 흐른 초(seconds)를 계산
        // 휴식중이면 실시간 경과는 0인 상태
        let runningTime = vm.isRunning ? Int(now.timeIntervalSince(vm.stateStart)) : 0
        
        // 누적된 총 공부시간 + 진행중 공부 경과시간 계산
        let totalStudyTime = vm.studySeconds + runningTime
        
        // 총 공부 시간을 "h:mm:ss" 형태 문자열로 반환
        return TimerRunViewModel.format(seconds: totalStudyTime)
      }
      .distinctUntilChanged() // 이전값과 새 값이 같으면 방출안하고 무시
      .asDriver(onErrorJustReturn: "0:00:00") // 에러나면 기본으로 "0:00:00" 방출
  }
  
  // MARK: init

  init(timerID: UUID, repo: TimerRepository) {
    self.timerID = timerID
    self.repo = repo
  }
  
  // MARK: 데이터 로딩
  
  // 받아온 UUID를 기준으로 SwiftData에서 데이터를 바인딩
  func load() throws {
    guard let entity = try repo.fetch(by: timerID) else {
      throw RepositoryError.entityNotFound
    }
    self.timer = entity
  }
  
  // MARK: 시작/일시정지 버튼 tap

  func startAndPause() {
    // 여기에서 타이머 작동 로직
    // isRunning: Bool의 상태값을 기준으로, start/pause 상태로 관리
    
    let now = Date()
    // 이번 구간의 시간(현재 시간 - 현재 구간(공부/휴식))
    let time = Int(now.timeIntervalSince(stateStart))
    
    // 상태에 따라서 시간 누적
    if isRunning {
      studySeconds += time // 공부 시간 누적
      print("현재까지 총 공부 시간: \(studySeconds)")
    } else {
      restSeconds += time // 휴식 시간 누적
      print("현재까지 총 휴식 시간: \(restSeconds)")
    }
    
    isRunning.toggle()
    stateStart = now // 공부 <-> 휴식 상태가 바뀌니, 그 구간의 새 시각
  }
  
  // MARK: 정지 버튼 tap

  func stop() {
    let now = Date()
    let lastTime = Int(now.timeIntervalSince(stateStart))
    
    if isRunning {
      studySeconds += lastTime
    } else {
      // 혹시 필요할까 싶어서 총 휴식 시간도 누적계산
      restSeconds += lastTime
    }
    
    /*
     
     Models/StateModel의 StatsModel에 저장해야 하는 테이터들
     var statsID: UUID
     var date: Date
     var icon: String
     var category: String
     var time: Int
     
     */
    
    // MARK: 저장 (여기서는 임시로 print로 대체)

    print("""
      
      UUID: \(timer?.timerID ?? self.timerID)
      저장 기준 날짜(stop 버튼 tap한 UTC 기준): \(now)
      앱 아이콘: \(timer?.iconName ?? "아이콘 이름 없네요")
      제목/카테고리 이름: \(timer?.title ?? "카테고리명이 왜 없지")
      목표 공부 시간: \(timer?.goalTime ?? 0)분
      총 공부한 시간: \(studySeconds)초
      총 공부 시간 format 적용: \(TimerRunViewModel.format(seconds: studySeconds))
      
      (혹시 몰라서 넣은)
      총 휴식 시간: \(restSeconds)초
      총 휴식 시간 format 적용: \(TimerRunViewModel.format(seconds: restSeconds))
      """
    )
  }
}
