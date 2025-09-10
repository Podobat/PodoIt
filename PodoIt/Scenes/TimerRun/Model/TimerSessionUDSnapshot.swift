//
//  TimerSessionUDSnapshot.swift
//  PodoIt
//
//  Created by 서광용 on 9/10/25.
//

import Foundation

struct TimerSessionUDSnapshot: Codable {
  let timerID: UUID // uuid
  let isStudying: Bool // 공부 중(true)/휴식 중(false)
  let intervalStart: Date // 현재 구간(공부/휴식)이 시작된 시간 기록
  let totalStudySeconds: Int // 지금까지 누적된 총 공부 시간(초)
  
  // 휴식 상태 복구를 위한
  let restAddSeconds: Int
  let zeroMark: Bool
  let addedMark: Int?
  let addSnapshot: Int
}
