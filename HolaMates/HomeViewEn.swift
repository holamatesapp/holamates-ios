import SwiftUI

struct HomeViewEn: View {

    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var showHowToPlay = false
    @State private var showGameSelector = false
    @State private var showLanguagePopup = false
    @AppStorage("appLanguage") private var appLanguage: String = "auto"

    var body: some View {
        ZStack(alignment: .top) {

            // FONDO BASE
            Color(red: 11/255, green: 15/255, blue: 20/255)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {

                    // HERO
                    heroSection
                        .padding(.top, 56)

                    VStack(spacing: 40) {

                        gallery
                            .padding(.horizontal, 24)
                            .padding(.top, 56)

                        editorialText
                            .padding(.horizontal, 24)

                        rankingSection
                    }



                    // CTA FINAL
                    finalCTASection

                    // FOOTER
                    footerSection
                }
            }

            // HEADER
            header
        }
        .sheet(isPresented: $showHowToPlay) {
            HowToPlayViewEn()
        }
        .sheet(isPresented: $showLanguagePopup) {
            LanguageSelectorViewEn()
        }
        
        .fullScreenCover(isPresented: $showGameSelector) {
            NavigationStack {
                GameSelectorViewEn()
            }
        }
    }
}

// MARK: - HEADER

private extension HomeViewEn {

    var header: some View {
        ZStack {
            VisualEffectBlur()
                .ignoresSafeArea(edges: .top)

            HStack(spacing: 10) {

                // LOGO + BANDERA
                HStack(spacing: 4) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 22)

                    Button {
                        showLanguagePopup = true
                    } label: {
                        Image("bandera_ingles")
                            .resizable()
                            .frame(width: 26, height: 16)
                            .cornerRadius(3)
                            .padding(.vertical, 12)
                            .padding(.leading, 4)   // 👈 clave
                            .padding(.trailing, 12)
                    }
                    .contentShape(Rectangle())
                }

                Spacer()

                // HOW TO PLAY
                Button {
                    showHowToPlay = true
                } label: {
                    Text("How to play")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .frame(height: 56)
    }
}

// MARK: - HERO SECTION

private extension HomeViewEn {

    var heroSection: some View {
        VStack {
            if sizeClass == .regular {
                heroIpad
            } else {
                heroIphone
            }
        }
        .padding(.vertical, 56)
        .frame(maxWidth: .infinity)
        .background(heroBackground)
    }

    var heroBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 17/255, green: 24/255, blue: 36/255),
                Color(red: 15/255, green: 22/255, blue: 34/255)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - HERO IPHONE

private extension HomeViewEn {

    var heroIphone: some View {
        VStack(spacing: 10) {

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 180)

            Text("""
Improve your mental math in a fun and engaging way, and discover what you’re capable of.
""")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 20)   // 👈 separación respecto al texto


            Button {
                showGameSelector = true
            } label: {
                primaryButton(text: "▶ Play")
            }
            .padding(.top, 24)   // 👈 separación respecto al texto
            NavigationLink {
                RankingsView()
            } label: {
                rankingButton(text: "🏆 Ranking")
            }
            .padding(.bottom, 24)   // 👈 separación respecto al texto



            Image("imagen_principal")
                .resizable()
                .scaledToFit()
                .cornerRadius(20)
        }
        .padding(.horizontal, 24)   // 👈 AÑADE ESTA LÍNEA

    }
}

// MARK: - HERO IPAD

private extension HomeViewEn {

    var heroIpad: some View {
        HStack(spacing: 48) {

            VStack(alignment: .leading, spacing: 10) {

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)

                Text("""
Improve your mental math in a fun way
and discover everything you are capable of.
""")
                    .font(.title3)
                    .foregroundColor(.gray)

                Button {
                    showGameSelector = true
                } label: {
                    primaryButton(text: "▶ Play")
                }
                .padding(.top, 24)   // 👈 separación respecto al texto

                NavigationLink {
                    RankingsView()   // ✅ BIEN
                } label: {
                    rankingButton(text: "🏆 Ranking")
                }


                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image("imagen_principal")
                .resizable()
                .scaledToFit()
                .cornerRadius(24)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)   // 👈 AÑADE ESTA LÍNEA

    }
}

// MARK: - GALERÍA

private extension HomeViewEn {

