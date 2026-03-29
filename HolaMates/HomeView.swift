import SwiftUI

struct HomeView: View {

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
            HowToPlayView()
        }
        .sheet(isPresented: $showLanguagePopup) {
            LanguageSelectorView()
        }
        
        .fullScreenCover(isPresented: $showGameSelector) {
            NavigationStack {
                GameSelectorView()
            }
        }
    }
}

// MARK: - HEADER

private extension HomeView {

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
                        Image(appLanguage == "en" ? "bandera_ingles" : "bandera_espana")
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

                // BOTÓN
                Button {
                    showHowToPlay = true
                } label: {
                    Text("Cómo se juega")
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

private extension HomeView {

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

private extension HomeView {

    var heroIphone: some View {
        VStack(spacing: 10) {

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 180)

            Text("""
Mejora tu cálculo mental con una forma divertida y descubre todo lo que eres capaz de conseguir.
""")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 20)   // 👈 separación respecto al texto


            Button {
                showGameSelector = true
            } label: {
                primaryButton(text: "▶ Jugar")
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

private extension HomeView {

    var heroIpad: some View {
        HStack(spacing: 48) {

            VStack(alignment: .leading, spacing: 10) {

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)

                Text("""
Mejora tu cálculo mental con una forma divertida de aprender matemáticas
y descubre todo lo que eres capaz de conseguir.
""")
                    .font(.title3)
                    .foregroundColor(.gray)

                Button {
                    showGameSelector = true
                } label: {
                    primaryButton(text: "▶ Jugar")
                }
                .padding(.top, 24)   // 👈 separación respecto al texto

                NavigationLink {
                    RankingsView()
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

private extension HomeView {

    var gallery: some View {
        let columns: [GridItem] = {
            sizeClass == .regular
            ? Array(repeating: GridItem(.flexible(), spacing: 24), count: 3)
            : [GridItem(.flexible())]
        }()

        return LazyVGrid(columns: columns, spacing: 24) {

            galleryCard(
                image: "imagen_1",
                text: "Aprende las tablas de multiplicar jugando y sin presión."
            )

            galleryCard(
                image: "imagen_2",
                text: "Competiciones escolares de cálculo mental, rápidas y divertidas."
            )

            galleryCard(
                image: "imagen_3",
                text: "Retos matemáticos para jugar en familia y aprender juntos."
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

private extension HomeView {

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

private extension HomeView {

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
                    title: "Motivación",
                    text: """
Entrena tu mente. Cada partida eres mejor:
bate tus récords y sigue avanzando.
Supérate a ti mismo.
"""
                )

                rankingCard(
                    emoji: "🏆",
                    title: "¿Qué guarda el ranking?",
                    text: """
Las 5 mejores marcas de cada juego y nivel.
Guarda el nombre al entrar en el Top 5.
"""
                )

                rankingCard(
                    emoji: "🔒",
                    title: "Privacidad y seguridad",
                    text: """
El ranking se guarda solo en este dispositivo.
"""
                )
            }

            Text("HolaMates funciona sin cuentas, sin registros y sin recoger datos personales.")
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

private extension HomeView {

    var editorialText: some View {
        VStack(spacing: 12) {

            Text("Jugar también es aprender")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)


            Text("""
Cada partida es una oportunidad para pensar un poco más rápido
y disfrutar superándote a ti mismo.
""")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: 720)
    }
}

// MARK: - CTA FINAL

private extension HomeView {

    var finalCTASection: some View {
        VStack(spacing: 24) {

            Image("empezamos_imagen")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 220)

            Button {
                showGameSelector = true
            } label: {
                primaryButton(text: "▶ Jugar")
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

private extension HomeView {

    var footerSection: some View {
        VStack {
            VStack(spacing: 6) {
                Text("© 2026 HolaMates. Sistema de juego original desarrollado por HolaMates.")
                Text("Queda prohibida la reproducción total o parcial del contenido, incluyendo el sistema de juego, sin autorización expresa por escrito.")
                Text("Todos los derechos reservados.")
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

private extension HomeView {

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

struct HowToPlayView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                // TÍTULO
                Text("Cómo se juega")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // -------- Suma 10 --------
                VStack(spacing: 14) {

                    Text("Suma 10")
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
Aparecen números en pantalla. El primero es azul. Pulsa el número que, al sumarse con él, dé 10.

Si aciertas, el número se borra.

Si fallas, aparece otro número como penalización.
""")
                        .font(.subheadline)
                            .foregroundColor(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 8)   // ⬅️ ESTA ES LA CLAVE

                        Text("⏱️ La partida acaba a los 60 segundos o cuando hay 10 números en pantalla.")
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

                    Text("Sumas,Restas, Multiplicaciones y Divisiones")
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
Aparecen operaciones en pantalla. La primera (azul) es la activa. Introduce el resultado.

Si aciertas, la operación se borra.

Si fallas, aparece una nueva operación como penalización.
""")
                        .font(.subheadline)
                            .foregroundColor(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 8)
                        

                        Text("⏱️ La partida acaba a los 90 segundos o cuando hay 10 operaciones en pantalla.")
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
                Text("💪 Intenta superarte en cada partida.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.top, 8)

                // BOTÓN
                Button {
                    dismiss()
                } label: {
                    Text("Ok, entendido")
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

struct VisualEffectBlur: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct GameSelectorView: View {

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

                Text("Elige un juego")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                VStack(spacing: 18) {

                    NavigationLink(destination: Suma10View()) {
                        selectorButton("▶ Suma 10", .blue)
                    }

                    NavigationLink(destination: SumasView()) {
                        selectorButton("▶ Sumas", .orange)
                    }

                    NavigationLink(destination: RestasView()) {
                        selectorButton("▶ Restas", .purple)
                    }

                    NavigationLink(destination: TablasView()) {
                        selectorButton("▶ Multiplicaciones", .green)
                    }

                    NavigationLink(destination: DivisionesView()) {
                        selectorButton("▶ Divisiones", .red)
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


struct LanguageSelectorView: View {

    @Environment(\.dismiss) private var dismiss
    @AppStorage("appLanguage") private var appLanguage: String = "auto"

    var body: some View {
        ZStack {
            Color(red: 11/255, green: 15/255, blue: 20/255)
                .ignoresSafeArea()

            VStack(spacing: 28) {

                Text("Seleccionar idioma")
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
