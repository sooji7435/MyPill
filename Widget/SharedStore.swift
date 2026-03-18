//
//  SharedStore.swift
//  MyPill
//
//  앱과 위젯이 데이터를 공유하기 위한 App Group UserDefaults 래퍼
//  Xcode → Signing & Capabilities → App Groups → "group.com.yourname.mypill" 추가 필요
//

import Foundation

enum SharedStore {
    static let groupID  = "group.com.younsu.park.mypill"
    static let key      = "widget_schedules"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: groupID) ?? .standard
    }

    // MARK: - 오늘 일정을 위젯용으로 저장
    static func saveToday(_ schedules: [Schedule]) {
        guard let data = try? JSONEncoder().encode(schedules) else { return }
        defaults.set(data, forKey: key)
    }

    // MARK: - 위젯에서 오늘 일정 읽기
    static func loadToday() -> [Schedule] {
        guard
            let data    = defaults.data(forKey: key),
            let decoded = try? JSONDecoder().decode([Schedule].self, from: data)
        else { return [] }
        return decoded
    }
}
