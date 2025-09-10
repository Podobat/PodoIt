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
  let restRemainingSeconds: Int // 남은 휴식시간이 끝나기까지 남은 시간
  let savedAt: Date // 저장된 시간
}
