import SwiftUI

struct RankingConfigView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var isEnabled: Bool = true

    var body: some View {
        ZStack {
            Color(red: 11/255, green: 15/255, blue: 20/255)
                .ignoresSafeArea()

            VStack(spacing: 18) {

                // HEADER IGUAL QUE EN RankingsView
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

                    // hueco para mantener el título centrado
                    Color.clear
                        .frame(width: 36, height: 36)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                VStack(spacing: 6) {
                    Text("⚙️")
                        .font(.system(size: 34))

                    Text("Ranking")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.top, 4)

                VStack(spacing: 24) {

                    Text("🇪🇸 Al pulsar OFF se borran todos los rankings\n🇬🇧Tap OFF to delete all rankings")
                    

                    
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    VStack(spacing: 24) {

                        Text("Ranking")
                            .foregroundColor(.yellow)
                            .font(.title3)
                            .fontWeight(.bold)

                        HStack(spacing: 16) {
                            Text("OFF")
                                .foregroundColor(.white)
                                .fontWeight(.bold)

                            ZStack {
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(isEnabled ? Color.blue : Color.gray.opacity(0.35))
                                    .frame(width: 84, height: 40)

                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 30, height: 30)
                                    .offset(x: isEnabled ? 20 : -20)
                                    .animation(.easeInOut(duration: 0.2), value: isEnabled)
                            }
                            .onTapGesture {
                                isEnabled.toggle()
                                RankingManager.shared.resetAllRankings()
                            }

                            Text("ON")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 12/255, green: 18/255, blue: 28/255))
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.white.opacity(0.08))
                    )

                    Text("🇪🇸 El ranking se guarda en este dispositivo\n🇬🇧 Stored locally on this device")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 16)

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            isEnabled = true
        }
    }
}
