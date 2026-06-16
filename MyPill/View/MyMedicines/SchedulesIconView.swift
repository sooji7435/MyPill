import SwiftUI

struct SchedulesIconView: View {
    @EnvironmentObject var schedule: SchedulesViewModel

    @State private var selectedItem: Schedule?

    private var uniqueMedicines: [Schedule] {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        var seen = Set<String>()
        return schedule.schedules.values
            .flatMap { $0 }
            .filter { $0.takeTime >= startOfToday }      // 오늘 이후 일정만
            .sorted { $0.takeTime < $1.takeTime }
            .filter { seen.insert("\($0.title)_\($0.iconName)").inserted }
    }

    var body: some View {
        HStack(spacing: 12) {
            ForEach(uniqueMedicines) { item in
                VStack(spacing: 6) {
                    Image(item.iconName)
                        .resizable()
                        .frame(width: 44, height: 44)
                        .padding()
                        .background(Color.MainColor.opacity(0.2))
                        .clipShape(Circle())
                    Text(item.title)
                        .font(.custom("Cafe24Dongdong", size: 24))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(width: 80)
                .onLongPressGesture { selectedItem = item }
            }
        }
        // alert을 ForEach 밖으로 이동 → 중복 선언 방지
        .alert(item: $selectedItem) { item in
            Alert(
                title: Text("'\(item.title)' 삭제"),
                message: Text("이 약의 모든 일정이 삭제됩니다."),
                primaryButton: .destructive(Text("삭제")) {
                    schedule.removeAllSchedules(withTitle: item.title, iconName: item.iconName)
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
    }
}

#Preview {
    SchedulesIconView()
        .environmentObject(SchedulesViewModel())
}
