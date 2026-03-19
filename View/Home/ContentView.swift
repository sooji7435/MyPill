//
//  ContentView.swift
//  MyPill
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        Group {
            if auth.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(SchedulesViewModel())
        .environmentObject(CalendarViewModel())
        .environmentObject(GoogleOAuthViewModel())
}
