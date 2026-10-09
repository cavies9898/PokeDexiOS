import Foundation

enum SavePokemonOutcome: Sendable {
    case saved
    case teamFull
    case duplicate
}

protocol PokemonTeamRepository: Sendable {
    func observeTeam(idTeam: Int) async -> AsyncStream<[Pokemon]>
    func team(idTeam: Int) async throws -> [Pokemon]
    func savePokemon(_ pokemon: Pokemon, idTeam: Int) async throws -> SavePokemonOutcome
    func deletePokemon(idPokemon: Int, idTeam: Int) async throws -> Int
}
