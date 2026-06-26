import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: String = "home"

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("일정", systemImage: "calendar") }
                .tag("home")
            StatsView()
                .tabItem { Label("통계", systemImage: "chart.bar.fill") }
                .tag("stats")
            SettingsView()
                .tabItem { Label("설정", systemImage: "gearshape") }
                .tag("settings")
        }
        .tint(Color.MainColor)
        .onOpenURL { _ in selectedTab = "home" }
    }
}

#Preview {
    MainTabView()
        .environmentObject(SchedulesViewModel())
        .environmentObject(CalendarViewModel())
}
