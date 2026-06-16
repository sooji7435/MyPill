import SwiftUI

struct CalendarBody: View {
    @EnvironmentObject var calendar: CalendarViewModel
    @EnvironmentObject var schedulesVM: SchedulesViewModel

    @Binding var selectedDay: Int
    @Binding var selectedDate: Date
    @Binding var monthOffset: Int

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
        let isSelected    = value.day == selectedDay && calendar.currentMonthOffset == monthOffset
        let hasSchedules  = !schedulesVM.schedules(for: value.date).isEmpty

        Button {
            selectedDay  = value.day
            selectedDate = value.date
        } label: {
            VStack(spacing: 2) {
                ZStack {
                    Circle()
                        .foregroundColor(isSelected ? Color.BackGroundColor : .clear)
                    Text("\(value.day)")
                        .font(.custom("Cafe24Dongdong", size: 30))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                Circle()
                    .fill(hasSchedules ? Color.MainColor : Color.clear)
                    .frame(width: 4, height: 4)
            }
        }
    }
}

#Preview {
    CalendarBody(selectedDay: .constant(1), selectedDate: .constant(Date()), monthOffset: .constant(0))
        .environmentObject(CalendarViewModel())
        .environmentObject(SchedulesViewModel())
}
