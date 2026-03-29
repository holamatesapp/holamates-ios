import SwiftUI

struct AddRankingEntryView: View {

    let challenge: ChallengeID
    let score: Int

    /// Callback al guardar la marca
    let onSave: (_ ranking: [RankingEntry], _ newIndex: Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var initials: String = ""

    var body: some View {
        ZStack {

            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .preferredColorScheme(.dark)
                .onTapGesture { dismiss() }

            VStack(spacing: 20) {

                Text("Añadir marca")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Aciertos: \(score)")
                    .foregroundColor(.gray)

                ZStack {
                    if initials.isEmpty {
                        Text("ABC")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.gray.opacity(0.6))
                    }

                    TextField("", text: $initials)
                        .textInputAutocapitalization(.characters)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(height: 52)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.yellow, lineWidth: 2)
                )
                .padding(.horizontal, 24)
                .onChange(of: initials) { newValue in
                    initials = String(
                        newValue
                            .uppercased()
                            .filter { $0.isLetter }
                            .prefix(3)
                    )
                }

                Button {
                    save()
                } label: {
                    Text("OK")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(width: 160)
                        .padding()
                        .background(canSave ? Color.yellow : Color.gray.opacity(0.4))
                        .foregroundColor(.black)
                        .cornerRadius(14)
                }
                .disabled(!canSave)
            }
            .padding(32)
            .frame(maxWidth: 340)
            .background(Color(red: 12/255, green: 18/255, blue: 28/255))
            .cornerRadius(24)
        }
    }

    private var canSave: Bool {
        initials.count == 3
    }

    private func save() {
        let result = RankingManager.shared.addEntry(
            initials: initials,
            score: score,
            challenge: challenge
        )

        onSave(result.ranking, result.index)
        dismiss()
    }
}
