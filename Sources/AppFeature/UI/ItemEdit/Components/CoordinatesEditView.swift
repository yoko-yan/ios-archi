//
//  Created by yokoda.takayuki on 2023/01/29.
//

import Combine
import SwiftUI

struct CoordinatesEditView: View {
    @Binding var coordinates: String?

    var body: some View {
        VStack {
            HStack {
                Label("coordinates", systemImage: "location.circle")
                Spacer()
                TextField("未登録", text: .init(get: {
                    coordinates ?? ""
                }, set: { newValue in
                    coordinates = newValue
                }))
                .multilineTextAlignment(TextAlignment.trailing)
            }
        }
        .padding(.horizontal)
        .accentColor(.gray)
    }
}

#Preview {
    CoordinatesEditView(
        coordinates: .constant(.init("200,0,-100"))
    )
}

#Preview {
    CoordinatesEditView(
        coordinates: .constant(nil)
    )
}
