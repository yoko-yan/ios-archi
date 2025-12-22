import SwiftUI

struct SettingsView: View {
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = true
    @State private var showRestartAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("iCloud同期", isOn: $iCloudSyncEnabled)
                        .onChange(of: iCloudSyncEnabled) { _, _ in
                            handleSyncToggle()
                        }
                } header: {
                    Text("データ同期")
                } footer: {
                    Text("iCloud同期をオンにすると、複数のデバイス間でデータが同期されます。設定変更後はアプリを再起動してください。")
                }

                if showRestartAlert {
                    Section {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.orange)
                            Text("設定を反映するにはアプリを再起動してください")
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("設定")
        }
    }

    private func handleSyncToggle() {
        NotificationCenter.default.post(name: .iCloudSyncSettingChanged, object: nil)
        showRestartAlert = true
    }
}

#Preview {
    SettingsView()
}
