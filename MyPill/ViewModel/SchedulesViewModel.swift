import Foundation
import Combine
import WidgetKit

// MARK: - SchedulesViewModel
class SchedulesViewModel: ObservableObject {
    @Published private(set) var schedules: [String: [Schedule]] = [:] {
        didSet { persistSchedules() }
    }

    private let storageKey = "schedules_storage"
    private let calendar   = Calendar.current

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

    init() { loadSchedules() }

    // MARK: - 일정 추가 (반복 지원)
    func addSchedule(title: String, takeTime: Date, description: String? = nil, iconName: String, repeatType: RepeatType = .none) {
        let groupID: UUID? = repeatType != .none ? UUID() : nil
        let dates: [Date]

        switch repeatType {
        case .none:
            dates = [takeTime]
        case .daily:
            dates = (0..<90).compactMap { calendar.date(byAdding: .day, value: $0, to: takeTime) }
        case .weekly:
            dates = (0..<52).compactMap { calendar.date(byAdding: .weekOfYear, value: $0, to: takeTime) }
        case .monthly:
            dates = (0..<12).compactMap { calendar.date(byAdding: .month, value: $0, to: takeTime) }
        }

        for date in dates {
            let s = Schedule(title: title, description: description, iconName: iconName,
                             takeTime: date, repeatType: repeatType, repeatGroupID: groupID)
            schedules[dateKey(from: date), default: []].append(s)
            if date >= Date() {
                NotificationManager.shared.scheduleNotification(for: s)
            }
        }
    }

    // MARK: - 일정 편집 (날짜 변경 포함)
    func editSchedule(old: Schedule, new: Schedule) {
        let oldKey = dateKey(from: old.takeTime)
        schedules[oldKey]?.removeAll { $0.id == old.id }
        if schedules[oldKey]?.isEmpty == true { schedules.removeValue(forKey: oldKey) }

        let newKey = dateKey(from: new.takeTime)
        schedules[newKey, default: []].append(new)

        NotificationManager.shared.cancelNotification(for: old.id)
        if new.takeTime >= Date() {
            NotificationManager.shared.scheduleNotification(for: new)
        }
    }

    // MARK: - 일정 상태 업데이트
    func updateSchedule(_ updated: Schedule) {
        let key = dateKey(from: updated.takeTime)
        guard let idx = schedules[key]?.firstIndex(where: { $0.id == updated.id }) else { return }
        schedules[key]?[idx] = updated
    }

    // MARK: - 단일 일정 삭제
    func removeSchedule(_ schedule: Schedule) {
        let key = dateKey(from: schedule.takeTime)
        schedules[key]?.removeAll { $0.id == schedule.id }
        if schedules[key]?.isEmpty == true { schedules.removeValue(forKey: key) }
        NotificationManager.shared.cancelNotification(for: schedule.id)
    }

    // MARK: - 반복 그룹 전체 삭제
    func removeGroup(groupID: UUID) {
        for key in schedules.keys {
            schedules[key]?.filter { $0.repeatGroupID == groupID }.forEach {
                NotificationManager.shared.cancelNotification(for: $0.id)
            }
            schedules[key]?.removeAll { $0.repeatGroupID == groupID }
            if schedules[key]?.isEmpty == true { schedules.removeValue(forKey: key) }
        }
    }

    // MARK: - 같은 제목+아이콘 일정 전체 삭제 (약 단위 삭제)
    func removeAllSchedules(withTitle title: String, iconName: String) {
        for key in schedules.keys {
            schedules[key]?.filter { $0.title == title && $0.iconName == iconName }.forEach {
                NotificationManager.shared.cancelNotification(for: $0.id)
            }
            schedules[key]?.removeAll { $0.title == title && $0.iconName == iconName }
            if schedules[key]?.isEmpty == true { schedules.removeValue(forKey: key) }
        }
    }

    // MARK: - 30분 후로 미루기 (Snooze)
    func snoozeSchedule(_ schedule: Schedule) {
        let originalKey = dateKey(from: schedule.takeTime)
        schedules[originalKey]?.removeAll { $0.id == schedule.id }
        if schedules[originalKey]?.isEmpty == true { schedules.removeValue(forKey: originalKey) }

        var snoozed = schedule
        snoozed.takeTime = Date().addingTimeInterval(30 * 60)
        snoozed.isMissed = false
        schedules[dateKey(from: snoozed.takeTime), default: []].append(snoozed)
        NotificationManager.shared.snoozeNotification(for: snoozed, minutes: 30)
    }

    // MARK: - 특정 날짜 일정 조회
    func schedules(for date: Date) -> [Schedule] {
        schedules[dateKey(from: date)] ?? []
    }

    // MARK: - 포맷 헬퍼
    func formattedTime(_ date: Date) -> String { timeFormatter.string(from: date) }
    func dateKey(from date: Date) -> String     { dateFormatter.string(from: date) }

    // MARK: - Persistence
    private func persistSchedules() {
        guard let data = try? JSONEncoder().encode(schedules) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
        SharedStore.saveToday(schedules(for: Date()))
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func loadSchedules() {
        guard
            let data    = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([String: [Schedule]].self, from: data)
        else { return }
        schedules = decoded
    }
}