    var gallery: some View {
        let columns: [GridItem] = {
            sizeClass == .regular
            ? Array(repeating: GridItem(.flexible(), spacing: 24), count: 3)
            : [GridItem(.flexible())]
        }()

        return LazyVGrid(columns: columns, spacing: 24) {

            galleryCard(
                image: "imagen_1",
                text: "Learn multiplication tables in a fun and pressure-free way."
            )

            galleryCard(
                image: "imagen_2",
                text: "Fast and fun mental math competitions for schools."
            )

            galleryCard(
                image: "imagen_3",
                text: "Math challenges to play with family and learn together."
            )
        }
    }

    func galleryCard(image: String, text: String) -> some View {
        VStack(spacing: 12) {

            Image(image)
                .resizable()
                .aspectRatio(4/3, contentMode: .fit)
                .cornerRadius(16)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}

private extension HomeViewEn {

    func rankingCard(emoji: String, title: String, text: String) -> some View {
        VStack(spacing: 12) {

            Text("\(emoji) \(title)")
                .font(.headline)
                .foregroundColor(.white)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}

// MARK: - RANKING SECTION

private extension HomeViewEn {

    var rankingSection: some View {
        VStack(spacing: 28) {

            Image("medallas")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 180)

            Text("Ranking")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            VStack(spacing: 20) {

                rankingCard(
                    emoji: "🎯",
                    title: "Motivation",
                    text: """
Train your mind. Every game makes you better:
beat your records and keep improving.
Challenge yourself.
"""
                )

                rankingCard(
                    emoji: "🏆",
                    title: "What does the ranking store?",
                    text: """
The top 5 scores for each game and level.
Save your name when you reach the Top 5.
"""
                )

                rankingCard(
                    emoji: "🔒",
                    title: "Privacy & Security",
                    text: """
The ranking is stored only on this device.
"""
                )
            }

            Text("HolaMates works without accounts, registrations, or personal data collection.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .frame(maxWidth: 520)
        }
        .frame(maxWidth: .infinity)          // ⬅️ ancho completo
        .padding(.horizontal, 24)            // padding interno
        .padding(.vertical, 40)
        .background(Color.white.opacity(0.05)) // fondo plano, no card
    }
}



// MARK: - TEXTO EDITORIAL

private extension HomeViewEn {

    var editorialText: some View {
        VStack(spacing: 12) {

            Text("Playing is also learning")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)


            Text("""
Every game is a chance to think a little faster
and enjoy improving yourself.
""")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: 720)
    }
}

// MARK: - CTA FINAL

private extension HomeViewEn {

    var finalCTASection: some View {
        VStack(spacing: 24) {

            Image("ready_to_play")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 220)

            Button {
                showGameSelector = true
            } label: {
                primaryButton(text: "▶ Play")
            }
        }
        .padding(.vertical, 64)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.1))
    }

    var finalBackground: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.03),
                Color.white.opacity(0.06)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - FOOTER

private extension HomeViewEn {

    var footerSection: some View {
        VStack {
            VStack(spacing: 6) {
                Text("© 2026 HolaMates. Original game system developed by HolaMates.")
                Text("Reproduction of this content, in whole or in part, is prohibited without written permission.")
                Text("All rights reserved.")
            }
            .font(.system(size: 14))
            .foregroundColor(.white.opacity(0.45))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 32)
    }
}

// MARK: - BOTONES

private extension HomeViewEn {

