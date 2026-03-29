import SwiftUI

struct SubtractionOp: Identifiable {
    let id = UUID()
    let a: Int
    let b: Int
    var revealed: Bool = false
}


enum RestasLevel: String, CaseIterable {
    case initLevel = "Iniciación"
    case easy = "Fácil"
    case normal = "Medio"
    case hard = "Difícil"
}

enum RestasMode: String, CaseIterable {
    case sin = "Sin llevada"
    case con = "Con llevada"
}


struct RestasView: View {

    @Environment(\.dismiss) private var dismiss
    
    enum GameEndReason {
        case time
        case fail
    }

    // MARK: - Estado del juego
    @State private var ops: [SubtractionOp] = []
    @State private var answer: String = ""
    @State private var hits: Int = 0
    @State private var running: Bool = false
    @State private var timer: Timer? = nil
    @State private var startTime: Date? = nil
    @State private var showGameOver: Bool = false
    @State private var endReason: GameEndReason? = nil
    @State private var timeProgress: Double = 0
    @State private var timeTimer: Timer? = nil


    
    
    // 🏆 Ranking (copiado de Suma10)
    @State private var ranking: [RankingEntry] = []
    @State private var navigateToRanking: Bool = false
    @State private var qualifiesForRanking: Bool = false
    @State private var currentChallenge: ChallengeID? = nil
    @State private var isNewNumberOne: Bool = false
    @State private var showAddRanking: Bool = false
    @State private var lastRankingIndex: Int = 0

    
    // ⏳ espera acumulada de la operación activa
    @State private var activeWait: Int = 0

    // 👉 operación fallida
    @State private var gameOverOpId: UUID? = nil

    // ℹ️ INFO
    @State private var showInfo: Bool = false

    @State private var mode: RestasMode = .sin
    @State private var level: RestasLevel = .normal

    // MARK: - Constantes
    private let MAX_STACK = 10

    // ✅ Oficial: 60s total, 4 fases de 15s
    private let GAME_TIME: Double = 60_000
    private let STEP_TIME: Double = 15_000

    private let REVEAL_AFTER = 3

    // ✅ Velocidades oficiales (ms -> segundos para Timer)
    private let LEVEL_SPEEDS: [RestasLevel: [Double]] = [
        .initLevel: [3.8, 3.4, 3.2, 3.0],
        .easy:      [3.0, 2.6, 2.2, 1.8],
        .normal:    [2.4, 2.0, 1.6, 1.2],
        .hard:      [1.8, 1.4, 1.0, 0.8]
    ]


    // MARK: - Layout fijo
    private let bubbleW: CGFloat = 66   // +6
    private let bubbleH: CGFloat = 32   // +4

    private let bubbleSpacing: CGFloat = 8
    
    // 👉 DESTINO DE NAVEGACIÓN AL RANKING (copiado de Suma10)
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

