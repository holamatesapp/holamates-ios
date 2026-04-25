import SwiftUI

struct RankingView: View {
    
    @Environment(\.dismiss) private var dismiss

    // MARK: - Input
    let challenge: ChallengeID
    let ranking: [RankingEntry]
    let highlightedIndex: Int

    // MARK: - Body
    var body: some View {
        ZStack {
            Color(red: 11/255, green: 15/255, blue: 20/255)
                .ignoresSafeArea()

            VStack(spacing: 24) {

                // 🔙 Botón volver
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

                // 🏆 Header
                VStack(spacing: 10) {
                    
                    Text("🏆")
                        .font(.system(size: 40))
                    
                    Text("Ranking")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Image(imageNameForChallenge())
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .padding(.top, 6)
                }

                // Ranking list
                VStack(spacing: 12) {

                    if ranking.isEmpty {

                        ForEach(0..<5) { index in
                            emptyRankingRow(position: index + 1)
                        }

                    } else {

                        ForEach(ranking.indices, id: \.self) { index in
                            rankingRow(
                                entry: ranking[index],
                                position: index + 1,
                                highlighted: index == highlightedIndex
                            )
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .padding(.top, 20)
        }
        .navigationBarHidden(true)
    }

    // MARK: - Row

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
                .lineLimit(1)
                .fontWeight(highlighted ? .bold : .regular)

            Spacer()

            Text("\(entry.score)")
                .fontWeight(.bold)
        }
        .padding()
        .background(
            highlighted
            ? Color.yellow.opacity(0.85)
            : Color.white.opacity(0.08)
        )
        .foregroundColor(highlighted ? .black : .white)
        .cornerRadius(14)
    }

    // MARK: - Imagen juego

    private func imageNameForChallenge() -> String {
        
        let raw = challenge.rawValue
        
        if raw.contains("suma10") { return "imagen_suma10" }
        if raw.contains("sumas") { return "imagen_sumas" }
        if raw.contains("restas") { return "imagen_restas" }
        if raw.contains("tablas") { return "imagen_multiplicaciones" }
        if raw.contains("divisiones") { return "imagen_divisiones" }
        
        return "imagen_suma10"
    }
}


// MARK: - Empty Row (fuera del struct)

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
            .fontWeight(.bold)
            .foregroundColor(.white.opacity(0.3))
    }
    .padding()
    .background(Color.white.opacity(0.05))
    .cornerRadius(14)
}
