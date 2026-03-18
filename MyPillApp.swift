//
//  MyPillApp.swift
//  MyPill
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

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

    @StateObject private var authViewModel      = AuthViewModel()
    @StateObject private var schedulesViewModel = SchedulesViewModel()
    @StateObject private var calendarViewModel  = CalendarViewModel()
    @StateObject private var googleViewModel    = GoogleOAuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(schedulesViewModel)
                .environmentObject(calendarViewModel)
                .environmentObject(googleViewModel)
                .onAppear {
                    googleViewModel.authViewModel = authViewModel
                    NotificationManager.shared.requestPermission()
                }
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