                // 🔼 ZONA SUPERIOR
                ScrollView {
                    VStack(spacing: 8) {

                        // HEADER (solo añadimos la i)
                        HStack {
                            Button { dismiss() } label: {
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

                        GeometryReader { geo in
                            Text("Restas")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .frame(maxWidth: geo.size.width * 0.8)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(height: 44)

                        HStack(spacing: 8) {

                            Picker("Modo", selection: $mode) {
                                ForEach(RestasMode.allCases, id: \.self) { m in
                                    Text(m.rawValue).tag(m)
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(.white)
                            .disabled(running)
                            
                         

                            Picker("Nivel", selection: $level) {
                                ForEach(RestasLevel.allCases, id: \.self) { lvl in                                    Text(lvl.rawValue).tag(lvl)
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(.white)
                            .disabled(running)
                        }



                        Text("Aciertos: \(hits)")
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                        
                        TimelineBar(
                            progress: timeProgress,
                            isFail: endReason != nil
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 6)



                        operacionesView
                            .frame(height: 64)
                            .padding(.top, 16)
                    }
                    .padding()
                }

                Spacer(minLength: 8)

                // 🔽 ZONA INFERIOR
                VStack(spacing: 16) {

                    keypad

                    Button {
                        startGame()
                    } label: {
                        Text("▶ Play")
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(running ? Color.gray.opacity(0.4) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)
                    .disabled(running)

                }
                .padding(.bottom, 16)
            }

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
            timeTimer?.invalidate()
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

                    // 🚀 NAVEGACIÓN AL RANKING
                    DispatchQueue.main.async {
                        navigateToRanking = true
                    }
                }
            }
        }

    }

    // MARK: - OPERACIONES

    private var operacionesView: some View {
        VStack(spacing: 6) {

            ZStack {
                baseRow()
                overlayRow(range: 0..<5)
            }

            ZStack {
                baseRow()
                overlayRow(range: 5..<10)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func updateTimeProgress() {
        guard let startTime, running else {
            timeProgress = 0
            return
        }

        let elapsed = Date().timeIntervalSince(startTime) * 1000
        timeProgress = min(elapsed / GAME_TIME, 1)
    }

    

    private func baseRow() -> some View {
        HStack(spacing: bubbleSpacing) {
            ForEach(0..<5, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.10))
                    .frame(width: bubbleW, height: bubbleH)
            }
        }
    }

    private func overlayRow(range: Range<Int>) -> some View {
        HStack(spacing: bubbleSpacing) {
            ForEach(range, id: \.self) { slot in
                overlaySlot(at: slot)
            }
        }
    }

    @ViewBuilder
    private func overlaySlot(at index: Int) -> some View {

        let activeSlot = 9 - (ops.count - 1)
        let opIndex = index - activeSlot

        if opIndex >= 0 && opIndex < ops.count {
            let op = ops[opIndex]

            Text(op.revealed
                 ? "\(op.a)-\(op.b)=\(op.a - op.b)"
                 : "\(op.a)-\(op.b)")
            
                .font(.system(size: op.revealed ? 14 : 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: bubbleW, height: bubbleH)
                .background(
                    (endReason == .fail && op.id == gameOverOpId) ? Color.red :
                    (endReason == .time && opIndex == 0) ? Color.red :
                    (running && opIndex == 0) ? Color.blue :
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
                        keyButton(label: "\(n)") { press("\(n)") }
                    }
                }
            }

            HStack {
                Spacer()
                keyButton(label: "0") { press("0") }
                Spacer()
            }
        }
        .padding(.horizontal)
    }

    // MARK: - LÓGICA

    private func randOp() -> SubtractionOp {

        func unoUno() -> (Int, Int) {
            var a = Int.random(in: 1...9)
            var b = Int.random(in: 1...a)
            if b == 0 { b = 1 }
            return (a, b)
        }

        func dosUnoSinLlevada() -> (Int, Int) {
            var result: Int
            var b: Int
            var a: Int
            repeat {
                result = Int.random(in: 1...9)
                b = Int.random(in: 1...9)
                a = b + result
            } while a % 10 < b
            return (a, b)
        }

        func dosUnoConLlevada() -> (Int, Int) {
            var result: Int
            var b: Int
            var a: Int
            repeat {
                result = Int.random(in: 1...9)
                b = Int.random(in: 1...9)
                a = b + result
            } while a % 10 >= b
            return (a, b)
        }

        if mode == .con {

            let r = Double.random(in: 0...1)

            if r < 0.7 {
                let (a, b) = dosUnoConLlevada()
                return SubtractionOp(a: a, b: b)
            }

            if Double.random(in: 0...1) < 0.5 {
                let (a, b) = unoUno()
                return SubtractionOp(a: a, b: b)
            } else {
                let (a, b) = dosUnoSinLlevada()
                return SubtractionOp(a: a, b: b)
            }
        }

        if Double.random(in: 0...1) < 0.5 {
            let (a, b) = unoUno()
            return SubtractionOp(a: a, b: b)
        } else {
            let (a, b) = dosUnoSinLlevada()
            return SubtractionOp(a: a, b: b)
        }
    }
  


    private func currentInterval() -> Double? {
        guard let startTime else { return nil }

        let elapsed = Date().timeIntervalSince(startTime) * 1000
        if elapsed >= GAME_TIME { return nil }

        let speeds = LEVEL_SPEEDS[level] ?? []
        guard !speeds.isEmpty else { return nil }

        let phase = min(Int(elapsed / STEP_TIME), 3)
        let index = min(phase, speeds.count - 1)
        return speeds[index]
    }


    private func addOperation() {
        guard running else { return }
        if ops.count >= MAX_STACK {
            endGame(reason: .fail)
            return
        }
        // ⏳ solo cuenta la espera de la operación activa
        if let first = ops.first, !first.revealed {
            activeWait += 1

            if activeWait >= REVEAL_AFTER {
                // revelar la operación activa
                if let idx = ops.firstIndex(where: { $0.id == first.id }) {
                    ops[idx].revealed = true
                }
            }
        }

        ops.append(randOp())
    }


    private func loop() {
        guard let interval = currentInterval() else {
            endGame(reason: .time)
            return
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            addOperation()
            loop()
        }
    }

    private func startGame() {
        showGameOver = false
        gameOverOpId = nil
        
        endReason = nil
        
        timer?.invalidate()
        ops.removeAll()
        hits = 0
        answer = ""
        activeWait = 0        // 🔑 reset clave
        running = true
        startTime = Date()
        addOperation()
        loop()
        
        timeProgress = 0
        updateTimeProgress()

        timeTimer?.invalidate()
        timeTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateTimeProgress()
        }

    }


    private func press(_ n: String) {
        guard running, !ops.isEmpty else { return }

        answer += n
        let cur = ops[0]
        let result = String(cur.a - cur.b)

        if answer == result {
            hits += 1
            ops.removeFirst()
            answer = ""
            activeWait = 0

            // ✅ Nunca vacío mientras se juega
            if ops.isEmpty {
                ops.append(randOp())
            }

            // ✅ REINICIO DE INTERVALO TAMBIÉN AL ACERTAR
            if running {
                timer?.invalidate()
                loop()
            }

            return
        }


        if result.hasPrefix(answer) { return }

        answer = ""
        addOperation()

        // 🔵 REINICIO DE INTERVALO (igual que Web)
        if running {
            timer?.invalidate()
            loop()
        }

    }

    private func endGame(reason: GameEndReason) {

        running = false
        timer?.invalidate()
        
        timeTimer?.invalidate()
        timeTimer = nil

        if reason == .time {
            timeProgress = 1
        }

        endReason = reason

        if reason == .fail {
            gameOverOpId = ops.first?.id
        } else {
            gameOverOpId = nil
        }

        // 🏆 Ranking (idéntico a Suma10)
        let challenge = currentChallengeID()
        currentChallenge = challenge

        ranking = RankingManager.shared.loadRanking(for: challenge)

        qualifiesForRanking = RankingManager.shared
            .qualifiesForTop5(score: hits, challenge: challenge)

        isNewNumberOne = ranking.first.map { hits >= $0.score } ?? true

        showGameOver = true
    }

    private func currentChallengeID() -> ChallengeID {

        switch (mode, level) {

        case (.sin, .initLevel):
            return .restas_sin_iniciacion
        case (.sin, .easy):
            return .restas_sin_facil
        case (.sin, .normal):
            return .restas_sin_normal
        case (.sin, .hard):
            return .restas_sin_dificil

        case (.con, .initLevel):
            return .restas_con_iniciacion
        case (.con, .easy):
            return .restas_con_facil
        case (.con, .normal):
            return .restas_con_normal
        case (.con, .hard):
            return .restas_con_dificil
        }
    }





    // MARK: - INFO FULL SCREEN (TABLAS – HEADER HOME STYLE + REAL BLUR)

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
                    Image("restasnumeros")
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
    Aparecen restas en pantalla. La primera (azul) es la activa. Introduce el resultado.

    Si aciertas, la operación se borra.

    Si fallas, aparece una nueva operación como penalización.
    """)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                    // ⏱️ RECUADRO
                    Text("⏱️ La partida acaba a los 60 segundos o cuando hay 10 operaciones en pantalla.")
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
                .padding(.top, 72) // espacio real para header + aire
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


    // MARK: - GAME OVER (sin cambios)

    private var gameOverOverlay: some View {
        GeometryReader { geo in
            ZStack {

                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showGameOver = false
                    }

                VStack {
                    Spacer()

                    VStack(spacing: 12) {

                        Text("Fin de la partida")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Aciertos: \(hits)")
                            .font(.title3)
                            .foregroundColor(.gray)

                        Text(mensajeAnimo(hits))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                        
                        if qualifiesForRanking {

                            Text(isNewNumberOne ? "🏆 ¡NUEVO Nº1!" : "🎉 ¡NUEVO TOP 5!")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)

                            Button {
                                showGameOver = false
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

    // MARK: - UI

    private func keyButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 90, height: 60)
                .background(Color(red: 24/255, green: 34/255, blue: 53/255))
                .cornerRadius(16)
        }
    }
}
