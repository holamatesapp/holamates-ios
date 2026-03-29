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

                // Header
                // Header
                VStack(spacing: 8) {
                    Text("🏆")
                        .font(.system(size: 44))

                    Text("Ranking")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)


                Text(challenge.title)
                    .font(.title3)
                    .foregroundColor(.gray)

                // Ranking list
                VStack(spacing: 12) {

                    if ranking.isEmpty {

                        VStack(spacing: 12) {
                            Text("😴")
                                .font(.system(size: 48))

                            Text("Todavía no hay resultados")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("¡Sé el primero en jugar!")
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
                    Text("Cerrar")
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
