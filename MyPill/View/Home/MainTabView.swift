import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: String = "home"

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("일정", systemImage: "calendar", value: "home") {
                HomeView()
            }
            Tab("통계", systemImage: "chart.bar.fill", value: "stats") {
                StatsView()
            }
            Tab("설정", systemImage: "gearshape", value: "settings") {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tint(Color.MainColor)
        // 위젯 탭 시 홈 탭으로 이동 (Info.plist에 "mypill" URL 스킴 등록 필요)
        .onOpenURL { _ in selectedTab = "home" }
    }
}

#Preview {
    MainTabView()
        .environmentObject(SchedulesViewModel())
        .environmentObject(CalendarViewModel())
}
