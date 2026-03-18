//
//  MainTabView.swift
//  MyPill
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        ZStack {
            TabView {
                Tab("일정", systemImage: "calendar") {
                    HomeView()
                }
                Tab("통계", systemImage: "chart.bar.fill") {
                    StatsView()
                }
                Tab("설정", systemImage: "gearshape") { SettingsView() }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tint(Color.MainColor)
    }
}


#Preview {
    MainTabView()
        .environmentObject(SchedulesViewModel())
        .environmentObject(CalendarViewModel())
        .environmentObject(GoogleOAuthViewModel())
        .environmentObject(AuthViewModel())
}
