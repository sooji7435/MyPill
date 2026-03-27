//
//  LoginView.swift
//  MyPill
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject var google: GoogleOAuthViewModel
    @EnvironmentObject var auth: AuthViewModel

    @State private var showSignUp = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.BackGroundColor, .white], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                Image("appLogo")
                    .resizable()
                    .frame(width: 400, height: 400)
                
                Text("MyPill")
                    .foregroundStyle(Color.MainColor)
                    .font(.custom("Cafe24Dongdong", size: 48))

                Spacer()

                // Google 로그인 — 성공 시 googleViewModel → authViewModel.isLoggedIn = true
                GoogleSignInButton(action: google.signIn)
                    .frame(height: 50)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                
                Spacer()
            }
        }
    }

}

#Preview {
    LoginView()
        .environmentObject(GoogleOAuthViewModel())
        .environmentObject(AuthViewModel())
}
