//
//  TimelineView.swift
//  PillManager
//

import SwiftUI

struct TimelineView: View {
    @EnvironmentObject var schedule: SchedulesViewModel
    @Binding var selectedDate: Date

    var body: some View {
        let dailySchedules = schedule.schedules(for: selectedDate)

        if dailySchedules.isEmpty {
            Text("오늘 일정이 없습니다")
                .font(.custom("Cafe24Dongdong", size: 20))
                .foregroundStyle(.secondary)
                .padding(.vertical, 32)
        } else {
            ForEach(dailySchedules) { sch in
                DisclosureGroup(sch.title) {
                    ScheduleDetailView(schedule: sch, onUpdate: schedule.updateSchedule)
                }
                .font(.custom("Cafe24Dongdong", size: 30))
                .foregroundStyle(.black)
                .disclosureGroupStyle(MyDisclosureStyle())
                .padding()
                .background(Color.BackGroundColor, in: RoundedRectangle(cornerRadius: 20))
            }
            .animation(.spring(), value: schedule.schedules)
            .padding(.top)

        }
        
    }
}

#Preview {
    TimelineView(selectedDate: .constant(Date()))
        .environmentObject(SchedulesViewModel())
}
