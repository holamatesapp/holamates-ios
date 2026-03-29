import SwiftUI




struct Suma10ViewEn: View {
    
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
                    
                    Text("Sum 10")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding()
                
                // CONTENIDO
                VStack(spacing: 24) {
                    
                    Picker("Level", selection: $level) {
                        ForEach(GameLevel.allCases, id: \.self) { lvl in
                            Text(levelText(lvl)).tag(lvl)
                        }
                    }
                    .pickerStyle(.menu)
                    .foregroundColor(.white)
                    .disabled(running)
                    
                    Text("Hits: \(hits)")
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
                AddRankingEntryViewEn(
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
    
    private func levelText(_ level: GameLevel) -> String {
        switch level {
        case .initLevel: return "Beginner"
        case .easy: return "Easy"
        case .normal: return "Medium"
        case .hard: return "Hard"
        }
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
                        Text("Game Over")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Hits: \(hits)")
                            .font(.body)
                            .foregroundColor(.gray)
                        
                        Text(mensajeAnimo(hits))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                        
                        
                        if qualifiesForRanking {
                            Text(isNewNumberOne ? "NEW #1!" : "NEW TOP 5!")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                            
                            Button {
                                showGameOver = false   // ⬅️ CIERRA EL POPUP DEBAJO
                                showAddRanking = true
                            } label: {
                                Text("Save score")
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
                    Text("How to play")
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
    Numbers appear on the screen. The first one is blue. Tap the number that adds up to 10.

    If you are correct, the number disappears.

    If you are wrong, a new number appears as a penalty.
    """)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                    // ⏱️ RECUADRO
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
                        .padding(.horizontal, 28)

                    Text("💪 Try to improve with every game.")
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
