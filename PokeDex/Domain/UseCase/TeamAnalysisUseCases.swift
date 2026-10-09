import Foundation

struct GetTeamCoverageUseCase: Sendable {
    private let repository: any PokemonRepository

    init(repository: any PokemonRepository) {
        self.repository = repository
    }

    func callAsFunction(ids: [Int]) async throws -> TeamCoverage {
        if ids.isEmpty { return TeamCoverage() }
        return try await repository.teamCoverage(ids: ids)
    }
}

struct GetTeamStatsUseCase: Sendable {
    func callAsFunction(pokemons: [Pokemon]) -> TeamStatsSummary {
        guard !pokemons.isEmpty else { return TeamStatsSummary() }

        let size = pokemons.count
        let averages = (0..<statCount).map { index in
            pokemons.reduce(0) { $0 + $1.stats.value(at: index) } / size
        }

        let leaders = (0..<statCount).map { index -> StatLeader in
            guard let best = pokemons.max(by: {
                $0.stats.value(at: index) < $1.stats.value(at: index)
            }) else {
                return StatLeader(value: 0, pokemon: pokemons[0])
            }
            return StatLeader(value: best.stats.value(at: index), pokemon: best)
        }

        let roles = Role.allCases
            .map { role in
                RoleGroup(role: role, members: pokemons.filter { classifyRole($0) == role })
            }
            .filter { !$0.members.isEmpty }

        return TeamStatsSummary(
            memberCount: size,
            averageTotal: pokemons.reduce(0) { $0 + $1.stats.total } / size,
            averages: averages,
            leaders: leaders,
            ranking: pokemons.sorted { $0.stats.total > $1.stats.total },
            roles: roles
        )
    }

    private func classifyRole(_ pokemon: Pokemon) -> Role {
        let stats = pokemon.stats
        switch true {
        case (stats.defense >= 100 || stats.specialDefense >= 100) && stats.hp >= 75:
            return .tank
        case stats.speed >= 100:
            return .fast
        case stats.attack >= 100 && stats.attack > stats.specialAttack:
            return .physical
        case stats.specialAttack >= 100:
            return .special
        default:
            return .balanced
        }
    }
}

struct AnalyzeTeamUseCase: Sendable {
    func callAsFunction(pokemons: [Pokemon]) -> TeamAnalysis {
        let size = pokemons.count
        guard size > 0 else { return TeamAnalysis() }

        let physical = pokemons.filter { $0.stats.attack >= $0.stats.specialAttack }.count
        let special = size - physical

        let fast = pokemons.filter { $0.stats.speed >= 100 }.count
        let medium = pokemons.filter { (60...99).contains($0.stats.speed) }.count
        let slow = pokemons.filter { $0.stats.speed < 60 }.count

        let typeCounts = Dictionary(
            grouping: pokemons.flatMap(\.types).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            by: { $0 }
        )
            .map { TypeCount(name: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }

        let defensive = pokemons.filter {
            ($0.stats.defense + $0.stats.specialDefense) / 2 >= 90
        }.count

        let average = pokemons.reduce(0) { $0 + $1.stats.total } / size
        let uniqueTypes = typeCounts.count

        var strengths: [String] = []
        if physical > 0 && special > 0 {
            let lo = min(physical, special)
            if Double(lo) / Double(size) >= 0.4 {
                strengths.append("Reparto equilibrado entre ataque físico (\(physical)) y especial (\(special))")
            } else if special > physical {
                strengths.append("Vocación especialista: \(special) de \(size) Pokémon atacan con Ataque Especial")
            } else {
                strengths.append("Vocación ofensiva física: \(physical) de \(size) Pokémon atacan con Ataque")
            }
        }
        if fast >= 2 {
            strengths.append("\(fast) Pokémon rápidos (Velocidad 100 o superior)")
        }
        if uniqueTypes >= 5 {
            strengths.append("\(uniqueTypes) tipos distintos: buena cobertura ofensiva")
        }
        if defensive >= 2 {
            strengths.append("\(defensive) Pokémon defensivos (Defensa y Def. Esp. altas)")
        }
        if average >= 430 {
            strengths.append("Media alta del equipo: \(average) de \(maxTeamScore) por Pokémon")
        }
        if strengths.isEmpty {
            strengths.append("\(size) Pokémon en el equipo")
        }

        var weaknesses: [String] = []
        if slow >= 2 {
            weaknesses.append("\(slow) Pokémon lentos (Velocidad por debajo de 60): llegas tarde a los ataques")
        }
        if physical == 0 || special == 0 {
            let dominated = physical == 0 ? "especial" : "físico"
            weaknesses.append("Todo el equipo es \(dominated): fácil de prever")
        }
        if (1...3).contains(uniqueTypes) {
            weaknesses.append("Solo \(uniqueTypes) tipos: poca variedad en la defensa")
        }
        if defensive == 0 {
            weaknesses.append("Sin Pokémon claramente defensivos")
        }
        if (1...379).contains(average) {
            weaknesses.append("Poder general bajo: media de \(average) de \(maxTeamScore)")
        }
        if size < Team.maxPokemon {
            weaknesses.append("Equipo incompleto: \(size) de \(Team.maxPokemon) Pokémon")
        }

        return TeamAnalysis(
            memberCount: size,
            averageScore: average,
            scoreRatio: Double(average) / Double(maxTeamScore),
            physicalCount: physical,
            specialCount: special,
            fastCount: fast,
            mediumCount: medium,
            slowCount: slow,
            typeCounts: typeCounts,
            defensiveCount: defensive,
            strengths: Array(strengths.prefix(3)),
            weaknesses: Array(weaknesses.prefix(3))
        )
    }
}
