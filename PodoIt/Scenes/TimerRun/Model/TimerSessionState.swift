//
//  TimerSessionState.swift
//  PodoIt
//
//  Created by 서광용 on 9/1/25.
//
import Foundation

struct TimerSessionState {
  var sessionStart: Date // 공부 시작한 시간 기록
  var stateStart: Date // 현재 구간(공부/휴식)이 시작된 시간 기록
  var isRunning: Bool // 공부 중(true)/휴식 중(false)
  var totalStudySeconds: Int // 지금까지 누적된 총 공부 시간(초)
  var totalRestSeconds: Int // 지금까지 누적된 총 휴식 시간(초)
}
