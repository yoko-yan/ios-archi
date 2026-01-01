import SwiftUI

struct HomeView: View {
    @State private var isShowAppInfoView = false

    var body: some View {
        NavigationStack {
            TimeLineView()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            isShowAppInfoView.toggle()
                        }) {
                            Image(systemName: "info")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.black.opacity(0.5),
                                                    Color.black.opacity(0.3)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 2)
                                )
                        }
                    }
                }
        }
        .sheet(isPresented: $isShowAppInfoView, content: {
            AppInfoView()
        })
        .analyticsScreen(name: "HomeView", class: String(describing: type(of: self)))
    }
}

// MARK: - Previews

#Preview {
    HomeView()
}
