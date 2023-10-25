//
//  Created by yoko-yan on 2023/10/25
//

import Foundation
import SwiftUI

struct TextFieldClearButton: ViewModifier {
    let text: String?
    var action: (() -> Void)?

    func body(content: Content) -> some View {
        HStack {
            content
            if let text, !text.isEmpty {
                Button(action: { action?() }) {
                    Image(systemName: "delete.left")
                        .foregroundColor(Color(UIColor.opaqueSeparator))
                }
                .padding(.trailing, 8)
            }
        }
    }
}
