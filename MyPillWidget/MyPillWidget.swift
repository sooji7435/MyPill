import WidgetKit
import SwiftUI

// MARK: - 타임라인 엔트리
struct PillEntry: TimelineEntry {
    let date: Date
    let schedules: [Schedule]

    var nextSchedule: Schedule? {
        schedules
            .filter { !$0.isTaken && $0.takeTime > Date() }
            .sorted { $0.takeTime < $1.takeTime }
            .first
    }

    var adherenceRate: Double {
        let past = schedules.filter { $0.takeTime <= Date() }
        guard !past.isEmpty else { return 0 }
        return Double(past.filter { $0.isTaken }.count) / Double(past.count)
    }
}

// MARK: - 타임라인 프로바이더
struct PillProvider: TimelineProvider {
    func placeholder(in context: Context) -> PillEntry {
        PillEntry(date: Date(), schedules: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (PillEntry) -> Void) {
        completion(PillEntry(date: Date(), schedules: SharedStore.loadToday()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PillEntry>) -> Void) {
        let schedules = SharedStore.loadToday()
        let entry     = PillEntry(date: Date(), schedules: schedules)
        let nextHour  = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let nextDose  = schedules.filter { !$0.isTaken && $0.takeTime > Date() }
                                 .sorted { $0.takeTime < $1.takeTime }
                                 .first?.takeTime ?? nextHour
        completion(Timeline(entries: [entry], policy: .after(min(nextHour, nextDose))))
    }
}

// MARK: - 크기별 분기
struct MyPillWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: PillEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small 위젯
struct SmallWidgetView: View {
    let entry: PillEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "pills.fill").foregroundStyle(Color.MainColor)
                Text("MyPill").font(.caption.bold()).foregroundStyle(Color.MainColor)
            }
            Spacer()
            if let next = entry.nextSchedule {
                Text("다음 복용").font(.caption2).foregroundStyle(.secondary)
                Text(next.title).font(.headline).lineLimit(1)
                Text(next.takeTime, style: .time).font(.caption).foregroundStyle(.secondary)
            } else {
                Text("오늘 복용 완료! 🎉").font(.subheadline.bold()).foregroundStyle(Color.MainColor)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.2)).frame(height: 6)
                    Capsule().fill(Color.MainColor)
                        .frame(width: geo.size.width * entry.adherenceRate, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding()
        .containerBackground(.background, for: .widget)
        .widgetURL(URL(string: "mypill://home"))
    }
}

// MARK: - Medium 위젯
struct MediumWidgetView: View {
    let entry: PillEntry

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "a h:mm"; return f
    }()

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                ZStack {
                    Circle().stroke(Color.gray.opacity(0.15), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: entry.adherenceRate)
                        .stroke(Color.TintColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(entry.adherenceRate * 100))%")
                        .font(.caption.bold()).foregroundStyle(Color.TintColor)
                }
                .frame(width: 60, height: 60)
                Text("오늘 복용률").font(.caption2).foregroundStyle(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("오늘 일정").font(.caption.bold()).foregroundStyle(.secondary)
                if entry.schedules.isEmpty {
                    Text("일정 없음").font(.subheadline).foregroundStyle(.secondary)
                } else {
                    ForEach(entry.schedules.prefix(3)) { sch in
                        HStack(spacing: 6) {
                            Image(systemName: sch.isTaken ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(sch.isTaken ? .green : .secondary)
                                .font(.caption)
                            Text(sch.title).font(.caption).lineLimit(1)
                            Spacer()
                            Text(Self.timeFormatter.string(from: sch.takeTime))
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .containerBackground(.background, for: .widget)
        .widgetURL(URL(string: "mypill://home"))
    }
}

// MARK: - 잠금화면 원형 위젯
struct AccessoryCircularView: View {
    let entry: PillEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Text("\(Int(entry.adherenceRate * 100))%")
                    .font(.system(size: 14, weight: .bold))
                    .minimumScaleFactor(0.5)
                Text("복용률")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.clear, for: .widget)
        .widgetURL(URL(string: "mypill://home"))
    }
}

// MARK: - 잠금화면 직사각형 위젯
struct AccessoryRectangularView: View {
    let entry: PillEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label("MyPill", systemImage: "pills.fill")
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            if let next = entry.nextSchedule {
                Text(next.title)
                    .font(.caption.bold())
                    .lineLimit(1)
                Label(next.takeTime, format: .dateTime.hour().minute())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("복용 완료! 🎉")
                    .font(.caption.bold())
            }
        }
        .containerBackground(.clear, for: .widget)
        .widgetURL(URL(string: "mypill://home"))
    }
}

// MARK: - 위젯 등록
struct MyPillWidget: Widget {
    let kind = "MyPillWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PillProvider()) { entry in
            MyPillWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MyPill 복용 일정")
        .description("오늘 복용할 약과 복용률을 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

#Preview(as: .systemSmall) {
    MyPillWidget()
} timeline: {
    PillEntry(date: .now, schedules: [
        Schedule(title: "오메가3", iconName: "omega3",    takeTime: Date(),                          isTaken: true),
        Schedule(title: "비타민D", iconName: "vitamin_D", takeTime: Date().addingTimeInterval(3600), isTaken: false)
    ])
}

#Preview(as: .systemMedium) {
    MyPillWidget()
} timeline: {
    PillEntry(date: .now, schedules: [
        Schedule(title: "오메가3", iconName: "omega3",    takeTime: Date(),                          isTaken: true),
        Schedule(title: "비타민D", iconName: "vitamin_D", takeTime: Date().addingTimeInterval(3600), isTaken: false),
        Schedule(title: "철분제",  iconName: "pill",      takeTime: Date().addingTimeInterval(7200), isTaken: false)
    ])
}

#Preview(as: .accessoryCircular) {
    MyPillWidget()
} timeline: {
    PillEntry(date: .now, schedules: [
        Schedule(title: "오메가3", iconName: "omega3", takeTime: Date(), isTaken: true)
    ])
}

#Preview(as: .accessoryRectangular) {
    MyPillWidget()
} timeline: {
    PillEntry(date: .now, schedules: [
        Schedule(title: "오메가3", iconName: "omega3",    takeTime: Date(),                          isTaken: true),
        Schedule(title: "비타민D", iconName: "vitamin_D", takeTime: Date().addingTimeInterval(3600), isTaken: false)
    ])
}
