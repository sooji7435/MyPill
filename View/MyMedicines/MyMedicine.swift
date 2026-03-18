//
//  MyMedicine.swift
//  PillManager
//

import SwiftUI

struct MyMedicine: View {
    @EnvironmentObject var schedule: SchedulesViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                addButton
                SchedulesIconView()
            }
            .padding(.horizontal)
        }
    }

    private var addButton: some View {
        NavigationLink(destination: ScheduleAddView()) {
            VStack(spacing: 6) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .padding()
                    .background(Color.appColor4.opacity(0.2))
                    .clipShape(Circle())
                    .foregroundStyle(.gray)
                Text("추가")
                    .foregroundStyle(.gray)
                    .font(.custom("Cafe24Dongdong", size: 24))
            }
        }
    }
}

#Preview {
    NavigationStack {
        MyMedicine()
            .environmentObject(SchedulesViewModel())
    }
}
