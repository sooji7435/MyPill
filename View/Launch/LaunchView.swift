//
//  OnboardingView.swift
//  MyPill
//
//  Created by 박윤수 on 9/11/25.
//

import SwiftUI

struct LaunchView: View {
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.appColor1, Color.white]),
                           startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            Text("My Pill")
                .font(Font.custom("Cafe24Dongdong", size: 60))
                .foregroundColor(.color4)
                    }
                }
        }

#Preview {
    LaunchView()
}
