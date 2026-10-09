import Foundation

struct TypeChart: Sendable {
    struct Attacker: Sendable {
        let id: Int
        let name: String
    }

    let attackers: [Attacker]
    let factors: [String: Int]

    init(attackers: [Attacker], factors: [String: Int]) {
        self.attackers = attackers
        self.factors = factors
    }

    func multiplier(attackingTypeId: Int, ownTypeIds: [Int]) -> Double {
        ownTypeIds.reduce(1.0) { acc, targetId in
            acc * Double(factors["\(attackingTypeId)-\(targetId)"] ?? 100) / 100.0
        }
    }

    func coverage(ownTypesByPokemon: [Int: [Int]], ids: [Int]) -> TeamCoverage {
        guard !ids.isEmpty else { return TeamCoverage() }

        let rows = attackers.map { attacker -> TypeCoverageRow in
            var resistant = 0
            var weak = 0
            var neutral = 0

            for pokemonId in ids {
                let ownTypes = ownTypesByPokemon[pokemonId] ?? []
                if ownTypes.isEmpty {
                    neutral += 1
                    continue
                }
                let multiplier = multiplier(attackingTypeId: attacker.id, ownTypeIds: ownTypes)
                if multiplier > 1.0 {
                    weak += 1
                } else if multiplier < 1.0 {
                    resistant += 1
                } else {
                    neutral += 1
                }
            }

            return TypeCoverageRow(
                type: attacker.name,
                resistant: resistant,
                weak: weak,
                neutral: neutral
            )
        }
        .sorted {
            if $0.score != $1.score { return $0.score > $1.score }
            return $0.type < $1.type
        }

        return TeamCoverage(memberCount: ids.count, rows: rows)
    }

    func weaknesses(ownTypes: [(id: Int, name: String)]) -> [TypeEffectiveness] {
        let typeIds = ownTypes.map(\.id)
        guard !typeIds.isEmpty else { return [] }

        var grouped: [Int: (name: String, values: [Int])] = [:]
        for attacker in attackers {
            let values = typeIds.compactMap { factors["\(attacker.id)-\($0)"] }
            grouped[attacker.id] = (attacker.name, values)
        }

        return grouped.compactMap { _, entry -> TypeEffectiveness? in
            guard entry.values.count == typeIds.count else { return nil }
            let multiplier = entry.values.reduce(1.0) { acc, factor in
                acc * Double(factor) / 100.0
            }
            return TypeEffectiveness(type: entry.name, multiplier: multiplier)
        }
        .filter { $0.multiplier != 1.0 }
        .sorted {
            if $0.multiplier != $1.multiplier { return $0.multiplier > $1.multiplier }
            return $0.type < $1.type
        }
    }
}
