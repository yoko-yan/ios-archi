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
                    Text("iCloud同期をオンにすると、複数のデバイス間でデータが同期されます。設定変更後は、アプリをバックグラウンドに移動してから戻ってください。")
                }

                if showRestartAlert {
                    Section {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("設定を反映するには")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text("ホーム画面に戻ってから、アプリを再度開いてください")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("設定")
        }
    }

    private func handleSyncToggle() {
        showRestartAlert = true
    }
}

#Preview {
    SettingsView()
}
