import SwiftUI

struct CalendarYearMonth: View {
    @EnvironmentObject var calendar: CalendarViewModel

    var body: some View {
        HStack {
            Button { calendar.currentMonthOffset -= 1 } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            let parts = calendar.yearAndMonthComponents()
            Text("\(parts[0]) \(parts.indices.contains(1) ? parts[1] : "")")
            Spacer()
            Button { calendar.currentMonthOffset += 1 } label: {
                Image(systemName: "chevron.right")
            }
        }
        .font(.cafe(30))
        .foregroundStyle(.primary)
        .padding()
    }
}
