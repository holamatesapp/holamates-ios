import SwiftUI

struct DivisionOp: Identifiable {
    let id = UUID()
    let divisor: Int
    let dividend: Int
    let res: Int
    var revealed: Bool = false
}


enum DivisionesLevel: String, CaseIterable {
    case initLevel = "1"
    case easy = "2"
    case normal = "3"
    case hard = "4"
}


struct DivisionesView: View {

    @Environment(\.dismiss) private var dismiss
    
    enum GameEndReason {
        case time
        case fail
    }

    // MARK: - Estado del juego
    @State private var ops: [DivisionOp] = []
    @State private var answer: String = ""
    @State private var hits: Int = 0
    @State private var running: Bool = false
    @State private var timer: Timer? = nil
    @State private var startTime: Date? = nil
    @State private var showGameOver: Bool = false
    @State private var endReason: GameEndReason? = nil
    @State private var timeProgress: Double = 0
    @State private var timeTimer: Timer? = nil
    
    @State private var playerName: String = ""
    @State private var canCloseGameOver: Bool = false


    
    
    // 🏆 Ranking (copiado de Suma10)
    @State private var ranking: [RankingEntry] = []
    @State private var navigateToRanking: Bool = false
    @State private var qualifiesForRanking: Bool = false
    @State private var currentChallenge: ChallengeID? = nil
    @State private var isNewNumberOne: Bool = false
    @State private var lastRankingIndex: Int = 0

    
    // ⏳ espera acumulada de la operación activa
    @State private var activeWait: Int = 0

    // 👉 operación fallida
    @State private var gameOverOpId: UUID? = nil

    // ℹ️ INFO

    @State private var selectedTable: String = "all"
    @State private var level: DivisionesLevel = .normal


    // MARK: - Constantes
    private let MAX_STACK = 10

    // ✅ Oficial: 60s total, 4 fases de 15s
    private let GAME_TIME: Double = 60_000
    private let STEP_TIME: Double = 15_000

    private let REVEAL_AFTER = 3

