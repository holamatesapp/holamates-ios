import SwiftUI

struct UpdateGateView<Content: View>: View {

    private let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    @Environment(\.openURL) private var openURL

    @State private var showUpdateAlert = false

    var body: some View {
        content
            .task {
                // Esperamos un poco más que el splash (2s)
                try? await Task.sleep(nanoseconds: 2_200_000_000)
                await checkForUpdate()
            }
            .alert("Nueva versión disponible", isPresented: $showUpdateAlert) {
                Button("Actualizar") {
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/id6757677556") {
                        openURL(url)
                    }
                }
                Button("Más tarde", role: .cancel) { }
            } message: {
                Text("Hay una nueva versión de HolaMates disponible en la App Store.")
            }
    }

    private func checkForUpdate() async {
        guard let bundleId = Bundle.main.bundleIdentifier else { return }

        let current = UpdateChecker.currentAppVersion()
        print("Versión instalada:", current)

        do {
            guard let info = try await UpdateChecker.fetchAppStoreInfo(bundleId: bundleId) else {
                print("No se recibió información de App Store")
                return
            }

            print("Versión App Store:", info.appStoreVersion)

            if UpdateChecker.isNewerVersion(appStore: info.appStoreVersion, current: current) {
                print("Hay versión nueva -> mostrar popup")
                showUpdateAlert = true
            } else {
                print("No hay versión nueva")
            }

        } catch {
            print("Error al consultar App Store:", error.localizedDescription)
        }
    }
}
