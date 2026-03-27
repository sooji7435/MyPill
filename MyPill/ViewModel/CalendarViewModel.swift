//
//  CalendarViewModel.swift
//  PillManager
//
//  Created by 박윤수 on 5/31/25.
//

import Foundation

// MARK: - Model
struct DateInfo: Identifiable {
    let id: String = UUID().uuidString
    let day: Int        // -1이면 빈 셀(padding)
    let date: Date

    var isPadding: Bool { day == -1 }
}

// MARK: - ViewModel
class CalendarViewModel: ObservableObject {
    @Published var currentDate: Date = Date()
    @Published var currentMonthOffset: Int = 0  // currentMonth → currentMonthOffset (의미 명확화)

    private let calendar = Calendar.current     // 매번 생성하지 않도록 저장

    // MARK: - 헤더: "yyyy년 MM월" → ["yyyy년", "MM월"]
    func yearAndMonthComponents() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        formatter.locale = .autoupdatingCurrent
        return formatter.string(from: month(for: currentMonthOffset))
            .components(separatedBy: " ")
    }

    // MARK: - offset 만큼 이동한 달의 Date 반환
    func month(for offset: Int) -> Date {
        calendar.date(byAdding: .month, value: offset, to: currentDate) ?? currentDate
    }

    // MARK: - 해당 달의 DateInfo 배열 (앞에 padding 포함)
    func datesForCurrentMonth() -> [DateInfo] {
        var days: [DateInfo] = month(for: currentMonthOffset)
            .allDatesInMonth(using: calendar)
            .map { date in
                DateInfo(day: calendar.component(.day, from: date), date: date)
            }

        // 첫 날의 요일만큼 빈 셀을 앞에 삽입 (일요일 = 1)
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? currentDate)
        let padding = (0 ..< firstWeekday - 1).map { _ in DateInfo(day: -1, date: .now) }
        days.insert(contentsOf: padding, at: 0)

        return days
    }
}

// MARK: - Date Extension
extension Date {
    /// 해당 달의 모든 날짜를 배열로 반환 (시간은 정오로 고정)
    func allDatesInMonth(using calendar: Calendar = .current) -> [Date] {
        guard
            let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: self)),
            let range = calendar.range(of: .day, in: .month, for: startDate)
        else { return [] }

        return range.compactMap { day -> Date? in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startDate) else { return nil }
            // UTC 변환으로 인한 날짜 변경 방지 → 정오로 고정
            return calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date)
        }
    }
}
