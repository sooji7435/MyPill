import SwiftUI

struct TimelineView: View {
    @EnvironmentObject var schedule: SchedulesViewModel
    @Binding var selectedDate: Date

    @State private var timerTick = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        let dailySchedules = schedule.schedules(for: selectedDate)

        Group {
            if dailySchedules.isEmpty {
                let isToday = Calendar.current.isDateInToday(selectedDate)
                Text(isToday ? "오늘 일정이 없습니다" : "해당 날짜의 일정이 없습니다")
                    .font(.custom("Cafe24Dongdong", size: 20))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 32)
            } else {
                ForEach(dailySchedules) { sch in
                    ScheduleDetailView(
                        schedule: sch,
                        onUpdate: schedule.updateSchedule,
                        onDelete: schedule.removeSchedule,
                        timerTick: timerTick
                    )
                    .font(.custom("Cafe24Dongdong", size: 30))
                    .foregroundStyle(.primary)
                    .disclosureGroupStyle(MyDisclosureStyle())
                    .padding()
                }
            }
        }
        .onReceive(timer) { timerTick = $0 }
    }
}

#Preview {
    TimelineView(selectedDate: .constant(Date()))
        .environmentObject(SchedulesViewModel())
}
