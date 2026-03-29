import SwiftUI

struct ContentView: View {

    @State private var showSplash = true

    var body: some View {
            ZStack {
                if showSplash {
                    SplashView {
                        showSplash = false
                    }
                } else {
                    MainView()
                }
            }
    }
}

// MARK: - Splash

struct SplashView: View {

    let onFinish: () -> Void

    var body: some View {
        ZStack {
            Color(
                red: 11.0 / 255.0,
                green: 15.0 / 255.0,
                blue: 20.0 / 255.0
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)   // ajusta si quieres
                    .accessibilityHidden(true)

             
            }

        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onFinish()
            }
        }
    }
}
