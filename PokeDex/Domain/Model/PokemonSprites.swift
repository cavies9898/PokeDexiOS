import Foundation

enum PokemonSprites {
    private static let base =
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon"

    static func sprite(_ id: Int) -> String {
        "\(base)/\(id).png"
    }

    static func artwork(_ id: Int) -> String {
        "\(base)/other/official-artwork/\(id).png"
    }
}
