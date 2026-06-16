import Foundation

// MARK: - RepeatType
enum RepeatType: String, Codable, CaseIterable {
    case none    = "없음"
    case daily   = "매일"
    case weekly  = "매주"
    case monthly = "매월"
}

// MARK: - Schedule
struct Schedule: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var iconName: String
    var takeTime: Date
    var isTaken: Bool
    var isMissed: Bool
    var repeatType: RepeatType
    var repeatGroupID: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        iconName: String,
        takeTime: Date,
        isTaken: Bool = false,
        isMissed: Bool = false,
        repeatType: RepeatType = .none,
        repeatGroupID: UUID? = nil
    ) {
        self.id            = id
        self.title         = title
        self.description   = description
        self.iconName      = iconName
        self.takeTime      = takeTime
        self.isTaken       = isTaken
        self.isMissed      = isMissed
        self.repeatType    = repeatType
        self.repeatGroupID = repeatGroupID
    }

    // 기존 저장 데이터와의 하위 호환성 유지
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id            = try c.decode(UUID.self,   forKey: .id)
        title         = try c.decode(String.self, forKey: .title)
        description   = try c.decodeIfPresent(String.self, forKey: .description)
        iconName      = try c.decode(String.self, forKey: .iconName)
        takeTime      = try c.decode(Date.self,   forKey: .takeTime)
        isTaken       = try c.decode(Bool.self,   forKey: .isTaken)
        isMissed      = try c.decode(Bool.self,   forKey: .isMissed)
        repeatType    = try c.decodeIfPresent(RepeatType.self, forKey: .repeatType) ?? .none
        repeatGroupID = try c.decodeIfPresent(UUID.self, forKey: .repeatGroupID)
    }
}
