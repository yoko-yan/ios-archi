//
//  Created by yoko-yan on 2023/11/08
//

import Foundation
import SwiftUI

struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        // チェックボックスの外観と動作を返す
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square" :
                "square")
                .foregroundColor(.black)
            configuration.label
        }
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
}
