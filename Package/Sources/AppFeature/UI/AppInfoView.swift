//
//  Created by yoko-yan on 2023/11/03
//

import SwiftUI

struct AppInfoView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                let (version, build) = vesionInfo
                HStack {
                    Text("Version", bundle: .module)
                    Spacer()
                    Text(version)
                }
                .padding()

                HStack {
                    Text("Build Version", bundle: .module)
                    Spacer()
                    Text(build)
                }
                .padding()

                Spacer()
            }
            .navigationBarTitle("", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var vesionInfo: (String, String) {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String // swiftlint:disable:this force_cast
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String // swiftlint:disable:this force_cast
        return (version, build)
    }
}

#Preview {
    AppInfoView()
}
