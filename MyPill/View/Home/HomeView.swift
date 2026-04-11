//
//  HomeView.swift
//  PillManager
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var schedule: SchedulesViewModel
    @EnvironmentObject var calendar: CalendarViewModel

    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color.BackGroundColor, .white], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack() {
                        CalendarView(selectedDate: $selectedDate)
                            .padding()
                        scheduleSection
                    }
                }
            }
            .navigationTitle("MyPill")

        }
        
    }

    private var scheduleSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("내 일정")
                    .font(.custom("Cafe24Dongdong", size: 30))
                    .padding(.horizontal)
                Spacer()
            }
            MyMedicine()
            TimelineView(selectedDate: $selectedDate)
        }
        .padding()

    }
    
}

#Preview {
    HomeView()
        .environmentObject(SchedulesViewModel())
        .environmentObject(CalendarViewModel())
}
