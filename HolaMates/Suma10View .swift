import SwiftUI

enum GameLevel: String, CaseIterable {
    case initLevel = "Iniciación"
    case easy = "Fácil"
    case normal = "Medio"
    case hard = "Difícil"
}

enum GameEndReason {
    case time
    case fail
}

enum GamePhase {
    case idle
    case playing
    case ending
    case ended
}


struct Suma10View: View {
    
    @Environment(\.dismiss) private var dismiss
    
    
    // MARK: - Estado del juego
    @State private var value: String = "—"
    @State private var hits: Int = 0
    @State private var running: Bool = false
    @State private var timer: Timer? = nil
    @State private var startTime: Date?
    @State private var timeTimer: Timer? = nil
    @State private var gameOverIndex: Int? = nil
    @State private var showGameOver: Bool = false
    @State private var canCloseGameOver: Bool = false
    @State private var endReason: GameEndReason? = nil
    @State private var ranking: [RankingEntry] = []
    @State private var navigateToRanking = false
    @State private var timeProgress: Double = 0
    @State private var phase: GamePhase = .idle


    

    
    
    
    
    
    
    // 🏆 Ranking
    @State private var qualifiesForRanking: Bool = false
    @State private var currentChallenge: ChallengeID? = nil
    @State private var isNewNumberOne: Bool = false
    @State private var showAddRanking: Bool = false
    @State private var lastRankingIndex: Int = 0
    
    
    
    
    // ℹ️ INFO
    @State private var showInfo: Bool = false
    
    @State private var level: GameLevel = .normal
    
    // MARK: - Constantes
    private let maxLen = 10
    private let gameTime: Double = 60
    
    // MARK: - Layout
    private let bubbleH: CGFloat = 45
    private let bubbleSpacing: CGFloat = 8
    
    
    // 👉 DESTINO DE NAVEGACIÓN AL RANKING
    private var rankingDestination: some View {
        Group {
            if let challenge = currentChallenge {
                RankingView(
                    challenge: challenge,
                    ranking: ranking,
                    highlightedIndex: lastRankingIndex
                )
                
            } else {
                EmptyView()
            }
        }
    }
    
    
    
    var body: some View {
        ZStack {
            
            Color(red: 11/255, green: 15/255, blue: 20/255)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // 🔼 HEADER (idéntico a Multiplicaciones)
                VStack(spacing: 20) {
                    
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Circle())
                        }
                        
                        
                        
                        
                        Spacer()
                        
                        Button {
                            showInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                    
                    Text("Suma 10")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding()
                
                // CONTENIDO
                VStack(spacing: 24) {
                    
                    Picker("Nivel", selection: $level) {
                        ForEach(GameLevel.allCases, id: \.self) { lvl in
                            Text(lvl.rawValue).tag(lvl)
                        }
                    }
                    .pickerStyle(.menu)
                    .foregroundColor(.white)
                    .disabled(running)
                    
                    Text("Aciertos: \(hits)")
                        .foregroundColor(.gray)
                    
                    TimelineBar(
                        progress: timeProgress,
                        isFail: endReason == .fail,
                        isTimeUp: endReason == .time
                    )
                    
                    
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    
                    // 🔵 BURBUJAS
                    GeometryReader { geo in
                        let totalWidth = geo.size.width * 0.9
                        let bubbleW = (totalWidth - bubbleSpacing * 9) / 10
                        
                        ZStack {
                            HStack(spacing: bubbleSpacing) {
                                ForEach(0..<10, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white.opacity(0.10))
                                        .frame(width: bubbleW, height: bubbleH)
                                }
                            }
                            
                            HStack(spacing: bubbleSpacing) {
                                ForEach(0..<10, id: \.self) { slot in
                                    overlaySlot(
                                        at: slot,
                                        bubbleW: bubbleW,
                                        bubbleH: bubbleH
                                    )
                                }
                            }
                        }
                        .frame(width: totalWidth, height: bubbleH)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: bubbleH)
                    
                    Spacer()
                    
                    keypad
                    
                    
                    
                    
                    
                    // ▶ Play
                    GeometryReader { geo in
                        Button {
                            startGame()
                            
                        } label: {
                            Text("▶ Play")
                                .font(.title3)
                                .fontWeight(.bold)
                                .frame(width: geo.size.width * 0.9)
                                .padding()
                                .background(running ? Color.gray.opacity(0.4) : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        .disabled(running)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 56)
                    
                }
                .padding()
            }
            
            // POPUPS
            if showGameOver {
                gameOverOverlay
            }
            
            if showInfo {
                infoOverlay
            }
            
        }
        
        
        .navigationDestination(isPresented: $navigateToRanking) {
                    rankingDestination
                }
        
        
        .navigationBarHidden(true)
        .onDisappear {
            timer?.invalidate()
        }
        
        
        .sheet(isPresented: $showAddRanking) {
            if let challenge = currentChallenge {
                AddRankingEntryView(
                    challenge: challenge,
                    score: hits
                ) { newRanking, index in
                    ranking = newRanking
                    lastRankingIndex = index
                    
                    showAddRanking = false
                    
                    // 🚀 AQUÍ SE NAVEGA
                    DispatchQueue.main.async {
                        navigateToRanking = true
                    }
                }
            }
        }
        
        
        
        
        
        
        
        
        
        
    }
    
