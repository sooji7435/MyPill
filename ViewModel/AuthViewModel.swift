//
//  AuthViewModel.swift
//  MyPill
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth

// MARK: - 앱 전체 인증 상태 관리
class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = true   // 앱 시작 시 로그인 상태 확인 중

    init() {
        checkSession()
    }

    // MARK: - 앱 시작 시 기존 세션 확인
    private func checkSession() {
        // Firebase Auth 세션 유지 확인
        if Auth.auth().currentUser != nil {
            isLoggedIn = true
        } else if GIDSignIn.sharedInstance.currentUser != nil {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
        isLoading = false
    }

    // MARK: - 로그아웃
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        try? Auth.auth().signOut()
        isLoggedIn = false
    }
}
