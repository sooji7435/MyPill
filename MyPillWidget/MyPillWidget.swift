//
//  MyPillWidget.swift
//  MyPillWidget   ← Widget Extension 타겟에 추가
//
//  Xcode 설정:
//  1. File → New → Target → Widget Extension → 이름: MyPillWidget
//  2. 앱 타겟 + 위젯 타겟 모두 → Signing & Capabilities → App Groups → group.com.yourname.mypill 추가
//  3. Schedule.swift, SharedStore.swift 를 위젯 타겟 멤버십에 체크
//

import WidgetKit
import SwiftUI

// MARK: - 타임라인 엔트리 (위젯이 표시할 데이터 스냅샷)
struct PillEntry: TimelineEntry {
    let date: Date
    let schedules: [Schedule]

    // 다음에 복용할 일정
    var nextSchedule: Schedule? {
        schedules
            .filter { !$0.isTaken && $0.takeTime > Date() }
            .sorted { $0.takeTime < $1.takeTime }
            .first
    }

    // 오늘 전체 복용률
    var adherenceRate: Double {
        let past = schedules.filter { $0.takeTime <= Date() }
        guard !past.isEmpty else { return 0 }
        return Double(past.filter { $0.isTaken }.count) / Double(past.count)
    }
}

// MARK: - 타임라인 프로바이더 (언제 위젯을 갱신할지 결정)
struct PillProvider: TimelineProvider {
    // 위젯 갤러리 미리보기용
    func placeholder(in context: Context) -> PillEntry {
        PillEntry(date: Date(), schedules: [])
    }

    // 위젯 추가 시 스냅샷
    func getSnapshot(in context: Context, completion: @escaping (PillEntry) -> Void) {
        let entry = PillEntry(date: Date(), schedules: SharedStore.loadToday())
        completion(entry)
    }

    // 실제 타임라인 — 매 시간마다 갱신
    func getTimeline(in context: Context, completion: @escaping (Timeline<PillEntry>) -> Void) {
        let schedules = SharedStore.loadToday()
        let entry     = PillEntry(date: Date(), schedules: schedules)

        // 다음 갱신: 1시간 후 or 다음 복용 시간 중 빠른 것
        let nextHour  = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let nextDose  = schedules
            .filter { !$0.isTaken && $0.takeTime > Date() }
            .sorted { $0.takeTime < $1.takeTime }
            .first?.takeTime ?? nextHour
        let refreshAt = min(nextHour, nextDose)

        let timeline = Timeline(entries: [entry], policy: .after(refreshAt))
        completion(timeline)
    }
}

// MARK: - Small 위젯 뷰
struct SmallWidgetView: View {
    let entry: PillEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "pills.fill")
                    .foregroundStyle(Color.MainColor)
                Text("MyPill")
                    .font(.caption.bold())
                    .foregroundStyle(Color.MainColor)
            }

            Spacer()

            if let next = entry.nextSchedule {
                Text("다음 복용")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(next.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(next.takeTime, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("오늘 복용 완료! 🎉")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.MainColor)
            }

            // 복용률 프로그레스 바
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.2)).frame(height: 6)
                    Capsule()
                        .fill(Color.MainColor)
                        .frame(width: geo.size.width * entry.adherenceRate, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding()
        .containerBackground(Color.white, for: .widget)
    }
}

