//
//  SchedulesViewModel.swift
//  MyPill
//
//  Created by 박윤수 on 7/23/25.
//
//  ⚠️ 이 파일은 앱 타겟에만 체크합니다.
//  Schedule, ScheduleStatus 모델은 Schedule.swift 에 있습니다.
//

import Foundation
import Combine

// MARK: - SchedulesViewModel
class SchedulesViewModel: ObservableObject {
    @Published private(set) var schedules: [String: [Schedule]] = [:] {
        didSet { persistSchedules() }
    }

    private let storageKey = "schedules_storage"

    private lazy var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private lazy var timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    init() {
        loadSchedules()
    }

    // MARK: - 일정 추가
    func addSchedule(title: String, takeTime: Date, description: String? = nil, iconName: String) {
        let key = dateKey(from: takeTime)
        let newSchedule = Schedule(
            title: title,
            description: description,
            iconName: iconName,
            takeTime: takeTime
        )
        schedules[key, default: []].append(newSchedule)
        NotificationManager.shared.scheduleNotification(for: newSchedule)
    }

    // MARK: - 일정 상태 업데이트 (isTaken / isMissed)
    func updateSchedule(_ updated: Schedule) {
        let key = dateKey(from: updated.takeTime)
        guard let idx = schedules[key]?.firstIndex(where: { $0.id == updated.id }) else { return }
        schedules[key]?[idx] = updated
    }

    // MARK: - 일정 삭제
    func removeSchedule(id: UUID, on date: Date) {
        let key = dateKey(from: date)
        schedules[key]?.removeAll { $0.id == id }
        if schedules[key]?.isEmpty == true {
            schedules.removeValue(forKey: key)
        }
        NotificationManager.shared.cancelNotification(for: id)
    }

    // MARK: - 30분 후로 미루기 (Snooze)
    func snoozeSchedule(_ schedule: Schedule) {
        var snoozed = schedule
        snoozed.isMissed = false
        updateSchedule(snoozed)
        NotificationManager.shared.snoozeNotification(for: schedule, minutes: 30)
    }

    // MARK: - 특정 날짜 일정 조회
    func schedules(for date: Date) -> [Schedule] {
        schedules[dateKey(from: date)] ?? []
    }

    // MARK: - 포맷 헬퍼
    func formattedTime(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }

    func dateKey(from date: Date) -> String {
        dateFormatter.string(from: date)
    }

    // MARK: - Persistence (UserDefaults)
    private func persistSchedules() {
        guard let data = try? JSONEncoder().encode(schedules) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
        SharedStore.saveToday(schedules(for: Date()))
    }

    private func loadSchedules() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([String: [Schedule]].self, from: data)
        else { return }
        schedules = decoded
    }
}
