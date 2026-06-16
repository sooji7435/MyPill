//
//  SettingsView.swift
//  MyPill
//

import SwiftUI

struct SettingsView: View {

    var body: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        NavigationStack {
            List {
                Section("앱 정보") {
                    LabeledContent("버전", value: version ?? "알 수 없음")
                }
            }
            .navigationTitle("설정")
        }
    }
}

#Preview {
    SettingsView()
}
