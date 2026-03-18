//
//  ContentView.swift
//  MyPill
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        Group {
            if auth.isLoading {
                // 앱 시작 시 세션 확인 중 — LaunchView 재활용
                LaunchView()
            } else if auth.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
        // 로그인 상태 변경 시 애니메이션
        .animation(.easeInOut(duration: 0.3), value: auth.isLoggedIn)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(SchedulesViewModel())
        .environmentObject(CalendarViewModel())
        .environmentObject(GoogleOAuthViewModel())
}
