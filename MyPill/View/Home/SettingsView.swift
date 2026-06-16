import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var schedulesViewModel: SchedulesViewModel
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showResetAlert = false

    var body: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        NavigationStack {
            List {
                Section("알림") {
                    HStack {
                        Text("알림 권한")
                        Spacer()
                        Text(statusText)
                            .foregroundStyle(statusColor)
                            .font(.subheadline)
                    }
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("시스템 설정에서 변경", systemImage: "gear")
                    }
                }

                Section("데이터") {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("모든 일정 초기화", systemImage: "trash")
                    }
                }

                Section("앱 정보") {
                    LabeledContent("버전", value: version ?? "알 수 없음")
                }
            }
            .navigationTitle("설정")
            .onAppear { refreshNotificationStatus() }
            .alert("모든 일정 초기화", isPresented: $showResetAlert) {
                Button("초기화", role: .destructive) { schedulesViewModel.resetAll() }
                Button("취소", role: .cancel) {}
            } message: {
                Text("모든 일정과 알림이 삭제됩니다. 이 작업은 되돌릴 수 없습니다.")
            }
        }
    }

    private var statusText: String {
        switch notificationStatus {
        case .authorized:    return "허용됨"
        case .denied:        return "거부됨"
        case .notDetermined: return "미설정"
        default:             return "알 수 없음"
        }
    }

    private var statusColor: Color {
        notificationStatus == .authorized ? .green : .red
    }

    private func refreshNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { notificationStatus = settings.authorizationStatus }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SchedulesViewModel())
}
