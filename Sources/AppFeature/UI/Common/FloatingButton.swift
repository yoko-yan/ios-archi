//
//  Created by takayuki.yokoda on 2023/07/03.
//

import Foundation
import SwiftUI

struct FloatingButton<Content: View>: View {
    var action: (() -> Void)? = nil
    @ViewBuilder var label: () -> Content

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    action?()
                }, label: {
                    label()
                })
                .frame(width: 60, height: 60)
                .background(.green)
                .cornerRadius(30.0)
                .shadow(color: .gray, radius: 3, x: 3, y: 3)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 16.0, trailing: 16.0))
            }
        }
    }
}
