//
//  Schedule.swift
//  MyPill
//
//  Created by 박윤수 on 3/18/26.
//
//  이 파일은 앱 타겟 + 위젯 타겟 모두에 체크해야 합니다.
//  (SwiftUI / Foundation 만 사용 → 위젯에서 임포트 가능)


import Foundation

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

