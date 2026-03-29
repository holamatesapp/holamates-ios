import Foundation

struct UpdateChecker {

    struct Result {
        let appStoreVersion: String
    }

    static func fetchAppStoreInfo(bundleId: String) async throws -> Result? {

        // 🔥 URL normal (la dejamos así para ver el problema real)
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)") else {
            return nil
        }

        // 🔥 Capturamos también la response
        let (data, response) = try await URLSession.shared.data(from: url)

        // =========================
        // 🧪 DEBUG (CLAVE)
        // =========================

        print("📦 JSON RAW:")
        print(String(data: data, encoding: .utf8) ?? "no data")

        if let httpResponse = response as? HTTPURLResponse {
            print("🌐 STATUS:", httpResponse.statusCode)
            print("📡 HEADERS:", httpResponse.allHeaderFields)
        }

        // =========================
        // 📦 PARSE NORMAL
        // =========================

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let results = json["results"] as? [[String: Any]],
            let first = results.first,
            let version = first["version"] as? String
        else {
            return nil
        }

        print("✅ VERSION EXTRAIDA:", version)

        return Result(appStoreVersion: version)
    }

    // =========================
    // 📱 VERSION LOCAL
    // =========================

    static func currentAppVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }

    // =========================
    // 🔍 COMPARACIÓN
    // =========================

    static func isNewerVersion(appStore: String, current: String) -> Bool {
        appStore.compare(current, options: .numeric) == .orderedDescending
    }
}
