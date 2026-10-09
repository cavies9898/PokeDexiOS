import Foundation

struct TeamRepositoryImpl: TeamRepository {
    private let database: UserDatabase

    init(database: UserDatabase) {
        self.database = database
    }

    func observeTeams() async -> AsyncStream<[Team]> {
        let database = self.database
        return AsyncStream { continuation in
            let task = Task {
                let changes = await database.changesStream()
                for await _ in changes {
                    if Task.isCancelled { break }
                    do {
                        let teams = try await loadTeams(database: database)
                        continuation.yield(teams)
                    } catch {
                        continuation.finish()
                        return
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func createTeam(name: String) async throws -> Int {
        try await database.insertTeam(name: name)
    }

    func renameTeam(id: Int, name: String) async throws {
        try await database.renameTeam(id: id, name: name)
    }

    func deleteTeam(id: Int) async throws {
        try await database.deleteTeam(id: id)
    }

    private func loadTeams(database: UserDatabase) async throws -> [Team] {
        let teams = try await database.teamRows()
        let counts = try await database.teamCounts()
        let pokemonIds = try await database.teamPokemonIds()

        var idsByTeam: [Int: [Int]] = [:]
        for entry in pokemonIds {
            idsByTeam[entry.idTeam, default: []].append(entry.idPokemon)
        }

        return teams.map { team in
            let ids = idsByTeam[team.id] ?? []
            return Team(
                id: team.id,
                name: team.name,
                pokemonCount: counts[team.id] ?? ids.count,
                pokemonIds: ids,
                sprites: ids.map { PokemonSprites.sprite($0) }
            )
        }
    }
}
