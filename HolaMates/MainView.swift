import SwiftUI

struct MainView: View {

    @AppStorage("appLanguage") private var appLanguage: String = "auto"

    var currentLanguage: String {
        if appLanguage == "auto" {
            let preferred = Locale.preferredLanguages.first ?? "es"
            
            if preferred.starts(with: "es") {
                return "es"
            } else {
                return "en"
            }
        }
        return appLanguage
    }

    var body: some View {
        Group {
            if currentLanguage == "en" {
                HomeViewEn()
            } else {
                HomeView()
            }
        }
        .id(currentLanguage) // 🔥 MUY IMPORTANTE
    }
}
