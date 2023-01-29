//
//  ButtonStyle.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/30.
//

import SwiftUI

struct OutlineButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(configuration.isPressed ? .gray : .accentColor)
            .padding()
            .background(
                RoundedRectangle(
                    cornerRadius: 8,
                    style: .continuous
                ).stroke(Color.accentColor)
            )
    }
}
