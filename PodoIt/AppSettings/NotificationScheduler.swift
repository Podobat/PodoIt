//
//  NotificationScheduler.swift
//  PodoIt
//
//  Created by 서광용 on 9/9/25.
//

import UserNotifications

enum NotificationID {
  static let goalTimeEnd = "goal"
  static let restingTimeEnd = "rest"
}

enum NotificationTitle {
  static let goalTimeEnd = "목표한 공부시간을 끝냈습니다."
  static let restingTimeEnd = "휴식 시간이 끝났습니다."
}

enum NotificationBody {
  static let goalTimeEnd = "추카해용"
  static let restingTimeEnd = "공부하쉐요"
}

enum NotificationScheduler {
  // MARK: 타이머 예약

  static func scheduleEnd(
    id: String,
    title: String,
    body: String,
    date: Date,
    isMuted: Bool = false,
    soundName: String? = nil
  ) {
    // 중복 방지: 일시정지, 종료시간 재계산 등 타이머가 다시 예약되면 기존의 예약 삭제
    // currnet: 싱글톤 인스턴스를 가져오는 정적 메서드. 등록/취소는 항상 1개만 존재하는 이 알림 상태에 접근한다 생각
    let center = UNUserNotificationCenter.current()
    // 울리지 않은 기존 알림중(에약 상태인), identifier(여기서는 id)를 가진 예약을 취소하는 메서드
    center.removePendingNotificationRequests(withIdentifiers: [id])
    
    // 지금부터 종료시간까지 남은 초 계산
    let seconds = date.timeIntervalSinceNow
    // 이미 지난 시간은 예약하지 않음 (없겠지만 혹시나)
    guard seconds > 0 else { return }
    
    // UNMutableNotificationContent: 로컬/푸시 알람의 내용을 담는 객체. 알림 내용 구성
    let content = UNMutableNotificationContent()
    content.title = title // 알람 배너 제목
    content.body = body // 제목 아래 설명 텍스트
    if isMuted { // 음소거라면
      content.sound = nil // 무음!
    } else { // 음소거가 아니라 소리가 나야한다면
      content.sound = .default // 재생할 소리 (기본 "띵"소리. 짧게 1번)
    }
    
    // 로컬 알림이 울리는 조건을 정의
    // timeInterval: 지금부터 seconds 뒤 알람이 울림. (0초는 문제 생길 수 있다해서 max 1초)
    // repeats: 반복 여부 설정 (false. 한 번만 울리도록)
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
    
    // 알림 예약 (id지정, 알림 content, 울리는 시간 trigger)
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    center.add(request) { error in // 위에서 만든 current 싱글톤에 예약 등록.
      if let error = error {
        print("알림 등록에 실패함: \(error)")
      } else {
        print("알림 등록 성공!")
      }
    }
  }
  
  // MARK: 타이머 취소

  // 예약할때 중복은 예약된게 생겨야 지워지지만, stop이나 공부 <-> 휴식 상태에서 지우기 위해서 필요
  static func cancel(id: String) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
  }
}
