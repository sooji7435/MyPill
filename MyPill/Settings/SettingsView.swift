//
//  SettingsView.swift
//  MyPill
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var google: GoogleOAuthViewModel
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("계정") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.appColor4)
                        VStack(alignment: .leading) {
                            Text(google.givenName ?? "사용자")
                                .font(.custom("Cafe24Dongdong", size: 18))
                        }
                    }

                    Button(role: .destructive) {
                        google.signOut()
                    } label: {
                        Label("로그아웃", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }

                Section("앱 정보") {
                    LabeledContent("버전", value: "1.0.0")
                }
            }
            .navigationTitle("설정")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(GoogleOAuthViewModel())
        .environmentObject(AuthViewModel())
}
