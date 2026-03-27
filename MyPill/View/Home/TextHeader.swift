//
//  TextHeader.swift
//  PillManager
//

import SwiftUI

struct TextHeader: View {
    @EnvironmentObject var google: GoogleOAuthViewModel

    private var displayName: String {
        google.givenName ?? "사용자"
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("반갑습니다\n\(displayName)님")
                .font(.custom("Cafe24Dongdong", size: 30))
                .multilineTextAlignment(.leading)
                .padding()
            Spacer()
        }
    }
}

#Preview {
    TextHeader()
        .environmentObject(GoogleOAuthViewModel())
}
