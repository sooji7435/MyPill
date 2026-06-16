//
//  MyPillApp.swift
//  MyPill
//

import SwiftUI

@main
struct MyPillApp: App {
    @StateObject private var schedulesViewModel = SchedulesViewModel()
    @StateObject private var calendarViewModel  = CalendarViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(schedulesViewModel)
                .environmentObject(calendarViewModel)
                .onAppear {
                    NotificationManager.shared.requestPermission()
                }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                NotificationManager.shared.clearBadge()
                calendarViewModel.refreshCurrentDate()
            }
        }
    }
}
