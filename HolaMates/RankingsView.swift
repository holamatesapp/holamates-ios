import SwiftUI

enum RankingsGame: String, CaseIterable, Identifiable {
    case suma10 = "Suma 10"
    case sumas = "Sumas"
    case restas = "Restas"   // ✅ AÑADIR
    case tablas = "Tablas"
    case divisiones = "Divisiones"

    var id: String { rawValue }
}

enum TablasTableSelection: String, CaseIterable, Identifiable {
    case all = "Todas"
    case t2 = "Tabla del 2"
    case t3 = "Tabla del 3"
    case t4 = "Tabla del 4"
    case t5 = "Tabla del 5"
    case t6 = "Tabla del 6"
    case t7 = "Tabla del 7"
    case t8 = "Tabla del 8"
    case t9 = "Tabla del 9"

    var id: String { rawValue }

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
}

struct RankingsView: View {

    @Environment(\.dismiss) private var dismiss

    // Selección
    @State private var game: RankingsGame = .suma10

    // Picker nivel (según juego)
    @State private var sumaLevel: GameLevel = .normal
    @State private var tablasLevel: TablasLevel = .normal
    
    // Sumas: selector
    @State private var sumasLevel: SumasLevel = .normal
    @State private var sumasMode: SumasMode = .sin
    
    // Restas: selector
    @State private var restasLevel: SumasLevel = .normal
    @State private var restasMode: SumasMode = .sin

    // Tablas: selector de tabla
    @State private var tablasTable: TablasTableSelection = .all
    
    // Divisiones: selector
    @State private var divisionesLevel: DivisionesLevel = .normal
    @State private var divisionesDivisor: String = "all"   // "all" o "1"..."9"

    // Navegación estable al Ranking
    @State private var ranking: [RankingEntry] = []
    @State private var currentChallenge: ChallengeID? = nil
    @State private var navigateToRanking: Bool = false

    // ✅ Popup reset
    @State private var showResetPopup: Bool = false
    @State private var resetText: String = ""

    private let noHighlightIndex: Int = -1

