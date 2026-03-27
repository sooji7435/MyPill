//
//  SwiftUIView.swift
//  PillManager
//
//  Created by 박윤수 on 7/29/25.
//

import SwiftUI

struct MyDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    configuration.label
                    Spacer()
                    Image(systemName: configuration.isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.black)
                        .font(.caption.lowercaseSmallCaps())
                        .animation(nil, value: configuration.isExpanded)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if configuration.isExpanded {
                configuration.content
            }
        }
    }
}
