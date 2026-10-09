import Foundation

struct Team: Identifiable, Hashable, Sendable {
    static let maxPokemon = 6

    let id: Int
    let name: String
    let pokemonCount: Int
    let pokemonIds: [Int]
    let sprites: [String]

    init(
        id: Int = 0,
        name: String = "",
        pokemonCount: Int = 0,
        pokemonIds: [Int] = [],
        sprites: [String] = []
    ) {
        self.id = id
        self.name = name
        self.pokemonCount = pokemonCount
        self.pokemonIds = pokemonIds
        self.sprites = sprites
    }
}
