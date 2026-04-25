import SwiftUI

enum RankingsGame: String, CaseIterable, Identifiable {
    case suma10 = "Suma 10"
    case sumas = "Sumas"
    case restas = "Restas"   // ✅ AÑADIR
    case tablas = "Tablas"
    case divisiones = "Divisiones"

    var id: String { rawValue }
}

enum TablasTableSelection: CaseIterable, Identifiable {
    case all
    case t2, t3, t4, t5, t6, t7, t8, t9

    var id: String { tableId }

    var tableId: String {
        switch self {
        case .all: return "all"
        case .t2: return "2"
        case .t3: return "3"
        case .t4: return "4"
        case .t5: return "5"
        case .t6: return "6"
        case .t7: return "7"
        case .t8: return "8"
        case .t9: return "9"
        }
    }

    // 🔥 TEXTO UNIVERSAL (SIN IDIOMA)
    var display: String {
        switch self {
        case .all: return "X 1 … 9"
        default: return "X \(tableId)"
        }
    }
}

struct RankingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // Selección
    @State private var game: RankingsGame = .suma10
    
    @State private var currentChallenge: ChallengeID? = nil
    
    
    
    
    
    
    // Tablas: selector de tabla
    @State private var tablasTable: TablasTableSelection = .all
    
    @State private var divisionesDivisor: String = "all"   // "all" o "1"..."9"
    
    // Navegación estable al Ranking
    @State private var ranking: [RankingEntry] = []
    
    
    @State private var showConfig = false
    
    
    
    
    var body: some View {
        ZStack {
            Color(red: 11/255, green: 15/255, blue: 20/255)
                .ignoresSafeArea()
            
            VStack(spacing: 18) {
                
                // Header
                HStack {
                    
                    // 🔙 VOLVER
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
                    
                    // ⚙️ CONFIG
                    Button {
                        showConfig = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
                
                
                
                .padding(.horizontal)
                .padding(.top, 8)
                
                VStack(spacing: 6) {
                    Text("🏆")
                        .font(.system(size: 34))
                    
                    Text("Ranking")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.top, 4)
                
                
                
                VStack(spacing: 14) {
                    
                    HStack(spacing: 12) {
                        gameButton(.suma10, image: "imagen_suma10")
                        gameButton(.sumas, image: "imagen_sumas")
                        gameButton(.restas, image: "imagen_restas")
                        gameButton(.tablas, image: "imagen_multiplicaciones")
                        gameButton(.divisiones, image: "imagen_divisiones")
                    }
                    .frame(maxWidth: .infinity)
                    
                    
                    
                    // (3) Tablas: tabla
                    if game == .tablas {
                        Picker("Tabla", selection: $tablasTable) {
                            ForEach(TablasTableSelection.allCases) { t in
                                Text(t.display).tag(t)
                            }
                        }
                        .pickerStyle(.menu)
                        .foregroundColor(.white)
                    }
                    
                    if game == .divisiones {
                        Picker("Divisor", selection: $divisionesDivisor) {
                            Text("÷ 1 … 9").tag("all")
                            ForEach(1...9, id: \.self) { n in
                                Text("÷ \(n)").tag("\(n)")
                            }
                        }
                        .pickerStyle(.menu)
                        .foregroundColor(.white)
                    }
                    
                    
                }
                .padding(.horizontal, 10)
                
                
                if let challenge = currentChallenge {
                    
                    VStack(spacing: 16) {
                        
                        
                        
                        VStack(spacing: 10) {
                            if ranking.isEmpty {
                                ForEach(0..<5) { index in
                                    emptyRankingRow(position: index + 1)
                                }
                            } else {
                                ForEach(ranking.indices, id: \.self) { index in
                                    rankingRow(
                                        entry: ranking[index],
                                        position: index + 1,
                                        highlighted: false
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                
                
                
                
                
                Spacer()
                
                
                
                
                
            }
            
            
        }
        .navigationBarHidden(true)
        
        
        .navigationDestination(isPresented: $showConfig) {
            RankingConfigView()
        }
        
        
        .onAppear {
            loadRankingDirect()
        }
        
        .onChange(of: tablasTable) { _ in
            loadRankingDirect()
        }
        .onChange(of: divisionesDivisor) { _ in
            loadRankingDirect()
        }
        
    }
    
    
    // MARK: - Open
    
    
    private func gameButton(_ g: RankingsGame, image: String) -> some View {
        
        Button {
            game = g
            loadRankingDirect()
        } label: {
            
            GeometryReader { geo in
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(game == g ? Color.blue.opacity(0.25) : Color.white.opacity(0.05))
                    .cornerRadius(14)
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }
    
    private func loadRankingDirect() {
        let challenge = selectedChallengeID()
        currentChallenge = challenge
        ranking = RankingManager.shared.loadRanking(for: challenge)
    }
    
    
    private func selectedChallengeID() -> ChallengeID {
        switch game {
            
        case .suma10:
            return .suma10_normal   // cualquiera vale
            
        case .sumas:
            return .sumas_sin_normal
            
        case .restas:
            return .restas_sin_normal
            
        case .tablas:
            return challengeForTablas(
                tableId: tablasTable.tableId,
                level: .normal
            )
            
        case .divisiones:
            return challengeForDivisiones(
                divisorId: divisionesDivisor,
                level: .normal
            )
        }
    }
    
    // MARK: - Mapping
    
    private func challengeForSuma10(level: GameLevel) -> ChallengeID {
        switch level {
        case .initLevel: return .suma10_iniciacion
        case .easy:      return .suma10_facil
        case .normal:    return .suma10_normal
        case .hard:      return .suma10_dificil
        }
    }
    
    private func challengeForSumas(level: SumasLevel) -> ChallengeID {
        
        switch level {
        case .initLevel: return .sumas_sin_iniciacion
        case .easy:      return .sumas_sin_facil
        case .normal:    return .sumas_sin_normal
        case .hard:      return .sumas_con_dificil
        }
    }
    
    private func challengeForRestas(level: SumasLevel) -> ChallengeID {
        
        switch level {
        case .initLevel: return .restas_sin_iniciacion
        case .easy:      return .restas_sin_facil
        case .normal:    return .restas_sin_normal
        case .hard:      return .restas_con_dificil
        }
    }
    
    private func challengeForTablas(tableId: String, level: TablasLevel) -> ChallengeID {
        
        switch (tableId, level) {
            
        case ("all", .initLevel): return .tablas_all_iniciacion
        case ("all", .easy):      return .tablas_all_facil
        case ("all", .normal):    return .tablas_all_normal
        case ("all", .hard):      return .tablas_all_dificil
            
        case ("2", .initLevel): return .tablas_2_iniciacion
        case ("2", .easy):      return .tablas_2_facil
        case ("2", .normal):    return .tablas_2_normal
        case ("2", .hard):      return .tablas_2_dificil
            
        case ("3", .initLevel): return .tablas_3_iniciacion
        case ("3", .easy):      return .tablas_3_facil
        case ("3", .normal):    return .tablas_3_normal
        case ("3", .hard):      return .tablas_3_dificil
            
        case ("4", .initLevel): return .tablas_4_iniciacion
        case ("4", .easy):      return .tablas_4_facil
        case ("4", .normal):    return .tablas_4_normal
        case ("4", .hard):      return .tablas_4_dificil
            
        case ("5", .initLevel): return .tablas_5_iniciacion
        case ("5", .easy):      return .tablas_5_facil
        case ("5", .normal):    return .tablas_5_normal
        case ("5", .hard):      return .tablas_5_dificil
            
        case ("6", .initLevel): return .tablas_6_iniciacion
        case ("6", .easy):      return .tablas_6_facil
        case ("6", .normal):    return .tablas_6_normal
        case ("6", .hard):      return .tablas_6_dificil
            
        case ("7", .initLevel): return .tablas_7_iniciacion
        case ("7", .easy):      return .tablas_7_facil
        case ("7", .normal):    return .tablas_7_normal
        case ("7", .hard):      return .tablas_7_dificil
            
        case ("8", .initLevel): return .tablas_8_iniciacion
        case ("8", .easy):      return .tablas_8_facil
        case ("8", .normal):    return .tablas_8_normal
        case ("8", .hard):      return .tablas_8_dificil
            
        case ("9", .initLevel): return .tablas_9_iniciacion
        case ("9", .easy):      return .tablas_9_facil
        case ("9", .normal):    return .tablas_9_normal
        case ("9", .hard):      return .tablas_9_dificil
            
        default:
            return .tablas_all_normal
        }
    }
    
    private func challengeForDivisiones(divisorId: String, level: DivisionesLevel) -> ChallengeID {
        switch (divisorId, level) {
            
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
    
    // MARK: - Reset Overlay
    
    
    
    
    
    private func imageNameForChallenge(_ challenge: ChallengeID) -> String {
        let raw = challenge.rawValue
        
        if raw.contains("suma10") { return "imagen_suma10" }
        if raw.contains("sumas") { return "imagen_sumas" }
        if raw.contains("restas") { return "imagen_restas" }
        if raw.contains("tablas") { return "imagen_multiplicaciones" }
        if raw.contains("divisiones") { return "imagen_divisiones" }
        
        return "imagen_suma10"
    }
    
    private func rankingRow(
        entry: RankingEntry,
        position: Int,
        highlighted: Bool
    ) -> some View {
        
        HStack {
            Text("\(position)º")
                .fontWeight(.bold)
                .frame(width: 40, alignment: .leading)
            
            Text(entry.initials)
            
            Spacer()
            
            Text("\(entry.score)")
                .fontWeight(.bold)
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .foregroundColor(.white)
        .cornerRadius(14)
    }
    
    private func emptyRankingRow(position: Int) -> some View {
        
        HStack {
            Text("\(position)º")
                .fontWeight(.bold)
                .frame(width: 40, alignment: .leading)
                .foregroundColor(.white.opacity(0.4))
            
            Text("— — —")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white.opacity(0.3))
            
            Spacer()
            
            Text("--")
                .foregroundColor(.white.opacity(0.3))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
}
