//
//  LoginView.swift
//  MyPill
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject var google: GoogleOAuthViewModel
    @EnvironmentObject var auth: AuthViewModel

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showSignUp = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [.appColor1, .white], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                Text("MyPill")
                    .font(.custom("Cafe24Dongdong", size: 60))
                    .foregroundStyle(Color.appColor4)

                Image("pill")
                    .resizable()
                    .frame(width: 250, height: 250)

                Spacer().frame(height: 20)

                emailField
                passwordField
                loginButton
                signUpButton

                Spacer()
                Divider().padding()

                // ✅ Google 로그인 — 성공 시 googleViewModel → authViewModel.isLoggedIn = true
                GoogleSignInButton(action: google.signIn)
                    .frame(height: 50)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
            }
        }
        .alert(
            "로그인 오류",
            isPresented: Binding(
                get: { google.authError != nil },
                set: { if !$0 { google.authError = nil } }
            )
        ) {
            Button("확인", role: .cancel) { google.authError = nil }
        } message: {
            Text(google.authError?.localizedDescription ?? "")
        }
    }

    private var emailField: some View {
        TextField("Email", text: $email)
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal)
    }

    private var passwordField: some View {
        SecureField("Password", text: $password)
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
            .padding(.horizontal)
    }

    private var loginButton: some View {
        Button {
            // TODO: Firebase 이메일 로그인 구현
            // Auth.auth().signIn(withEmail: email, password: password)
        } label: {
            Text("Login")
                .font(.headline)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.appColor4)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }

    private var signUpButton: some View {
        Button { showSignUp = true } label: {
            Text("Don't have an account? Sign Up")
                .foregroundStyle(Color.appColor4)
        }
        .sheet(isPresented: $showSignUp) {
            // TODO: SignUpView()
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(GoogleOAuthViewModel())
        .environmentObject(AuthViewModel())
}
