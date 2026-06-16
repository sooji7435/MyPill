import SwiftUI

struct ScheduleDetailView: View {
    @EnvironmentObject var schedulesViewModel: SchedulesViewModel

    @State var schedule: Schedule
    @State private var showEditSheet = false

    var onUpdate: ((Schedule) -> Void)?
    var onDelete: ((Schedule) -> Void)?
    var timerTick: Date = Date()   // TimelineView에서 단일 타이머로 전달

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "a h:mm"
        return f
    }()

    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 14) {
                iconBox
                infoText
                Spacer()
                checkButton
                menuButton
            }
            .padding()

            if schedule.isMissed && !schedule.isTaken {
                Divider().padding(.horizontal)
                snoozeButton
                    .padding(.bottom, 8)
                    .padding(.horizontal)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
        )
        .onAppear { checkMissed() }
        .onChange(of: timerTick) { _, _ in checkMissed() }
        .sheet(isPresented: $showEditSheet) {
            ScheduleAddView(scheduleToEdit: schedule)
        }
        .onChange(of: showEditSheet) { _, isShowing in
            guard !isShowing,
                  let updated = schedulesViewModel.schedule(withID: schedule.id) else { return }
            schedule = updated
        }
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
            HStack(spacing: 4) {
                Text(schedule.title)
                    .font(.custom("Cafe24Dongdong", size: 22))
                    .fontWeight(.semibold)
                if schedule.repeatType != .none {
                    Text(schedule.repeatType.rawValue)
                        .font(.custom("Cafe24Dongdong", size: 11))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.MainColor.opacity(0.12))
                        .foregroundStyle(Color.MainColor)
                        .clipShape(Capsule())
                }
            }

            if let desc = schedule.description, !desc.isEmpty {
                Text(desc)
                    .font(.custom("Cafe24Dongdong", size: 16))
                    .foregroundStyle(Color.gray)
            }

            HStack {
                Label(
                    Self.timeFormatter.string(from: schedule.takeTime),
                    systemImage: "clock"
                )
                .font(.custom("Cafe24Dongdong", size: 12))
                .foregroundStyle(Color.gray)

                if schedule.isMissed {
                    Text("놓침")
                        .font(.custom("Cafe24Dongdong", size: 12))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.red.opacity(0.12))
                        .foregroundStyle(.red)
                        .clipShape(Capsule())
                } else if schedule.isTaken {
                    Text("복용 완료")
                        .font(.custom("Cafe24Dongdong", size: 12))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.green.opacity(0.12))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - 체크 버튼
    private var checkButton: some View {
        Button {
            guard !schedule.isMissed else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            schedule.isTaken.toggle()
            onUpdate?(schedule)
        } label: {
            Image(systemName:
                    schedule.isTaken  ? "checkmark.circle.fill" :
                    schedule.isMissed ? "xmark.circle.fill"     : "circle")
                .font(.system(size: 26))
                .foregroundStyle(
                    schedule.isTaken  ? .green :
                    schedule.isMissed ? .red   : .gray
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 편집/삭제 메뉴
    private var menuButton: some View {
        Menu {
            Button { showEditSheet = true } label: {
                Label("편집", systemImage: "pencil")
            }
            if let onDelete {
                Button(role: .destructive) { onDelete(schedule) } label: {
                    Label("삭제", systemImage: "trash")
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)
        }
    }

    // MARK: - 스누즈 버튼
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
