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

    // 로그인 성공 시 AuthViewModel의 상태를 바꾸기 위해 참조 보관
    weak var authViewModel: AuthViewModel?

    var isSignedIn: Bool {
        GIDSignIn.sharedInstance.currentUser != nil
    }

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
                print(error)
                return
            }
            self.checkUserInfo()
            self.authViewModel?.isLoggedIn = true   // 로그인 성공 → 화면 전환
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        oauthUserData = OAuthUserData()
        givenName     = nil
        authViewModel?.isLoggedIn = false
    }
}
