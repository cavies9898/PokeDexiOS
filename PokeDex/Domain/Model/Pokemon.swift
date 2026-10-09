import Foundation

struct Pokemon: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let imageUrl: String?
    var stats: PokemonStats
    var types: [String]
    let generation: String
    let region: String
    let habitat: String?
    let color: String
    let shape: String
    var isFavorite: Bool

    init(
        id: Int = 0,
        name: String = "",
        imageUrl: String? = "",
        stats: PokemonStats = PokemonStats(),
        types: [String] = [],
        generation: String = "",
        region: String = "",
        habitat: String? = "",
        color: String = "",
        shape: String = "",
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.stats = stats
        self.types = types
        self.generation = generation
        self.region = region
        self.habitat = habitat
        self.color = color
        self.shape = shape
        self.isFavorite = isFavorite
    }
}