    // ✅ Velocidades oficiales (ms -> segundos para Timer)
    private let LEVEL_SPEEDS: [DivisionesLevel: [Double]] = [
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
                    VStack(spacing: 0) {

                        // HEADER
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
                        }

                        VStack(spacing: 0) {

                            Image("imagen_divisiones")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                                .padding(.bottom, 20)

                            Picker("", selection: $level) {
                                Text("1").tag(DivisionesLevel.initLevel)
                                Text("2").tag(DivisionesLevel.easy)
                                Text("3").tag(DivisionesLevel.normal)
                                Text("4").tag(DivisionesLevel.hard)
                            }
                            .pickerStyle(.segmented)
                            .foregroundColor(.white)
                            .disabled(running)
                            .padding(.bottom, 16)
                        }

                        // DIVISOR IZQ + HITS DER
                        HStack(spacing: 12) {
                            
                            Picker("", selection: $selectedTable) {
                                Text("÷ 1 ... 9").tag("all")
                                ForEach(1...9, id: \.self) { n in
                                    Text("÷ \(n)").tag("\(n)")
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(.white)
                            .disabled(running)

                            Spacer().frame(width: 20)

                            HStack(spacing: 6) {
                                Image("target")
                                    .resizable()
                                    .frame(width: 20, height: 20)

                                Text("\(hits)")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(.horizontal)
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



                        
                    }
        
        .navigationDestination(isPresented: $navigateToRanking) {
            rankingDestination
        }
        
        .navigationBarHidden(true)
        .onDisappear {
            timer?.invalidate()
            timeTimer?.invalidate()
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
                 ? "\(op.dividend)÷\(op.divisor)=\(op.res)"
                 : "\(op.dividend)÷\(op.divisor)")
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

    private func randOp() -> DivisionOp {
        let divisor = selectedTable == "all"
            ? Int.random(in: 1...9)
            : (Int(selectedTable) ?? 1)

        let res = Int.random(in: 1...9)
        let dividend = divisor * res

        return DivisionOp(divisor: divisor, dividend: dividend, res: res)
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
        let result = String(cur.res)
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

        canCloseGameOver = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            canCloseGameOver = true
        }

        showGameOver = true
    }

    private func currentChallengeID() -> ChallengeID {

        let divisorID: String = {
            selectedTable == "all" ? "all" : selectedTable
        }()

        switch (divisorID, level) {

        case ("all", .initLevel): return .divisiones_all_iniciacion
        case ("all", .easy):      return .divisiones_all_facil
        case ("all", .normal):    return .divisiones_all_normal
        case ("all", .hard):      return .divisiones_all_dificil

        case ("1", .initLevel): return .divisiones_1_iniciacion
        case ("1", .easy):      return .divisiones_1_facil
        case ("1", .normal):    return .divisiones_1_normal
        case ("1", .hard):      return .divisiones_1_dificil

        case ("2", .initLevel): return .divisiones_2_iniciacion
        case ("2", .easy):      return .divisiones_2_facil
        case ("2", .normal):    return .divisiones_2_normal
        case ("2", .hard):      return .divisiones_2_dificil

        case ("3", .initLevel): return .divisiones_3_iniciacion
        case ("3", .easy):      return .divisiones_3_facil
        case ("3", .normal):    return .divisiones_3_normal
        case ("3", .hard):      return .divisiones_3_dificil

        case ("4", .initLevel): return .divisiones_4_iniciacion
        case ("4", .easy):      return .divisiones_4_facil
        case ("4", .normal):    return .divisiones_4_normal
        case ("4", .hard):      return .divisiones_4_dificil

        case ("5", .initLevel): return .divisiones_5_iniciacion
        case ("5", .easy):      return .divisiones_5_facil
        case ("5", .normal):    return .divisiones_5_normal
        case ("5", .hard):      return .divisiones_5_dificil

        case ("6", .initLevel): return .divisiones_6_iniciacion
        case ("6", .easy):      return .divisiones_6_facil
        case ("6", .normal):    return .divisiones_6_normal
        case ("6", .hard):      return .divisiones_6_dificil

        case ("7", .initLevel): return .divisiones_7_iniciacion
        case ("7", .easy):      return .divisiones_7_facil
        case ("7", .normal):    return .divisiones_7_normal
        case ("7", .hard):      return .divisiones_7_dificil

        case ("8", .initLevel): return .divisiones_8_iniciacion
        case ("8", .easy):      return .divisiones_8_facil
        case ("8", .normal):    return .divisiones_8_normal
        case ("8", .hard):      return .divisiones_8_dificil

        case ("9", .initLevel): return .divisiones_9_iniciacion
        case ("9", .easy):      return .divisiones_9_facil
        case ("9", .normal):    return .divisiones_9_normal
        case ("9", .hard):      return .divisiones_9_dificil

        default:
            return .divisiones_all_normal
        }
    }





    // MARK: - INFO FULL SCREEN (TABLAS – HEADER HOME STYLE + REAL BLUR)

   
    
    private func videoAnimo(hits: Int) -> String {
        
        if hits <= 5 { return "elefante_saltarin" }
        if hits <= 10 { return "nino_bailando" }
        if hits <= 15 { return "joven_alegria" }
        if hits <= 20 { return "perro_feliz" }
        if hits <= 25 { return "gato_feliz" }
        if hits <= 30 { return "bicho_feliz" }
        if hits <= 35 { return "mono_aplausos" }
        
        if hits <= 40 { return "hombre_gesto_ok" }
        if hits <= 45 { return "cerebro_llamas" }
        if hits <= 50 { return "nino_sale_volando" }
        if hits <= 55 { return "chimpace_bailando" }
        if hits <= 60 { return "pequeno_superheroe" }
        
        // 🙂 MEDIO
        if hits <= 65 { return "tortuga_cohete" }
        if hits <= 70 { return "leopardo_corriendo" }
        if hits <= 75 { return "panda_asustado" }
        
        // 🚀 ALTO
        if hits <= 80 { return "astronauta" }
        if hits <= 85 { return "cohete" }
        
        // 🏆 TOP
        if hits <= 90 { return "jesucristo_aplausos" }
        
        return "jesucristo_aplausos"
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

                        // 🎬 VIDEO (CLAVE)
                        VideoLoopView(videoName: videoAnimo(hits: hits))
                            .frame(width: 140, height: 140)

                        // 🏆 MEDALLA
                        if qualifiesForRanking {
                            Image(medalImageName())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80)
                        }
                        
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
    
    private func medalImageName() -> String {
        guard qualifiesForRanking else { return "" }

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
