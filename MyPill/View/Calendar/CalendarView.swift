import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var calendar: CalendarViewModel
    @Binding var selectedDate: Date

    var body: some View {
        VStack {
            CalendarYearMonth()
            CalendarHeader()
            CalendarBody(selectedDate: $selectedDate)
        }
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    CalendarView(selectedDate: .constant(Date()))
        .environmentObject(CalendarViewModel())
        .environmentObject(SchedulesViewModel())
}
