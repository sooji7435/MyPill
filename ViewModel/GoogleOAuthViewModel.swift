//
//  GoogleOAuthViewModel.swift
//  MyPill
//

import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

struct OAuthUserData {
    var oauthId: String = ""
    var idToken: String = ""
}

enum GoogleAuthError: LocalizedError {
    case notLoggedIn
    case missingRootViewController
    case signInFailed(Error)

    var errorDescription: String? {
        switch self {
        case .notLoggedIn:               return "로그인 상태가 아닙니다."
        case .missingRootViewController: return "화면을 찾을 수 없습니다."
        case .signInFailed(let e):       return e.localizedDescription
        }
    }
}

class GoogleOAuthViewModel: ObservableObject {
    @Published var oauthUserData = OAuthUserData()
    @Published var givenName: String?
    @Published var authError: GoogleAuthError?

    weak var authViewModel: AuthViewModel?

    var isSignedIn: Bool {
        GIDSignIn.sharedInstance.currentUser != nil
    }

    // MARK: - 앱 시작 시 이전 세션 복원 (껐다 켜도 로그인 유지)
    func restoreSession() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            guard let self else { return }
            if let user {
                self.givenName     = user.profile?.givenName
                self.oauthUserData = OAuthUserData(
                    oauthId: user.userID ?? "",
                    idToken: user.idToken?.tokenString ?? ""
                )
                self.authViewModel?.isLoggedIn = true
            }
            // 복원 실패 시 로그인 화면 표시
            self.authViewModel?.isLoading = false
        }
    }

    // MARK: - 유저 정보 동기화
    func checkUserInfo() {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            authError = .notLoggedIn
            return
        }
        givenName     = user.profile?.givenName
        oauthUserData = OAuthUserData(
            oauthId: user.userID ?? "",
            idToken: user.idToken?.tokenString ?? ""
        )
    }

    // MARK: - 로그인
    func signIn() {
        guard let rootVC = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController
        else {
            authError = .missingRootViewController
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { [weak self] _, error in
            guard let self else { return }
            if let error {
                self.authError = .signInFailed(error)
                return
            }
            self.checkUserInfo()
            self.authViewModel?.isLoggedIn = true
        }
    }

    // MARK: - 로그아웃
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        oauthUserData = OAuthUserData()
        givenName     = nil
        authViewModel?.isLoggedIn = false
    }
}
