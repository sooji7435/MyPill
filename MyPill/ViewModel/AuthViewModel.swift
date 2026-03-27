//
//  AuthViewModel.swift
//  MyPill
//

import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = true

    func signOut() {
        isLoggedIn = false
    }
}