    func primaryButton(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: sizeClass == .regular ? 320 : 200)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.blue.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(16)
    }
    
    func rankingButton(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.black)
            .padding(.vertical, 14)
            .frame(maxWidth: sizeClass == .regular ? 320 : 200)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 255/255, green: 214/255, blue: 10/255),
                        Color(red: 255/255, green: 193/255, blue: 7/255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(16)
    }

    func secondaryButton(text: String) -> some View {
        Text(text)
            .font(.subheadline)          // ⬅️ MISMO tamaño que el primario
            .fontWeight(.bold)
            .foregroundColor(.white)
            .multilineTextAlignment(.center) // solo centrar
            // ❌ NO lineLimit
            // ❌ NO fixedSize
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Color.green, Color.green.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(16)
            .frame(maxWidth: sizeClass == .regular ? 320 : 280)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    func divisionesButton(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Color.red, Color.red.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(16)
            .frame(maxWidth: sizeClass == .regular ? 320 : 280)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    func sumasButton(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Color.orange, Color.orange.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(16)
            .frame(maxWidth: sizeClass == .regular ? 320 : 280)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    func restasButton(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Color.purple, Color.purple.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(16)
            .frame(maxWidth: sizeClass == .regular ? 320 : 280)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    



}


// MARK: - MODAL "CÓMO SE JUEGA"

struct HowToPlayViewEn: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                // TÍTULO
                Text("How to play")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // -------- Suma 10 --------
                VStack(spacing: 14) {

                    Text("Sum 10")
                        .font(.headline)
                        .foregroundColor(.yellow)
                    
                    Image("suma10numeros")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 320)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.45), radius: 10, y: 6)
                        .padding(.top, 12)

                    // TEXTO + RECUADRO JUNTOS
                    VStack(spacing: 16) {

                        Text("""
Numbers appear on the screen. The first one is blue. Tap the number that adds up to 10.

If you are correct, the number disappears.

If you are wrong, a new number appears as a penalty.
""")
                        .font(.subheadline)
                            .foregroundColor(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 8)   // ⬅️ ESTA ES LA CLAVE

                        Text("⏱️ The game ends after 60 seconds or when there are 10 numbers on the screen.")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.horizontal, 18)
                }

                Divider()
                    .background(Color.white.opacity(0.30))

                // -------- TABLAS --------
                VStack(spacing: 14) {

                    Text("Additions, Subtractions, Multiplication and Division")
                        .font(.headline)
                        .foregroundColor(.yellow)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Image("tablasnumeros")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 320)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.45), radius: 10, y: 6)
                        .padding(.top, 12)

                    // TEXTO + RECUADRO JUNTOS
                    VStack(spacing: 16) {

                        Text("""
Operations appear on the screen. The first one (blue) is active. Enter the result.

If you are correct, the operation disappears.

If you are wrong, a new operation appears as a penalty.
""")
                        .font(.subheadline)
                            .foregroundColor(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 8)
                        

                        Text("⏱️ The game ends after 90 seconds or when there are 10 operations on the screen.")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.horizontal, 18)
                }

                // FRASE FINAL
                Text("💪 Try to improve with every game.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.top, 8)

                // BOTÓN
                Button {
                    dismiss()
                } label: {
                    Text("Got it")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.85)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(16)
                }
                .padding(.top, 16)
            }
            .padding(28)
        }
        .background(
            Color(red: 11/255, green: 15/255, blue: 20/255)
                .ignoresSafeArea()
        )
    }
}



// MARK: - BLUR HEADER



struct GameSelectorViewEn: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {

        ZStack {
            Color(red: 11/255, green: 15/255, blue: 20/255)
                .ignoresSafeArea()

            VStack(spacing: 32) {

                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                    }
                }

                Text("Choose a game")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                VStack(spacing: 18) {

                    NavigationLink(destination: Suma10View()){
                        selectorButton("▶ Sum 10", .blue)
                    }

                    NavigationLink(destination: SumasView()) {
                        selectorButton("▶ Additions", .orange)
                    }

                    NavigationLink(destination: RestasView()) {
                        selectorButton("▶ Subtractions", .purple)
                    }

                    NavigationLink(destination: TablasView()) {
                        selectorButton("▶ Multiplication", .green)
                    }

                    NavigationLink(destination: DivisionesView()) {
                        selectorButton("▶ Division", .red)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }

    func selectorButton(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(18)
            .frame(maxWidth: sizeClass == .regular ? 400 : .infinity)
    }
}


struct LanguageSelectorViewEn: View {

    @Environment(\.dismiss) private var dismiss
    @AppStorage("appLanguage") private var appLanguage: String = "auto"

    var body: some View {
        ZStack {
            Color(red: 11/255, green: 15/255, blue: 20/255)
                .ignoresSafeArea()

            VStack(spacing: 28) {

                Text("Select language")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                VStack(spacing: 16) {

                    Button {
                        appLanguage = "es"
                        dismiss()
                    } label: {
                        languageButton("🇪🇸 Español")
                    }

                    Button {
                        appLanguage = "en"
                        dismiss()
                    } label: {
                        languageButton("🇬🇧 English")
                    }

                    
                }

                Spacer()
            }
            .padding(24)
        }
    }

    func languageButton(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.08))
            .cornerRadius(16)
    }
}
