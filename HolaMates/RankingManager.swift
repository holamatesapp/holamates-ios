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
        "ranking_\(challenge.rawValue)"
    }
}
