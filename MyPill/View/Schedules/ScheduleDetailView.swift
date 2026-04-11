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
        VStack() {
            HStack(alignment: .top, spacing: 14) {
                iconBox

                infoText

                Spacer()

                    Button {
                        guard !schedule.isMissed else { return }
                        schedule.isTaken.toggle()
                        onUpdate?(schedule)
                    } label: {
                        Image(systemName:
                                schedule.isTaken
                              ? "checkmark.circle.fill"
                              : schedule.isMissed
                              ? "xmark.circle.fill"
                              : "circle")
                        .font(.system(size: 26))
                        .foregroundStyle(
                            schedule.isTaken ? .green :
                                schedule.isMissed ? .red : .gray
                        )
                    }
                    .buttonStyle(.plain)
                
            }
            .padding()

            if schedule.isMissed && !schedule.isTaken {
                Divider()
                    .padding(.horizontal)

                snoozeButton
                    .padding(.bottom, 8)
                    .padding(.horizontal)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
        )
    }

    // MARK: - 아이콘 박스
    private var iconBox: some View {
        ZStack {
            Circle()
                .fill(Color.TintColor.opacity(0.15))
                .frame(width: 76, height: 76)

            Image(schedule.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)
        }
    }

    // MARK: - 텍스트 정보
    private var infoText: some View {
        VStack(alignment: .leading) {
            Text(schedule.title)
                .font(.custom("Cafe24Dongdong", size: 22))
                .fontWeight(.semibold)

            if let desc = schedule.description, !desc.isEmpty {
                Text(desc)
                    .font(.custom("Cafe24Dongdong", size: 16))
                    .foregroundStyle(Color.gray)
            }

            HStack() {
                Label(
                    Self.timeFormatter.string(from: schedule.takeTime),
                    systemImage: "clock"
                )
                .font(.custom("Cafe24Dongdong", size: 12))
                .foregroundStyle(Color.gray)

                if schedule.isMissed {
                    Text("놓침")
                        .font(.custom("Cafe24Dongdong", size: 12))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.12))
                        .foregroundStyle(.red)
                        .clipShape(Capsule())
                } else if schedule.isTaken {
                    Text("복용 완료")
                        .font(.custom("Cafe24Dongdong", size: 12))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.12))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }
                else {
                    Text("")
                        .font(.custom("Cafe24Dongdong", size: 12))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
            }
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
        VStack {
            Spacer()
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
    }

    // MARK: - 스누즈 버튼 (30분 후 알림)
    private var snoozeButton: some View {
        Button {
            schedulesViewModel.snoozeSchedule(schedule)
        } label: {
            Label("30분 후 다시 알림", systemImage: "clock.arrow.circlepath")
                .font(.custom("Cafe24Dongdong", size: 12))
                .foregroundStyle(Color.appColor4)
                .padding(8)
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

