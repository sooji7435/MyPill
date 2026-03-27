//
//  StatsViewModel.swift
//  MyPill
//

import Foundation

// MARK: - 차트에 사용할 일별 통계 데이터
struct DayStat: Identifiable {
    let id = UUID()
    let label: String       // "월", "화" 등 요일 or "1일"
    let date: Date
    let taken: Int
    let total: Int

    var adherenceRate: Double {
        total == 0 ? 0 : Double(taken) / Double(total)
    }
}

class StatsViewModel: ObservableObject {
    @Published var weeklyStats: [DayStat] = []
    @Published var monthlyStats: [DayStat] = []
    @Published var overallRate: Double = 0

    private let calendar = Calendar.current

    // MARK: - SchedulesViewModel의 데이터를 받아 통계 계산
    func calculate(from schedules: [String: [Schedule]]) {
        weeklyStats  = computeWeekly(from: schedules)
        monthlyStats = computeMonthly(from: schedules)
        overallRate  = computeOverallRate(from: schedules)
    }

    // MARK: - 최근 7일 통계
    private func computeWeekly(from schedules: [String: [Schedule]]) -> [DayStat] {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        return (0..<7).compactMap { offset -> DayStat? in
            guard let date = calendar.date(byAdding: .day, value: -(6 - offset), to: Date()) else { return nil }
            let key       = dateKey(from: date)
            let dayItems  = schedules[key] ?? []
            let weekday   = calendar.component(.weekday, from: date) - 1
            return DayStat(
                label: weekdays[weekday],
                date: date,
                taken: dayItems.filter { $0.isTaken }.count,
                total: dayItems.count
            )
        }
    }

    // MARK: - 이번 달 통계 (주 단위로 묶음)
    private func computeMonthly(from schedules: [String: [Schedule]]) -> [DayStat] {
        guard
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())),
            let range = calendar.range(of: .day, in: .month, for: startOfMonth)
        else { return [] }

        // 주 단위로 그룹핑
        var weekGroups: [Int: [Schedule]] = [:]
        for day in range {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { continue }
            let weekOfMonth = calendar.component(.weekOfMonth, from: date)
            let key = dateKey(from: date)
            weekGroups[weekOfMonth, default: []].append(contentsOf: schedules[key] ?? [])
        }

        return weekGroups.sorted { $0.key < $1.key }.map { week, items in
            DayStat(
                label: "\(week)주",
                date: Date(),
                taken: items.filter { $0.isTaken }.count,
                total: items.count
            )
        }
    }

    // MARK: - 전체 복용률
    private func computeOverallRate(from schedules: [String: [Schedule]]) -> Double {
        let all   = schedules.values.flatMap { $0 }
        let past  = all.filter { $0.takeTime < Date() }
        guard !past.isEmpty else { return 0 }
        return Double(past.filter { $0.isTaken }.count) / Double(past.count)
    }

    private func dateKey(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
