import Foundation

struct PokemonTeamRepositoryImpl: PokemonTeamRepository {
    private let database: UserDatabase

    init(database: UserDatabase) {
        self.database = database
    }

    func observeTeam(idTeam: Int) async -> AsyncStream<[Pokemon]> {
        let database = self.database
        return AsyncStream { continuation in
            let task = Task {
                let changes = await database.changesStream()
                for await _ in changes {
                    if Task.isCancelled { break }
                    do {
                        let records = try await database.teamMembers(idTeam: idTeam)
                        continuation.yield(records.map { PokemonMapper.fromRecord($0) })
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

    func team(idTeam: Int) async throws -> [Pokemon] {
        try await database.teamMembers(idTeam: idTeam)
            .map { PokemonMapper.fromRecord($0) }
    }

    func savePokemon(_ pokemon: Pokemon, idTeam: Int) async throws -> SavePokemonOutcome {
        try await database.savePokemon(pokemon, idTeam: idTeam)
    }

    func deletePokemon(idPokemon: Int, idTeam: Int) async throws -> Int {
        try await database.deletePokemon(idPokemon: idPokemon, idTeam: idTeam)
    }
}
