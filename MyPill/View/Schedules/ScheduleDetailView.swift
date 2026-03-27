//
//  ScheduleDetailView.swift
//  MyPill
//

import SwiftUI

struct ScheduleDetailView: View {
    @EnvironmentObject var schedulesViewModel: SchedulesViewModel

    @State var schedule: Schedule
    var onUpdate: ((Schedule) -> Void)?

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "a h:mm"
        return f
    }()

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                iconBox
                infoText
                Spacer()
                statusButton
            }
            .padding(16)

            // missed 상태일 때만 스누즈 버튼 표시
            if schedule.isMissed && !schedule.isTaken {
                snoozeButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal)
        .onAppear { checkMissed() }
        .onReceive(timer) { _ in checkMissed() }
    }

    // MARK: - 아이콘 박스
    private var iconBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.blue.opacity(0.12))
                .frame(width: 50, height: 50)
            Image(schedule.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
        }
    }

    // MARK: - 텍스트 정보
    private var infoText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(schedule.title).font(.headline)
            if let desc = schedule.description, !desc.isEmpty {
                Text(desc).font(.subheadline).foregroundStyle(.secondary)
            }
            Text(Self.timeFormatter.string(from: schedule.takeTime))
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    // MARK: - 체크 버튼
    private var statusButton: some View {
        Button {
            guard !schedule.isMissed else { return }
            schedule.isTaken.toggle()
            onUpdate?(schedule)
        } label: {
            statusIcon
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var statusIcon: some View {
        if schedule.isTaken {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32)).foregroundStyle(.green)
        } else if schedule.isMissed {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 32)).foregroundStyle(.red)
        } else {
            Image(systemName: "circle")
                .font(.system(size: 32)).foregroundStyle(.secondary)
        }
    }

    // MARK: - 스누즈 버튼 (30분 후 알림)
    private var snoozeButton: some View {
        Button {
            schedulesViewModel.snoozeSchedule(schedule)
        } label: {
            Label("30분 후 다시 알림", systemImage: "clock.arrow.circlepath")
                .font(.caption)
                .foregroundStyle(Color.appColor4)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color.appColor4.opacity(0.1), in: Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    // MARK: - 시간 지나면 자동 missed
    private func checkMissed() {
        guard !schedule.isTaken, Date() > schedule.takeTime else { return }
        schedule.isMissed = true
        onUpdate?(schedule)
    }
}
