import SwiftUI

struct TimelineBar: View {

    /// Progreso entre 0.0 y 1.0
    let progress: Double

    /// Fin por fallo
    let isFail: Bool

    /// Fin por tiempo (nuevo, opcional)
    let isTimeUp: Bool

    init(
        progress: Double,
        isFail: Bool,
        isTimeUp: Bool = false   // ⬅️ clave
    ) {
        self.progress = progress
        self.isFail = isFail
        self.isTimeUp = isTimeUp
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .trailing) {

                Capsule()
                    .fill(Color.white.opacity(0.15))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: barColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progress)
            }
        }
        .frame(height: 6)
        .cornerRadius(999)
    }

    private var barColors: [Color] {
        if isTimeUp {
            // ⏱️ Tiempo agotado → rojo sólido
            return [Color.red, Color.red]
        }

        if isFail {
            // ❌ Fallo → rojo hasta donde llegó
            return [Color.red, Color(red: 0.6, green: 0, blue: 0)]
        }

        // ▶️ Jugando
        return [Color.green, Color.green.opacity(0.75)]
    }
}
