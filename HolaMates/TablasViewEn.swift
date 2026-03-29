import SwiftUI




enum TablasLevelEn: String, CaseIterable {
    case initLevel = "Beginner"
    case easy = "Easy"
    case normal = "Medium" 
    case hard = "Hard"
}


struct TablasViewEn: View {

    @Environment(\.dismiss) private var dismiss
    
    enum GameEndReason {
        case time
        case fail
    }

    // MARK: - Estado del juego
    @State private var ops: [MultiplicationOp] = []
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

    @State private var selectedTable: String = "all"
    @State private var level: TablasLevelEn = .normal


    // MARK: - Constantes
    private let MAX_STACK = 10

    // ✅ Oficial: 60s total, 4 fases de 15s
    private let GAME_TIME: Double = 60_000
    private let STEP_TIME: Double = 15_000

    private let REVEAL_AFTER = 3

    // ✅ Velocidades oficiales (ms -> segundos para Timer)
    private let LEVEL_SPEEDS: [TablasLevelEn: [Double]] = [
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
                RankingViewEn(
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
                            Text("Multiplication")
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

                            Picker("Table", selection: $selectedTable) {
                                Text("All").tag("all")

                                ForEach(1...9, id: \.self) { n in
                                    Text("Table of \(n)").tag("\(n)")
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(.white)
                            .frame(width: 140)   // 🔥 CLAVE REAL
                            .disabled(running)

                            Picker("Level", selection: $level) {
                                ForEach(TablasLevelEn.allCases, id: \.self) { lvl in
                                    Text(lvl.rawValue).tag(lvl)
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(.white)
                            .frame(width: 140)   // 🔥 CLAVE REAL
                            .disabled(running)
                        }



                        Text("Hits: \(hits)")
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
                AddRankingEntryViewEn(
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
                 ? "\(op.a)×\(op.b)=\(op.a * op.b)"
                 : "\(op.a)×\(op.b)")
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

    private func randOp() -> MultiplicationOp {
        let b = Int.random(in: 1...9)
        let a = selectedTable == "all"
            ? Int.random(in: 1...9)
            : Int(selectedTable) ?? 1
        return MultiplicationOp(a: a, b: b)
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
        let result = String(cur.a * cur.b)

        if answer == result {
            hits += 1
            ops.removeFirst()
            answer = ""
            activeWait = 0

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

        let tableID: String = {
            if selectedTable == "all" {
                return "all"
            } else {
                return selectedTable
            }
        }()

        switch (tableID, level) {

        // Todas las tablas
        case ("all", .initLevel):
            return .tablas_all_iniciacion
        case ("all", .easy):
            return .tablas_all_facil
        case ("all", .normal):
            return .tablas_all_normal
        case ("all", .hard):
            return .tablas_all_dificil

        // Tabla del 2
        case ("2", .initLevel):
            return .tablas_2_iniciacion
        case ("2", .easy):
            return .tablas_2_facil
        case ("2", .normal):
            return .tablas_2_normal
        case ("2", .hard):
            return .tablas_2_dificil

        // Tabla del 3
        case ("3", .initLevel):
            return .tablas_3_iniciacion
        case ("3", .easy):
            return .tablas_3_facil
        case ("3", .normal):
            return .tablas_3_normal
        case ("3", .hard):
            return .tablas_3_dificil

        // Tabla del 4
        case ("4", .initLevel):
            return .tablas_4_iniciacion
        case ("4", .easy):
            return .tablas_4_facil
        case ("4", .normal):
            return .tablas_4_normal
        case ("4", .hard):
            return .tablas_4_dificil

        // Tabla del 5
        case ("5", .initLevel):
            return .tablas_5_iniciacion
        case ("5", .easy):
            return .tablas_5_facil
        case ("5", .normal):
            return .tablas_5_normal
        case ("5", .hard):
            return .tablas_5_dificil

        // Tabla del 6
        case ("6", .initLevel):
            return .tablas_6_iniciacion
        case ("6", .easy):
            return .tablas_6_facil
        case ("6", .normal):
            return .tablas_6_normal
        case ("6", .hard):
            return .tablas_6_dificil

        // Tabla del 7
        case ("7", .initLevel):
            return .tablas_7_iniciacion
        case ("7", .easy):
            return .tablas_7_facil
        case ("7", .normal):
            return .tablas_7_normal
        case ("7", .hard):
            return .tablas_7_dificil

        // Tabla del 8
        case ("8", .initLevel):
            return .tablas_8_iniciacion
        case ("8", .easy):
            return .tablas_8_facil
        case ("8", .normal):
            return .tablas_8_normal
        case ("8", .hard):
            return .tablas_8_dificil

        // Tabla del 9
        case ("9", .initLevel):
            return .tablas_9_iniciacion
        case ("9", .easy):
            return .tablas_9_facil
        case ("9", .normal):
            return .tablas_9_normal
        case ("9", .hard):
            return .tablas_9_dificil

        default:
            return .tablas_all_normal
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
                    Text("How to play")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .padding(.top, 8)

                    // IMAGEN
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

                    // TEXTO PRINCIPAL
                    Text("""
                    Multiplication operations appear on screen. The first one (blue) is active. Enter the result.

                    If correct, the operation disappears.

                    If you fail, a new operation appears as a penalty.
                    """)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                    // ⏱️ RECUADRO
                    Text("⏱️ The game ends after 60 seconds or when there are 10 operations on screen.")
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

                    Text("💪 Try to improve every game.")
                        .font(.footnote)
                        .foregroundColor(.gray)

                    // ✅ BOTÓN
                    Button {
                        showInfo = false
                    } label: {
                        Text("OK, got it")
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
        
        if hits == 0  { return "No worries 💙 Let's try again" }
        if hits == 1  { return "Good try 💪 Every game counts" }
        if hits == 2  { return "Nice! Step by step 🙂" }
        if hits == 3  { return "Very good! Keep it up 👏" }
        if hits == 4  { return "Great! You're improving 🚀" }
        if hits == 5  { return "Nice start 😄" }
        if hits == 6  { return "Very good! Getting faster 🔥" }
        if hits == 7  { return "Great! Good focus 🧠" }
        if hits == 8  { return "Great! Solid rhythm 💪" }
        if hits == 9  { return "Very good! Good control 👌" }

        // 🔹 10–14
        if hits == 10 { return "Very good! Real progress 😄" }
        if hits == 11 { return "Very good! More confident 🙂" }
        if hits == 12 { return "Great! Good pace 🚀" }
        if hits == 13 { return "Great! Strong control 👏" }
        if hits == 14 { return "Very good! You're getting strong 💪" }

        // 🔹 15–19
        if hits == 15 { return "Very good! Consistent rhythm 💪" }
        if hits == 16 { return "Very good! Solid confidence 🙂" }
        if hits == 17 { return "Great! Strong focus 🧠" }
        if hits == 18 { return "Great! Excellent control 👏" }
        if hits == 19 { return "Very good! Ready for more 🚀" }

        // 🔥 20–24
        if hits == 20 { return "Brutal! Very high level 🔥" }
        if hits == 21 { return "Brutal! Very solid 💥" }
        if hits == 22 { return "Beast mode! Incredible pace 🔥" }
        if hits == 23 { return "Beast mode! Great control 💪" }
        if hits == 24 { return "Beast mode! Very strong 🧠" }

        // 🏆 25–29
        if hits == 25 { return "Pro level! Very fast 🚀" }
        if hits == 26 { return "Pro level! Great control 🎯" }
        if hits == 27 { return "Pro level! No mistakes 💥" }
        if hits == 28 { return "Pro level! Perfect precision 🎯" }
        if hits == 29 { return "Pro level! Impressive 🌟" }

        // 🏆 30–34
        if hits == 30 { return "Outstanding! High speed 🏆" }
        if hits == 31 { return "Outstanding! Great precision 🎯" }
        if hits == 32 { return "Outstanding! Strong confidence 😎" }
        if hits == 33 { return "Outstanding! Very solid 💪" }
        if hits == 34 { return "Outstanding! Top level 🌟" }

        // 🤖 35–39
        if hits == 35 { return "Machine! Next level 🤖" }
        if hits == 36 { return "Machine! Incredible pace 🔥" }
        if hits == 37 { return "Machine! Great mastery 🧠" }
        if hits == 38 { return "Machine! Amazing game 💥" }
        if hits == 39 { return "Machine! Unstoppable 🚀" }

        // 👑 40–44
        if hits == 40 { return "Legend! Historic game 👑" }
        if hits == 41 { return "Legend! Total control 😎" }
        if hits == 42 { return "Legend! Incredible precision 🎯" }
        if hits == 43 { return "Legend! Perfect rhythm 🌟" }
        if hits == 44 { return "Legend! Maximum level 🏆" }

        // 🌟 45–49
        if hits == 45 { return "Elite! Perfect game 🔥" }
        if hits == 46 { return "Elite! Absolute control 🧠" }
        if hits == 47 { return "Elite! No errors 💥" }
        if hits == 48 { return "Elite! Brutal 😎" }
        if hits == 49 { return "Elite! Unstoppable 🚀" }

        // 🚀 50–59
        if hits == 50 { return "Incredible! Another planet 🤯" }
        if hits == 51 { return "Incredible! Extreme level 🔥" }
        if hits == 52 { return "Incredible! Total mastery 💪" }
        if hits == 53 { return "Incredible! Perfect precision 🎯" }
        if hits == 54 { return "Incredible! Crazy speed 🚀" }
        if hits == 55 { return "Incredible! Steel mind 🧠" }
        if hits == 56 { return "Incredible! Speechless 🤯" }
        if hits == 57 { return "Incredible! Absolute master 🏆" }
        if hits == 58 { return "Incredible! Perfect game 🔥" }
        if hits == 59 { return "Incredible! Almost impossible 😎" }

        // 🌌 60–69
        if hits == 60 { return "👑 Absolute legend 🔥" }
        if hits == 61 { return "👑 Mythical level 🚀" }
        if hits == 62 { return "🌟 Legendary mastery 💪" }
        if hits == 63 { return "⚡ Supernatural speed 🔥" }
        if hits == 64 { return "💎 Perfect precision 🎯" }
        if hits == 65 { return "🧠 Mental master 👏" }
        if hits == 66 { return "🔥 Extreme dominance 🚀" }
        if hits == 67 { return "⚡ Unstoppable speed 💥" }
        if hits == 68 { return "🏆 Historic level 🌟" }
        if hits == 69 { return "👑 Almost perfect 😎" }

        // 🌌 70–79
        if hits == 70 { return "🌌 Myth level 🚀" }
        if hits == 71 { return "🔥 Legendary game 🏆" }
        if hits == 72 { return "💥 Totally unstoppable ⚡" }
        if hits == 73 { return "🌟 Epic performance 🚀" }
        if hits == 74 { return "💎 Absolute control 🎯" }
        if hits == 75 { return "👑 Supreme master 🔥" }
        if hits == 76 { return "⚡ Alien speed 🧠" }
        if hits == 77 { return "🌌 Galactic mastery 🚀" }
        if hits == 78 { return "🏆 Record level 🌟" }
        if hits == 79 { return "🔥 Insane 😎" }

        // 🛸 80–89
        if hits == 80 { return "🛸 Galactic level 🚀" }
        if hits == 81 { return "🌠 Stellar performance 🔥" }
        if hits == 82 { return "💎 Total precision 🎯" }
        if hits == 83 { return "⚡ Extreme speed 💥" }
        if hits == 84 { return "👑 Infinite master 🏆" }
        if hits == 85 { return "🌌 Cosmic game 🚀" }
        if hits == 86 { return "🔥 Absolute dominance 💪" }
        if hits == 87 { return "🧠 Pure genius 🌟" }
        if hits == 88 { return "⚡ Unstoppable 🚀" }
        if hits == 89 { return "🏆 Maximum level 😎" }

        // 🌟 90–100
        if hits == 90 { return "🌟 Supreme level 🔥" }
        if hits == 91 { return "🔥 Total dominance 👑" }
        if hits == 92 { return "⚡ Perfect speed 🚀" }
        if hits == 93 { return "💎 Legendary precision 🎯" }
        if hits == 94 { return "🧠 Absolute control 🌟" }
        if hits == 95 { return "👑 Eternal master 🔥" }
        if hits == 96 { return "🌌 Supernatural performance 🚀" }
        if hits == 97 { return "⚡ Unstoppable rhythm 💥" }
        if hits == 98 { return "🏆 Historic game 🌟" }
        if hits == 99 { return "👑 Almost eternal 🔥" }
        if hits == 100 { return "💯 This is history!!! 🏆" }

        // 🌠 101+
        if hits == 101 { return "👑 Impossible level achieved 🔥" }
        if hits == 102 { return "🌠 Transcendent level 🔥" }
        if hits == 103 { return "🚀 Beyond impossible 💥" }
        if hits == 104 { return "👑 Absolute math mastery 🏆" }
        if hits == 105 { return "⚡ Supernatural speed 🧠" }
        if hits == 106 { return "💎 Infinite precision 🎯" }
        if hits == 107 { return "🔥 Off-the-scale pace 🚀" }
        if hits == 108 { return "🌌 Total universe control 🌟" }
        if hits == 109 { return "🧠 Brilliant mind 💥" }
        if hits == 110 { return "🏆 Historic mark 🚀" }
        if hits == 111 { return "👑 Untouchable level 🔥" }

        if hits == 112 { return "⚡ Legendary performance 💎" }
        if hits == 113 { return "🌠 Perfect game 🏆" }
        if hits == 114 { return "🔥 Limitless dominance 🚀" }
        if hits == 115 { return "🧠 Unstoppable mind 💥" }
        if hits == 116 { return "👑 Champion rhythm 🏆" }
        if hits == 117 { return "⚡ Epic level 🚀" }
        if hits == 118 { return "🌌 Absolute precision 💎" }
        if hits == 119 { return "🔥 Unforgettable game 🏆" }
        if hits == 120 { return "👑 Infinite level 🚀" }
        if hits == 121 { return "🌟 Beyond legend 🔥" }

        if hits > 121 { return "🏆 ETERNAL LEGEND! This is history" }

        return "Great job! Keep going 🚀"
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

                        Text("Game Over")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Hits: \(hits)")
                            .font(.title3)
                            .foregroundColor(.gray)

                        Text(mensajeAnimo(hits))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                        
                        if qualifiesForRanking {

                            Text(isNewNumberOne ? "🏆 NEW #1!" : "🎉 NEW TOP 5!")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)

                            Button {
                                showGameOver = false
                                showAddRanking = true
                            } label: {
                                Text("Add score")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.yellow)
                                    .foregroundColor(.black)
                                    .cornerRadius(14)
                            }
                        }


                        Text("Tap outside to close")
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
