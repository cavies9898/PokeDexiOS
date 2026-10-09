import Foundation

protocol PokemonRepository: Sendable {
    func pokemons() async throws -> [Pokemon]
    func pokemon(byId id: Int) async throws -> Pokemon?
    func pokemonDetail(id: Int) async throws -> PokemonDetail?
    func teamCoverage(ids: [Int]) async throws -> TeamCoverage
}
