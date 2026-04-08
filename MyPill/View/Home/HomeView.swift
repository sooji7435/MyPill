//
//  HomeView.swift
//  PillManager
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var schedule: SchedulesViewModel
    @EnvironmentObject var calendar: CalendarViewModel
    @EnvironmentObject var google: GoogleOAuthViewModel

    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color.BackGroundColor, .white], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        CalendarView(selectedDate: $selectedDate)
                            .padding(.horizontal)
                        scheduleSection
                    }
                }
            }
        }
    }

    private var scheduleSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("내 일정")
                    .font(.custom("Cafe24Dongdong", size: 30))
                    .padding()
                Spacer()
                Button {
                    // TODO: 전체 보기
                } label: {
                    Text("모두보기")
                        .font(.custom("Cafe24Dongdong", size: 15))
                        .foregroundStyle(.gray)
                }
                .padding(.horizontal)
            }
            MyMedicine()
            TimelineView(selectedDate: $selectedDate)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(SchedulesViewModel())
        .environmentObject(CalendarViewModel())
        .environmentObject(GoogleOAuthViewModel())
}
