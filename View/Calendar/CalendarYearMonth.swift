//
//  CalendarYearMonth.swift
//  PillManager
//

import SwiftUI

struct CalendarYearMonth: View {
    @EnvironmentObject var calendar: CalendarViewModel
    @Binding var monthOffset: Int

    var body: some View {
        HStack {
            Button {
                monthOffset -= 1
                calendar.currentMonthOffset -= 1
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            let parts = calendar.yearAndMonthComponents()
            Button {} label: {
                Text("\(parts[0]) \(parts.indices.contains(1) ? parts[1] : "")")
            }

            Spacer()

            Button {
                monthOffset += 1
                calendar.currentMonthOffset += 1
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .font(.custom("Cafe24Dongdong", size: 30))
        .foregroundStyle(.black)
        .padding()
    }
}
