//
//  SettingsView.swift
//  MyPill
//

import SwiftUI

struct SettingsView: View {

    var body: some View {
        NavigationStack {
            List {
                Section("앱 정보") {
                    LabeledContent("버전", value: "2.0.0")
                }
            }
            .navigationTitle("설정")
        }
    }
}

#Preview {
    SettingsView()
}
