import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var calendar: CalendarViewModel

    @State private var monthOffset: Int = 0

    @Binding var selectedDate: Date

    var body: some View {
        VStack {
            CalendarYearMonth(monthOffset: $monthOffset)
            CalendarHeader()
            CalendarBody(selectedDate: $selectedDate, monthOffset: $monthOffset)
        }
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    CalendarView(selectedDate: .constant(Date()))
        .environmentObject(CalendarViewModel())
        .environmentObject(SchedulesViewModel())
}
