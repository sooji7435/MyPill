//
//  CalendarView.swift
//  PillManager
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var calendar: CalendarViewModel

    @State private var selectedDay: Int = Calendar.current.component(.day, from: Date())
    @State private var monthOffset: Int = 0

    @Binding var selectedDate: Date

    var body: some View {
        VStack {
            CalendarYearMonth(monthOffset: $monthOffset)
            CalendarHeader()
            CalendarBody(selectedDay: $selectedDay, selectedDate: $selectedDate, monthOffset: $monthOffset)
        }
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    CalendarView(selectedDate: .constant(Date()))
        .environmentObject(CalendarViewModel())
}
