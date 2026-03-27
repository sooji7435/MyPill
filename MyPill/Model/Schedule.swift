//
//  Schedule.swift
//  MyPill
//
//  Created by 박윤수 on 3/18/26.
//
//  이 파일은 앱 타겟 + 위젯 타겟 모두에 체크해야 합니다.
//  (SwiftUI / Foundation 만 사용 → 위젯에서 임포트 가능)


import Foundation

// MARK: - ScheduleStatus
// 위젯에서도 상태 표시에 사용
enum ScheduleStatus: String, Codable {
    case taken, missed, postponed, upcoming
}

// MARK: - Schedule
// 앱과 위젯이 공유하는 핵심 모델
struct Schedule: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var iconName: String
    var takeTime: Date
    var isTaken: Bool
    var isMissed: Bool

    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        iconName: String,
        takeTime: Date,
        isTaken: Bool = false,
        isMissed: Bool = false
    ) {
        self.id          = id
        self.title       = title
        self.description = description
        self.iconName    = iconName
        self.takeTime    = takeTime
        self.isTaken     = isTaken
        self.isMissed    = isMissed
    }
}

// MARK: - Medicine
// 향후 약 상세 정보 확장용 (현재 미사용)
struct Medicine: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var dosage: String
    var time: Date
    var status: ScheduleStatus

    init(id: UUID = UUID(), name: String, dosage: String, time: Date, status: ScheduleStatus) {
        self.id     = id
        self.name   = name
        self.dosage = dosage
        self.time   = time
        self.status = status
    }
}