// MARK: - Medium 위젯 뷰
struct MediumWidgetView: View {
    let entry: PillEntry

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "a h:mm"
        return f
    }()

    var body: some View {
        HStack(spacing: 16) {
            // 왼쪽: 복용률 원형
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: entry.adherenceRate)
                        .stroke(Color.TintColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(entry.adherenceRate * 100))%")
                        .font(.caption.bold())
                        .foregroundStyle(Color.TintColor)
                }
                .frame(width: 60, height: 60)

                Text("오늘 복용률")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // 오른쪽: 일정 목록 (최대 3개)
            VStack(alignment: .leading, spacing: 6) {
                Text("오늘 일정")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                if entry.schedules.isEmpty {
                    Text("일정 없음")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(entry.schedules.prefix(3)) { sch in
                        HStack(spacing: 6) {
                            Image(systemName: sch.isTaken ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(sch.isTaken ? .green : .secondary)
                                .font(.caption)
                            Text(sch.title)
                                .font(.caption)
                                .lineLimit(1)
                            Spacer()
                            Text(Self.timeFormatter.string(from: sch.takeTime))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .containerBackground(Color.white, for: .widget)
    }
}

// MARK: - 위젯 메인
struct MyPillWidget: Widget {
    let kind = "MyPillWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PillProvider()) { entry in
            // 위젯 크기별 분기
            GeometryReader { geo in
                if geo.size.width < 180 {
                    SmallWidgetView(entry: entry)
                } else {
                    MediumWidgetView(entry: entry)
                }
            }
        }
        .configurationDisplayName("MyPill 복용 일정")
        .description("오늘 복용할 약과 복용률을 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    MyPillWidget()
} timeline: {
    PillEntry(date: .now, schedules: [
        Schedule(title: "오메가3", iconName: "fish.fill", takeTime: Date(), isTaken: true),
        Schedule(title: "비타민D", iconName: "sun.max.fill", takeTime: Date().addingTimeInterval(3600), isTaken: false)
    ])
}

#Preview(as: .systemSmall) {
    MyPillWidget()
} timeline: {
    PillEntry(date: .now, schedules: [
        Schedule(title: "오메가3", iconName: "fish.fill", takeTime: Date(), isTaken: true),
        Schedule(title: "비타민D", iconName: "sun.max.fill", takeTime: Date().addingTimeInterval(3600), isTaken: false)
    ])
}

#Preview(as: .systemMedium) {
    MyPillWidget()
} timeline: {
    PillEntry(date: .now, schedules: [
        Schedule(title: "오메가3", iconName: "fish.fill", takeTime: Date(), isTaken: true),
        Schedule(title: "비타민D", iconName: "sun.max.fill", takeTime: Date().addingTimeInterval(3600), isTaken: false),
        Schedule(title: "철분제", iconName: "bolt.fill", takeTime: Date().addingTimeInterval(7200), isTaken: false)
    ])
}

#Preview(as: .systemLarge) {
    MyPillWidget()
} timeline: {
    PillEntry(date: .now, schedules: [
        Schedule(title: "오메가3", iconName: "fish.fill", takeTime: Date(), isTaken: true),
        Schedule(title: "비타민D", iconName: "sun.max.fill", takeTime: Date().addingTimeInterval(3600), isTaken: false),
        Schedule(title: "철분제", iconName: "bolt.fill", takeTime: Date().addingTimeInterval(7200), isTaken: false),
        Schedule(title: "마그네슘", iconName: "leaf.fill", takeTime: Date().addingTimeInterval(10800), isTaken: false)
    ])
}

#Preview("All Sizes") {
    ScrollView {
        VStack(spacing: 20) {
            Text("Small").font(.caption).foregroundStyle(.secondary)
            SmallWidgetView(entry: PillEntry(date: .now, schedules: [
                Schedule(title: "오메가3", iconName: "fish.fill", takeTime: Date(), isTaken: true),
                Schedule(title: "비타민D", iconName: "sun.max.fill", takeTime: Date().addingTimeInterval(3600), isTaken: false)
            ]))
            .frame(width: 155, height: 155)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Text("Medium").font(.caption).foregroundStyle(.secondary)
            MediumWidgetView(entry: PillEntry(date: .now, schedules: [
                Schedule(title: "오메가3", iconName: "fish.fill", takeTime: Date(), isTaken: true),
                Schedule(title: "비타민D", iconName: "sun.max.fill", takeTime: Date().addingTimeInterval(3600), isTaken: false),
                Schedule(title: "철분제", iconName: "bolt.fill", takeTime: Date().addingTimeInterval(7200), isTaken: false)
            ]))
            .frame(width: 329, height: 155)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding()
    }
}