    private var rankingDestination: some View {
        Group {
            if let challenge = currentChallenge {
                RankingView(
                    challenge: challenge,
                    ranking: ranking,
                    highlightedIndex: noHighlightIndex
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

            VStack(spacing: 18) {

                // Header
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

                    // ✅ NUEVO: engranaje
                    Button {
                        resetText = ""
                        showResetPopup = true
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
                .padding(.top, 12)

                VStack(spacing: 8) {

                    Text("🏆")
                        .font(.system(size: 44))

                    Text("Rankings")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Elige juego y nivel")
                        .foregroundColor(.gray)
                }
                .foregroundColor(.white)
                .padding(.bottom, 8)


                VStack(spacing: 14) {

                    // (1) Juego
                    Picker("Juego", selection: $game) {
                        ForEach(RankingsGame.allCases) { g in
                            Text(g.rawValue).tag(g)
                        }
                    }
                    .pickerStyle(.menu)
                    .foregroundColor(.white)

                    // (2) Nivel
                    Group {

                        if game == .suma10 {

                            Picker("Nivel", selection: $sumaLevel) {
                                ForEach(GameLevel.allCases, id: \.self) { lvl in
                                    Text(lvl.rawValue).tag(lvl)
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(.white)

                        } else if game == .sumas {

                            Picker("Modo", selection: $sumasMode) {
                                ForEach(SumasMode.allCases, id: \.self) { m in
                                    Text(m.rawValue).tag(m)
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(.white)

                            Picker("Nivel", selection: $sumasLevel) {
                                ForEach(SumasLevel.allCases, id: \.self) { lvl in
                                    Text(lvl.rawValue).tag(lvl)
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(.white)
                            
                        } else if game == .restas {

                            Picker("Modo", selection: $restasMode) {
                                ForEach(SumasMode.allCases, id: \.self) { m in
                                    Text(m.rawValue).tag(m)
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(.white)

                            Picker("Nivel", selection: $restasLevel) {
                                ForEach(SumasLevel.allCases, id: \.self) { lvl in
                                    Text(lvl.rawValue).tag(lvl)
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(.white)
                            
                        } else if game == .tablas {

                            Picker("Nivel", selection: $tablasLevel) {
                                ForEach(TablasLevel.allCases, id: \.self) { lvl in
                                    Text(lvl.rawValue).tag(lvl)
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(.white)

                        } else {

                            Picker("Nivel", selection: $divisionesLevel) {
                                ForEach(DivisionesLevel.allCases, id: \.self) { lvl in
                                    Text(lvl.rawValue).tag(lvl)
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(.white)
                        }
                    }

                    // (3) Tablas: tabla
                    if game == .tablas {
                        Picker("Tabla", selection: $tablasTable) {
                            ForEach(TablasTableSelection.allCases) { t in
                                Text(t.rawValue).tag(t)
                            }
                        }
                        .pickerStyle(.menu)
                        .foregroundColor(.white)
                    }
                    
                    if game == .divisiones {
                        Picker("Divisor", selection: $divisionesDivisor) {
                            Text("Todos").tag("all")
                            ForEach(1...9, id: \.self) { n in
                                Text("Divisor: \(n)").tag("\(n)")
                            }
                        }
                        .pickerStyle(.menu)
                        .foregroundColor(.white)
                    }

                    
                }
                .padding(.horizontal, 18)
                
                // ℹ️ Info ranking local
                VStack(spacing: 12) {

                    Text("⭐⭐⭐")
                        .font(.system(size: 34))

                    Text("Los resultados no se comparten ni se suben a internet.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)



                

                Spacer()

                // 🔽 BOTÓN FIJO ABAJO (igual que Suma10 ▶ Play)
                GeometryReader { geo in
                    Button {
                        openRanking()
                    } label: {
                        Text("Ver ranking")
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(width: geo.size.width * 0.9)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 56)
                .padding(.bottom, 20)

                NavigationLink(
                    destination: rankingDestination,
                    isActive: $navigateToRanking
                ) {
                    EmptyView()
                }

            }

            // ✅ Popup reset (overlay)
            if showResetPopup {
                resetOverlay
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Open

    private func openRanking() {
        let challenge = selectedChallengeID()
        currentChallenge = challenge
        ranking = RankingManager.shared.loadRanking(for: challenge)

        DispatchQueue.main.async {
            navigateToRanking = true
        }
    }

    private func selectedChallengeID() -> ChallengeID {
        switch game {
        case .suma10:
            return challengeForSuma10(level: sumaLevel)
            
        case .sumas:
            return challengeForSumas(
                mode: sumasMode,
                level: sumasLevel
            )
        case .restas:
            return challengeForRestas(
                mode: restasMode,
                level: restasLevel
            )

        case .tablas:
            return challengeForTablas(
                tableId: tablasTable.tableId,
                level: tablasLevel
            )

        case .divisiones:
            return challengeForDivisiones(
                divisorId: divisionesDivisor,
                level: divisionesLevel
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
    
    private func challengeForSumas(mode: SumasMode, level: SumasLevel) -> ChallengeID {

        switch (mode, level) {

        case (.sin, .initLevel): return .sumas_sin_iniciacion
        case (.sin, .easy):      return .sumas_sin_facil
        case (.sin, .normal):    return .sumas_sin_normal
        case (.sin, .hard):      return .sumas_sin_dificil

        case (.con, .initLevel): return .sumas_con_iniciacion
        case (.con, .easy):      return .sumas_con_facil
        case (.con, .normal):    return .sumas_con_normal
        case (.con, .hard):      return .sumas_con_dificil
        }
    }
    
    private func challengeForRestas(mode: SumasMode, level: SumasLevel) -> ChallengeID {

        switch (mode, level) {

        case (.sin, .initLevel): return .restas_sin_iniciacion
        case (.sin, .easy):      return .restas_sin_facil
        case (.sin, .normal):    return .restas_sin_normal
        case (.sin, .hard):      return .restas_sin_dificil

        case (.con, .initLevel): return .restas_con_iniciacion
        case (.con, .easy):      return .restas_con_facil
        case (.con, .normal):    return .restas_con_normal
        case (.con, .hard):      return .restas_con_dificil
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

    private var canReset: Bool {
        resetText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "borrar"
    }

    private var resetOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { showResetPopup = false }

            VStack(spacing: 18) {
                Text("Borrar rankings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Escribe \"borrar\" para confirmar")
                    .foregroundColor(.gray)

                ZStack {
                    if resetText.isEmpty {
                        Text("borrar")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.gray.opacity(0.6))
                    }

                    TextField("", text: $resetText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(height: 48)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.yellow, lineWidth: 2)
                )
                .padding(.horizontal, 24)

                Button {
                    RankingManager.shared.resetAllRankings()
                    showResetPopup = false
                } label: {
                    Text("OK")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(width: 160)
                        .padding()
                        .background(canReset ? Color.yellow : Color.gray.opacity(0.4))
                        .foregroundColor(.black)
                        .cornerRadius(14)
                }
                .disabled(!canReset)

                Text("Pulsa fuera para cerrar")
                    .font(.footnote)
                    .foregroundColor(.gray.opacity(0.7))
            }
            .padding(28)
            .frame(maxWidth: 340)
            .background(Color(red: 12/255, green: 18/255, blue: 28/255))
            .cornerRadius(24)
        }
    }
}
