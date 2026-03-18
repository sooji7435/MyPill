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
                Tab("내 약", systemImage: "cross.case") {
                    EmptyView()
                }
                TabSection("더보기") {
                    Tab("받은 알림", systemImage: "bolt.heart.fill") { EmptyView() }
                    Tab("설정", systemImage: "gearshape") { SettingsView() }
                }
            }
            .tabViewStyle(.sidebarAdaptable)
            .tint(Color.MainColor)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(SchedulesViewModel())
        .environmentObject(CalendarViewModel())
        .environmentObject(GoogleOAuthViewModel())
        .environmentObject(AuthViewModel())
}
