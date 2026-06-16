import SwiftUI

struct CalendarBody: View {
    @EnvironmentObject var calendar: CalendarViewModel
    @EnvironmentObject var schedulesVM: SchedulesViewModel

    @Binding var selectedDate: Date

    private let columns = Array(repeating: GridItem(.adaptive(minimum: 40)), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(calendar.datesForCurrentMonth()) { value in
                if value.isPadding {
                    Color.clear.frame(height: 44)
                } else {
                    dayCell(for: value)
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    private func dayCell(for value: DateInfo) -> some View {
        let isSelected   = Calendar.current.isDate(value.date, inSameDayAs: selectedDate)
        let hasSchedules = !schedulesVM.schedules(for: value.date).isEmpty

        Button { selectedDate = value.date } label: {
            VStack(spacing: 2) {
                ZStack {
                    Circle().foregroundColor(isSelected ? Color.MainColor : .clear)
                    Text("\(value.day)")
                        .font(.cafe(30))
                        .fontWeight(.semibold)
                        .foregroundStyle(isSelected ? .white : .primary)
                }
                Circle()
                    .fill(hasSchedules ? Color.MainColor : Color.clear)
                    .frame(width: 4, height: 4)
            }
        }
    }
}

#Preview {
    CalendarBody(selectedDate: .constant(Date()))
        .environmentObject(CalendarViewModel())
        .environmentObject(SchedulesViewModel())
}
