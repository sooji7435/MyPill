//
//  MyPillApp.swift
//  MyPill
//

import SwiftUI



@main
struct MyPillApp: App {
    @StateObject private var schedulesViewModel = SchedulesViewModel()
    @StateObject private var calendarViewModel  = CalendarViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(schedulesViewModel)
                .environmentObject(calendarViewModel)
                .onAppear {
                    NotificationManager.shared.requestPermission()
                }

        }
    }
}
