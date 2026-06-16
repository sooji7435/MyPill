import SwiftUI

struct CalendarHeader: View {
    private let weekDays = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        HStack {
            ForEach(weekDays, id: \.self) { day in
                Text(day)
                    .font(.cafe(30))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(day == "일" ? Color.MainColor : Color.primary)
            }
        }
        .padding(.horizontal)
    }
}

#Preview { CalendarHeader() }
