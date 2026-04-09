//
//  SchedulesIconView.swift
//  PillManager
//

import SwiftUI

struct SchedulesIconView: View {
    @EnvironmentObject var schedule: SchedulesViewModel
    
    @State var showingAlert: Bool = false
    @State private var selectedItem: Schedule?

    private var allSchedules: [Schedule] {
        schedule.schedules.values
            .flatMap { $0 }
            .sorted { $0.takeTime < $1.takeTime }
    }

    var body: some View {
        HStack(spacing: 12) {
            ForEach(allSchedules) { item in
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
                .onLongPressGesture {
                    selectedItem = item
                    showingAlert = true
                }
                .alert(item: $selectedItem) { item in
                    Alert(
                        title: Text("삭제하시겠습니까?"),
                        message: Text("삭제된 스케줄은 복구할 수 없습니다."),
                        primaryButton: .destructive(Text("삭제")) {
                            schedule.removeSchedule(id: item.id, on: item.date)
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            

        }
        
    }
}

#Preview {
    SchedulesIconView()
        .environmentObject(SchedulesViewModel())
}
