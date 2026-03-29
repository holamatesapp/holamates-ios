import SwiftUI

struct RankingViewEn: View {
    
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

                // Header
                VStack(spacing: 8) {
                    Text("🏆")
                        .font(.system(size: 44))

                    Text("Ranking")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)

                Text(challengeTitleEn())
                    .font(.title3)
                    .foregroundColor(.gray)

                // Ranking list
                VStack(spacing: 12) {

                    if ranking.isEmpty {

                        VStack(spacing: 12) {
                            Text("😴")
                                .font(.system(size: 48))

                            Text("No results yet")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("Be the first to play!")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 32)

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

                // Close button
                Button {
                    dismiss()
                } label: {
                    Text("Close")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }

            }
            .padding()
            .padding(.top, 20)
        }
        .navigationBarHidden(true)
    }

    // MARK: - Title mapping EN

    private func challengeTitleEn() -> String {
        let title = challenge.title

        var result = title
            // Juegos
            .replacingOccurrences(of: "Suma 10", with: "Sum 10")
            .replacingOccurrences(of: "Sumas", with: "Additions")
            .replacingOccurrences(of: "Restas", with: "Subtractions")
            .replacingOccurrences(of: "Multiplicaciones", with: "Multiplications")
            .replacingOccurrences(of: "Divisiones", with: "Divisions")

            // Niveles
            .replacingOccurrences(of: "Iniciación", with: "Beginner")
            .replacingOccurrences(of: "Fácil", with: "Easy")
            .replacingOccurrences(of: "Medio", with: "Medium")
            .replacingOccurrences(of: "Difícil", with: "Hard")

            // Tablas
            .replacingOccurrences(of: "Todas", with: "All")
            .replacingOccurrences(of: "Tabla del ", with: "Table ")

            // Divisiones
            .replacingOccurrences(of: "Todos", with: "All")
            .replacingOccurrences(of: "Divisor: ", with: "Divisor ")

        // 🔥 TRADUCCIÓN INTELIGENTE DE LLEVADA

        if title.contains("Sin llevada") {
            if title.contains("Restas") {
                result = result.replacingOccurrences(of: "Sin llevada", with: "No borrowing")
            } else {
                result = result.replacingOccurrences(of: "Sin llevada", with: "No carry")
            }
        }

        if title.contains("Con llevada") {
            if title.contains("Restas") {
                result = result.replacingOccurrences(of: "Con llevada", with: "With borrowing")
            } else {
                result = result.replacingOccurrences(of: "Con llevada", with: "With carry")
            }
        }

        return result
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
}
