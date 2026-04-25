import Foundation

final class RankingManager {

    static let shared = RankingManager()
    private init() {}

    // MARK: - Public API

    func loadRanking(for challenge: ChallengeID) -> [RankingEntry] {
        let key = storageKey(for: challenge)
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let ranking = try? JSONDecoder().decode([RankingEntry].self, from: data)
        else {
            return []
        }
        return ranking
    }

    func qualifiesForTop5(score: Int, challenge: ChallengeID) -> Bool {
        let ranking = loadRanking(for: challenge)
        if ranking.count < 5 { return true }
        return score >= (ranking.last?.score ?? 0)
    }

    @discardableResult
    func addEntry(
        initials: String,
        score: Int,
        challenge: ChallengeID
    ) -> (ranking: [RankingEntry], index: Int) {

        var ranking = loadRanking(for: challenge)
        let newEntry = RankingEntry(initials: initials, score: score)

        let index = ranking.firstIndex { score >= $0.score } ?? ranking.count
        ranking.insert(newEntry, at: index)

        if ranking.count > 5 {
            ranking = Array(ranking.prefix(5))
        }

        saveRanking(ranking, for: challenge)
        return (ranking, index)
    }

    // ✅ NUEVO: reset global
    func resetAllRankings() {
        for challenge in ChallengeID.allCases {
            let key = storageKey(for: challenge)
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    // MARK: - Persistence

    private func saveRanking(_ ranking: [RankingEntry], for challenge: ChallengeID) {
        let key = storageKey(for: challenge)
        guard let data = try? JSONEncoder().encode(ranking) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func storageKey(for challenge: ChallengeID) -> String {

        let raw = challenge.rawValue

        // ✅ SUMA10 (global)
        if raw.contains("suma10") {
            return "ranking_suma10"
        }

        // ✅ SUMAS (global)
        if raw.contains("sumas") {
            return "ranking_sumas"
        }

        // ✅ RESTAS (global)
        if raw.contains("restas") {
            return "ranking_restas"
        }

        // ✅ TABLAS (por número)
        if raw.contains("tablas") {

            if raw.contains("_all_") {
                return "ranking_tablas_all"
            }

            for i in 2...9 {
                if raw.contains("_\(i)_") {
                    return "ranking_tablas_\(i)"
                }
            }

            return "ranking_tablas_all"
        }

        // ✅ DIVISIONES (por divisor)
        if raw.contains("divisiones") {

            if raw.contains("_all_") {
                return "ranking_divisiones_all"
            }

            for i in 1...9 {
                if raw.contains("_\(i)_") {
                    return "ranking_divisiones_\(i)"
                }
            }

            return "ranking_divisiones_all"
        }

        // fallback (por si acaso)
        return "ranking_\(raw)"
    }
}
