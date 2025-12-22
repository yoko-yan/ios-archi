import SwiftUI

struct SettingsView: View {
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = true
    @AppStorage("pendingModelContainerReinitialization") private var pendingReinitialization = false
    @State private var showRestartAlert = false
    @State private var isReloading = false
    @State private var isSyncing = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Toggle("iCloud同期", isOn: $iCloudSyncEnabled)
                            .onChange(of: iCloudSyncEnabled) { _, _ in
                                handleSyncToggle()
                            }
                            .disabled(isReloading)

                        if isReloading {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                } header: {
                    Text("データ同期")
                } footer: {
                    Text("iCloud同期をオンにすると、複数のデバイス間でデータが同期されます。設定変更後は、アプリをバックグラウンドに移動してから戻ってください。")
                }

                if iCloudSyncEnabled && !isReloading {
                    Section {
                        Button(action: {
                            Task {
                                await performManualSync()
                            }
                        }) {
                            HStack {
                                Label("今すぐ同期", systemImage: "arrow.triangle.2.circlepath")

                                Spacer()

                                if isSyncing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                        }
                        .disabled(isSyncing)
                    } footer: {
                        Text("iCloudとの同期を手動で実行します。通常は自動的に同期されますが、最新のデータを確認したい場合に使用してください。")
                    }
                }

                if showRestartAlert && !isReloading {
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
            .onAppear {
                // 再初期化が保留中の場合、ローディング状態を復元
                if pendingReinitialization {
                    isReloading = true
                    showRestartAlert = true
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                // フォアグラウンド復帰時にローディング開始
                if newPhase == .active && pendingReinitialization {
                    isReloading = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .modelContainerReinitializationStarted)) { _ in
                isReloading = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .modelContainerReinitializationCompleted)) { _ in
                isReloading = false
                showRestartAlert = false
                pendingReinitialization = false
            }
            .onReceive(NotificationCenter.default.publisher(for: .manualSyncStarted)) { _ in
                isSyncing = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .manualSyncCompleted)) { _ in
                isSyncing = false
            }
        }
    }

    private func handleSyncToggle() {
        showRestartAlert = true
        isReloading = true
        pendingReinitialization = true
    }

    private func performManualSync() async {
        await SwiftDataManager.shared.manualSync()
    }
}

#Preview {
    SettingsView()
}
