//
//  NotificationManager.swift
//  MyPill
//

import UserNotifications

// MARK: - 앱 전체에서 알림을 관리하는 싱글톤
final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // MARK: - 권한 요청 (앱 첫 실행 시 호출)
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error { print("알림 권한 오류: \(error)") }
            print(granted ? "알림 허용됨" : "알림 거부됨")
        }
    }

    // MARK: - 일정 알림 등록
    func scheduleNotification(for schedule: Schedule) {
        // 이미 지난 시간이면 등록하지 않음
        guard schedule.takeTime > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "💊 복용 시간입니다"
        content.body  = "\(schedule.title) 복용할 시간이에요!"
        content.sound = .default
        content.badge = 1

        // 복용 시간에 정확히 발동
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: schedule.takeTime
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: schedule.id.uuidString,   // id로 개별 취소 가능
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("알림 등록 오류: \(error)") }
        }
    }

    // MARK: - 특정 일정 알림 취소 (삭제 시 호출)
    func cancelNotification(for scheduleId: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [scheduleId.uuidString])
    }

    // MARK: - Snooze: n분 후 다시 알림
    func snoozeNotification(for schedule: Schedule, minutes: Int = 30) {
        let content = UNMutableNotificationContent()
        content.title = "💊 복용 알림 (미룸)"
        content.body  = "\(schedule.title) 복용할 시간이에요!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(minutes * 60),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "\(schedule.id.uuidString)_snooze",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - 뱃지 초기화
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
