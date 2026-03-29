import Foundation

/// Representa una marca concreta dentro de un ranking.
/// Cada entrada corresponde a una única partida.
struct RankingEntry: Codable, Equatable {

    /// Iniciales introducidas por el jugador (3 letras)
    let initials: String

    /// Número de aciertos obtenidos en la partida
    let score: Int
}
