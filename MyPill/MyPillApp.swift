//
//  MyPillApp.swift
//  MyPill
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MyPillApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

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