    // MARK: - BURBUJAS
    
    @ViewBuilder
    private func overlaySlot(
        at index: Int,
        bubbleW: CGFloat,
        bubbleH: CGFloat
    ) -> some View {
        
        let chars = Array(value)
        let activeSlot = 10 - chars.count
        

        let lastVisibleSlot = activeSlot + chars.count - 1
        let charIndex = index - activeSlot
        
        if charIndex >= 0 && charIndex < chars.count {

            let char: Character = {
                if charIndex >= 0 && charIndex < chars.count {
                    return chars[charIndex]
                } else {
                    return " "
                }
            }()

            Text(String(char))

                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .frame(width: bubbleW, height: bubbleH)
                .background(
                    (!running && index == gameOverIndex) ? Color.red :
                    (running && index == activeSlot) ? Color.blue :
                    Color.white.opacity(0.15)
                )











            
            
            
                .cornerRadius(14)
        } else {
            Color.clear
                .frame(width: bubbleW, height: bubbleH)
        }
    }
    
    // MARK: - TECLADO
    
    private var keypad: some View {
        VStack(spacing: 12) {
            ForEach([[1,2,3],[4,5,6],[7,8,9]], id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { n in
                        Button {
                            press(n)
                        } label: {
                            Text("\(n)")
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(width: 80, height: 70)
                                .background(Color(red: 24/255, green: 34/255, blue: 53/255))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - LÓGICA
    
    private func updateTimeProgress() {
        guard let startTime else { return }
        
        // ⛔️ si el juego ya terminó, NO tocar el progreso
        guard running else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        timeProgress = min(elapsed / gameTime, 1)
    }
    
    
    
    private func startGame() {
        phase = .playing
        endReason = nil
        showGameOver = false
        timer?.invalidate()
        hits = 0
        value = rand1to9()
        running = true
        gameOverIndex = nil

        startTime = Date()
        scheduleTick(interval: levelIntervals().start)
        
        timeProgress = 0
        updateTimeProgress()
        
        
        timeTimer?.invalidate()
        timeTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateTimeProgress()
        }
        
    }
    
    private func tick() {
        guard running else { return }
        updateTimeProgress()
        
        // ⏱️ FIN POR TIEMPO
        if timeProgress >= 1 {
            endGame(reason: .time)
            return
        }
        
        // ❌ FIN POR FALLO
        if value.count >= maxLen {
            endGame(reason: .fail)
            return
        }
        
        value += rand1to9()
        scheduleTick(interval: currentInterval())
    }
    
    
    private func currentInterval() -> Double {
        guard let startTime else { return levelIntervals().start }
        let elapsed = Date().timeIntervalSince(startTime)
        let t = min(elapsed / gameTime, 1)
        let intervals = levelIntervals()
        return intervals.start - t * (intervals.start - intervals.end)
    }
    
    private func scheduleTick(interval: Double) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            tick()
        }
    }
    
    private func press(_ n: Int) {
        guard running,
              let firstChar = value.first,
              let first = Int(String(firstChar)) else { return }
        
        if first + n == 10 {
            hits += 1
            value.removeFirst()
            if value.isEmpty {
                value = rand1to9()
            }
        } else {
            value += rand1to9()
            
            if value.count >= maxLen {
                endGame(reason: .fail)
                return
            }
            
            // 🔵 REINICIO DE INTERVALO (igual que Web)
            timer?.invalidate()
            scheduleTick(interval: currentInterval())
        }

    }
    
    private func endGame(reason: GameEndReason) {

        // 🔴 calcular el slot visible ANTES de tocar nada
        let chars = Array(value)
        let activeSlot = 10 - chars.count

        gameOverIndex = activeSlot

        phase = .ending
        running = false
        timer?.invalidate()
        timeTimer?.invalidate()
        timeTimer = nil

        if reason == .time {
            timeProgress = 1
        }

        endReason = reason

        let challenge = currentChallengeID()
        currentChallenge = challenge

        ranking = RankingManager.shared.loadRanking(for: challenge)

        qualifiesForRanking = RankingManager.shared
            .qualifiesForTop5(score: hits, challenge: challenge)

        isNewNumberOne = ranking.first.map { hits >= $0.score } ?? true

        phase = .ended

        canCloseGameOver = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            canCloseGameOver = true
        }

        showGameOver = true
    }

    
    
    
    
    private func rand1to9() -> String {
        String(Int.random(in: 1...9))
    }
    
    private func levelIntervals() -> (start: Double, end: Double) {
        switch level {
        case .initLevel: return (3.5, 3.0)
        case .easy: return (1.8, 0.9)
        case .normal: return (1.5, 0.5)
        case .hard: return (1.2, 0.35)
        }
    }
    
    private func currentChallengeID() -> ChallengeID {
        switch level {
        case .initLevel:
            return .suma10_iniciacion
        case .easy:
            return .suma10_facil
        case .normal:
            return .suma10_normal
        case .hard:
            return .suma10_dificil
        }
    }
    
    // MARK: - POPUP GAME OVER
    
    
    private func mensajeAnimo(_ hits: Int) -> String {
        
        if hits == 0  { return "No pasa nada 💙 Vamos a intentarlo otra vez" }
        if hits == 1  { return "Buen intento 💪 Cada partida cuenta" }
        if hits == 2  { return "¡Bien! Poco a poco 🙂" }
        if hits == 3  { return "¡Muy bien! Sigue así 👏" }
        if hits == 4  { return "¡Muy bien! Vas mejorando 🚀" }
        if hits == 5  { return "¡Muy bien! Buen comienzo 😄" }
        if hits == 6  { return "¡Muy bien! Cada vez más rápido 🔥" }
        if hits == 7  { return "¡Genial! Buena concentración 🧠" }
        if hits == 8  { return "¡Genial! Ritmo sólido 💪" }
        if hits == 9  { return "¡Muy bien! Buen control 👌" }

        // 🔹 A partir de 10: ya se nota progreso real
        if hits == 10 { return "¡Muy bien! Se nota el progreso 😄" }
        if hits == 11 { return "¡Muy bien! Cada vez más seguro 🙂" }
        if hits == 12 { return "¡Genial! Buen ritmo 🚀" }
        if hits == 13 { return "¡Genial! Buen control 👏" }
        if hits == 14 { return "¡Muy bien! Vas fuerte 💪" }

        // 🔹 15–19: jugador sólido
        if hits == 15 { return "¡Muy bien! Ritmo constante 💪" }
        if hits == 16 { return "¡Muy bien! Buena seguridad 🙂" }
        if hits == 17 { return "¡Genial! Gran concentración 🧠" }
        if hits == 18 { return "¡Genial! Buen control 👏" }
        if hits == 19 { return "¡Muy bien! Preparado para más 🚀" }

        // 🔥 A partir de 20: nivel alto
        if hits == 20 { return "¡Brutal! Nivel altísimo 🔥" }
        if hits == 21 { return "¡Brutal! Muy sólido 💥" }
        if hits == 22 { return "¡Bestial! Ritmo brutal 🔥" }
        if hits == 23 { return "¡Bestial! Gran dominio 💪" }
        if hits == 24 { return "¡Bestial! Muy fuerte 🧠" }

        // 🏆 25–29: nivel pro
        if hits == 25 { return "¡Nivel pro! Muy rápido 🚀" }
        if hits == 26 { return "¡Nivel pro! Gran control 🎯" }
        if hits == 27 { return "¡Nivel pro! Sin fallos 💥" }
        if hits == 28 { return "¡Nivel pro! Precisión total 🎯" }
        if hits == 29 { return "¡Nivel pro! Impresionante 🌟" }

        // 🏆 30–34: sobresaliente
        if hits == 30 { return "¡Sobresaliente! Ritmo altísimo 🏆" }
        if hits == 31 { return "¡Sobresaliente! Mucha precisión 🎯" }
        if hits == 32 { return "¡Sobresaliente! Gran seguridad 😎" }
        if hits == 33 { return "¡Sobresaliente! Muy sólido 💪" }
        if hits == 34 { return "¡Sobresaliente! Nivel top 🌟" }

        // 🤖 35–39: máquina
        if hits == 35 { return "¡Máquina! Esto ya es otro nivel 🤖" }
        if hits == 36 { return "¡Máquina! Ritmo brutal 🔥" }
        if hits == 37 { return "¡Máquina! Gran dominio 🧠" }
        if hits == 38 { return "¡Máquina! Partidaza 💥" }
        if hits == 39 { return "¡Máquina! Imparable 🚀" }

        // 👑 40–44: leyenda
        if hits == 40 { return "¡Leyenda! Partida histórica 👑" }
        if hits == 41 { return "¡Leyenda! Dominio total 😎" }
        if hits == 42 { return "¡Leyenda! Precisión increíble 🎯" }
        if hits == 43 { return "¡Leyenda! Ritmo perfecto 🌟" }
        if hits == 44 { return "¡Leyenda! Nivel máximo 🏆" }

        // 🌟 45–49: élite
        if hits == 45 { return "¡Élite! Juego perfecto 🔥" }
        if hits == 46 { return "¡Élite! Control absoluto 🧠" }
        if hits == 47 { return "¡Élite! Sin errores 💥" }
        if hits == 48 { return "¡Élite! Brutal 😎" }
        if hits == 49 { return "¡Élite! Imparable 🚀" }

        // 🚀 50–59: fuera de lo normal
        if hits == 50 { return "¡Increíble! Esto es otro planeta 🤯" }
        if hits == 51 { return "¡Increíble! Nivel extremo 🔥" }
        if hits == 52 { return "¡Increíble! Dominio total 💪" }
        if hits == 53 { return "¡Increíble! Precisión perfecta 🎯" }
        if hits == 54 { return "¡Increíble! Ritmo demencial 🚀" }
        if hits == 55 { return "¡Increíble! Mente de acero 🧠" }
        if hits == 56 { return "¡Increíble! Sin palabras 🤯" }
        if hits == 57 { return "¡Increíble! Maestro absoluto 🏆" }
        if hits == 58 { return "¡Increíble! Juego perfecto 🔥" }
        if hits == 59 { return "¡Increíble! Casi imposible 😎" }
        
        if hits == 60 { return "👑 LEYENDA SUPREMA 👑 Dominio total 🤯🔥" }
        if hits == 61 { return "👑 Leyenda suprema… esto es muy serio 😎" }
        if hits == 62 { return "👑 Ritmo de auténtico campeón 🏆" }
        if hits == 63 { return "👑 Precisión brutal 🎯" }
        if hits == 64 { return "👑 Control absoluto 🧠" }
        if hits == 65 { return "👑 Nivel imposible para la mayoría 🚀" }
        if hits == 66 { return "👑 Esto ya es otra liga 🔥" }
        if hits == 67 { return "👑 Sin errores, sin miedo 💪" }
        if hits == 68 { return "👑 Partida legendaria 😎" }
        if hits == 69 { return "👑 Dominio total del juego 🏆" }
        
        if hits == 70 { return "🚀 NIVEL MÍTICO 🚀 Impresionante 🤯" }
        if hits == 71 { return "🚀 Velocidad y precisión perfectas 🔥" }
        if hits == 72 { return "🚀 Esto roza lo imposible 😱" }
        if hits == 73 { return "🚀 Mente matemática total 🧠" }
        if hits == 74 { return "🚀 Juego casi perfecto 🎯" }
        if hits == 75 { return "🚀 Brutal. Muy pocos llegan aquí 💥" }
        if hits == 76 { return "🚀 Control absoluto del ritmo 😎" }
        if hits == 77 { return "🚀 Partida de élite total 🏆" }
        if hits == 78 { return "🚀 Nivel de competición profesional 🔥" }
        if hits == 79 { return "🚀 Matemáticas en estado puro 🤯" }


        // 👑 80+
        return "🌟 HISTÓRICO 🌟 Nivel fuera de lo normal 👑🔥"
    }
    
    
    private var gameOverOverlay: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if canCloseGameOver {
                            showGameOver = false
                        }
                    }
                
                
                VStack {
                    Spacer()
                    VStack(spacing: 20) {
                        Text("Fin de la partida")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Aciertos: \(hits)")
                            .font(.body)
                            .foregroundColor(.gray)
                        
                        Text(mensajeAnimo(hits))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                        
                        
                        if qualifiesForRanking {
                            Text(isNewNumberOne ? "¡NUEVO Nº1!" : "¡NUEVO TOP 5!")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                            
                            Button {
                                showGameOver = false   // ⬅️ CIERRA EL POPUP DEBAJO
                                showAddRanking = true
                            } label: {
                                Text("Añadir marca")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.yellow)
                                    .foregroundColor(.black)
                                    .cornerRadius(14)
                            }
                            .disabled(!canCloseGameOver)
                            
                        }
                        
                        
                        
                        
                        Text("Pulsa fuera para cerrar")
                            .font(.footnote)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    
                    .padding(32)
                    .frame(
                        width: min(geo.size.width - 48, 420),
                        height: geo.size.height * 0.55
                    )
                    .background(Color(red: 12/255, green: 18/255, blue: 28/255))
                    .cornerRadius(24)
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - INFO FULL SCREEN (HEADER HOME STYLE + REAL BLUR)

    private var infoOverlay: some View {
        ZStack(alignment: .top) {

            // FONDO
            Color(red: 11/255, green: 15/255, blue: 20/255)
                .ignoresSafeArea()

            // 📜 SCROLL PRINCIPAL (PASA POR DEBAJO DEL HEADER)
            ScrollView {
                VStack(spacing: 24) {

                    // ✅ TÍTULO FUERA DEL NOTCH
                    Text("Cómo se juega")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .padding(.top, 8)

                    // IMAGEN
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

                    // TEXTO PRINCIPAL
                    Text("""
    Aparecen números en pantalla. El primero es azul. Pulsa el número que, al sumarse con él, dé 10.

    Si aciertas, el número se borra.

    Si fallas, aparece otro número como penalización.
    """)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                    // ⏱️ RECUADRO
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
                        .padding(.horizontal, 28)

                    Text("💪 Intenta superarte en cada partida.")
                        .font(.footnote)
                        .foregroundColor(.gray)

                    // ✅ BOTÓN
                    Button {
                        showInfo = false
                    } label: {
                        Text("OK, entendido")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
                .padding(.top, 72) // espacio real para header + respiro
            }

            // 🔝 HEADER FLOTANTE (SOLO BLUR + NOTCH)
            ZStack {
                VisualEffectBlur()
                Color.black.opacity(0.15)
            }
            .frame(height: 88) // incluye notch / dynamic island
            .ignoresSafeArea(edges: .top)
            .zIndex(1)
        }
    }

    
    }
