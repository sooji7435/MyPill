//
//  SchedulesIconView.swift
//  PillManager
//

import SwiftUI

struct SchedulesIconView: View {
    @EnvironmentObject var schedule: SchedulesViewModel

    private var allSchedules: [Schedule] {
        schedule.schedules.values
            .flatMap { $0 }
            .sorted { $0.takeTime < $1.takeTime }
    }

    var body: some View {
        HStack(spacing: 16) {
            ForEach(allSchedules) { item in
                VStack(spacing: 6) {
                    Image(item.iconName)
                        .resizable()
                        .frame(width: 44, height: 44)
                        .padding()
                        .background(Color.appColor4.opacity(0.2))
                        .clipShape(Circle())
                    Text(item.title)
                        .font(.custom("Cafe24Dongdong", size: 24))
                        .lineLimit(1)
                }
            }
        }
    }
}

#Preview {
    SchedulesIconView()
        .environmentObject(SchedulesViewModel())
}
