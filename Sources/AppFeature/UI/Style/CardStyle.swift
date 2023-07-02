//
//  CardStyle.swift
//
//
//  Created by takayuki.yokoda on 2023/07/02.
//

import SwiftUI

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(8)
            .clipped()
            .shadow(color: .gray.opacity(0.7), radius: 5)
            .accessibilityElement()
    }
}
