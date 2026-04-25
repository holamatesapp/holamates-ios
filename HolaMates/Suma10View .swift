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
    
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.systemBlue
        
        // seleccionado
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )
        
        // NO seleccionado (también blanco)
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .normal
        )
        
        UISegmentedControl.appearance().backgroundColor = UIColor(
            red: 24/255,
            green: 34/255,
            blue: 53/255,
            alpha: 1
        )
    }
    
    
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
    @State private var playerName: String = ""
    


    

    
    
    
    
    
    
    // 🏆 Ranking
    @State private var qualifiesForRanking: Bool = false
    @State private var currentChallenge: ChallengeID? = nil
    @State private var isNewNumberOne: Bool = false
    @State private var showAddRanking: Bool = false
    @State private var lastRankingIndex: Int = 0
    
    
    
    
    // ℹ️ INFO
    
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
                        

                    }
                    
                    Image("imagen_suma10")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                }
                .padding()
                
                // CONTENIDO
                VStack(spacing: 24) {
                    
                    Picker("", selection: $level) {
                        Text("1").tag(GameLevel.initLevel)
                        Text("2").tag(GameLevel.easy)
                        Text("3").tag(GameLevel.normal)
                        Text("4").tag(GameLevel.hard)
                    }
                    .pickerStyle(.segmented)
                    .foregroundColor(.white)
                    .disabled(running)
                    
                    HStack(spacing: 8) {
                        Image("target")
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text("\(hits)")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    
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

            
        }
        
        
        .navigationDestination(isPresented: $navigateToRanking) {
                    rankingDestination
                }
        
        
        .navigationBarHidden(true)
        .onDisappear {
            timer?.invalidate()
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
    
    
    

    private func videoAnimo(hits: Int) -> String {
        
        if hits <= 5 { return "elefante_saltarin" }
        if hits <= 10 { return "nino_bailando" }
        if hits <= 15 { return "joven_alegria" }
        if hits <= 20 { return "perro_feliz" }
        if hits <= 25 { return "gato_feliz" }
        if hits <= 30 { return "bicho_feliz" }
        if hits <= 40 { return "mono_aplausos" }
        
        if hits <= 50 { return "hombre_gesto_ok" }
        if hits <= 60 { return "cerebro_llamas" }
        if hits <= 70 { return "nino_sale_volando" }
        if hits <= 80 { return "chimpace_bailando" }
        if hits <= 90 { return "pequeno_superheroe" }
        
        // 🙂 MEDIO
        if hits <= 100 { return "tortuga_cohete" }
        if hits <= 110 { return "leopardo_corriendo" }
        if hits <= 120 { return "panda_asustado" }
        
        // 🚀 ALTO
        if hits <= 130 { return "astronauta" }
        if hits <= 140 { return "cohete" }
        
        // 🏆 TOP
        if hits <= 150 { return "jesucristo_aplausos" }
        
        return "jesucristo_aplausos"
    }
    

    
  
    
    private func medalImageName() -> String {
        guard qualifiesForRanking else { return "" }

        // posición estimada según ranking actual
        let sorted = (ranking + [RankingEntry(initials: "", score: hits)])
            .sorted { $0.score > $1.score }
        
        let position = sorted.firstIndex { $0.score <= hits } ?? 0

        switch position + 1 {
        case 1: return "medalla_1"
        case 2: return "medalla_2"
        case 3: return "medalla_3"
        case 4: return "medalla_4"
        case 5: return "medalla_5"
        default: return ""
        }
    }
    
    
    private var gameOverOverlay: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
 
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 24) {
                        
                        // 🎯 SCORE
                        HStack(spacing: 10) {
                            Image("target")
                                .resizable()
                                .frame(width: 32, height: 32)
                            
                            Text("\(hits)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        // MP4
                        
                        VideoLoopView(videoName: videoAnimo(hits: hits))
                            .frame(width: 140, height: 140)
     
                        
                        
                        // 🏆 MEDALLA (solo si ranking)
                        if qualifiesForRanking {
                            Image(medalImageName())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80)
                        }
                        
                        
                        // ✍️ INPUT (solo si entra en ranking)
                        if qualifiesForRanking {
                            ZStack {
                                if playerName.isEmpty {
                                    Text("ABC")
                                        .foregroundColor(.gray)
                                        .font(.title2)
                                }

                                TextField("", text: $playerName)
                                    .multilineTextAlignment(.center)
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(14)
                            .frame(width: geo.size.width * 0.6)
                        }
                        
                        
                        
                        // 🔵 BOTÓN OK
                        Button {
                            showGameOver = false

                            if qualifiesForRanking, let challenge = currentChallenge {
                                
                                let (newRanking, index) = RankingManager.shared.addEntry(
                                    initials: playerName,
                                    score: hits,
                                    challenge: challenge
                                )
                                
                                ranking = newRanking
                                lastRankingIndex = index
                                
                                navigateToRanking = true
                            }

                        } label: {
                            Text("OK")
                                .font(.headline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 40)
                        .disabled(!canCloseGameOver || (qualifiesForRanking && playerName.isEmpty))
                        
                    }
                    .padding(28)
                    .frame(width: min(geo.size.width - 48, 360))
                    .background(Color(red: 12/255, green: 18/255, blue: 28/255))
                    .cornerRadius(24)
                    
                    Spacer()
                }
            }
        }
    }
}
