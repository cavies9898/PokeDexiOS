import Foundation
import SwiftUI

enum FilterItem: String, CaseIterable, Identifiable {
    case all = "All"
    case type = "Type"
    case generation = "Generation"
    case region = "Region"
    case habitat = "Habitat"
    case color = "Color"
    case shape = "Shape"
    case alphabet = "Alphabet"
    case total = "Total"
    case hp = "HP"
    case attack = "Attack"
    case defense = "Defense"
    case specialAttack = "Spec. Atk"
    case specialDefense = "Spec. Def"
    case speed = "Speed"
    case id = "Number #"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var systemImage: String {
        switch self {
        case .all: "list.number"
        case .type: "square.grid.2x2"
        case .generation: "sparkles"
        case .region: "globe"
        case .habitat: "tree"
        case .color: "palette"
        case .shape: "line.3.horizontal"
        case .alphabet: "textformat.abc"
        case .total: "list.number"
        case .hp: "heart.fill"
        case .attack: "flame"
        case .defense: "shield"
        case .specialAttack: "bolt"
        case .specialDefense: "lock.shield"
        case .speed: "speedometer"
        case .id: "number"
        }
    }

    var hasOptions: Bool {
        switch self {
        case .type, .generation, .region, .habitat, .color, .shape: true
        default: false
        }
    }

    var selector: ((Pokemon) -> Set<String>)? {
        switch self {
        case .type: { Set($0.types) }
        case .generation: { Set([$0.generation]) }
        case .region: { Set([$0.region]) }
        case .habitat: { pokemon in
            guard let habitat = pokemon.habitat else { return [] }
            return [habitat]
        }
        case .color: { Set([$0.color]) }
        case .shape: { Set([$0.shape]) }
        default: nil
        }
    }

    var categoryValues: (Categories) -> [String] {
        switch self {
        case .type: { $0.type }
        case .generation: { $0.generation }
        case .region: { $0.region }
        case .habitat: { $0.habitat }
        case .color: { $0.color }
        case .shape: { $0.shape }
        default: { _ in [] }
        }
    }
}

struct FilterPipeline {
    static func apply(
        pokemons: [Pokemon],
        searchQuery: String,
        filter: FilterItem?,
        selectedCategories: [String],
        sortAscending: Bool?
    ) -> [Pokemon] {
        var list = pokemons

        if !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            list = list.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
        }

        if let filter, let selector = filter.selector, !selectedCategories.isEmpty {
            let selected = Set(selectedCategories)
            list = list.filter { pokemon in
                selector(pokemon).contains { selected.contains($0) }
            }
        }

        if let sortAscending {
            let comparator = comparator(for: filter)
            list = list.sorted(by: sortAscending ? comparator : { comparator($1, $0) })
        }

        return list
    }

    static func comparator(for filter: FilterItem?) -> (Pokemon, Pokemon) -> Bool {
        switch filter {
        case .hp: { $0.stats.hp < $1.stats.hp }
        case .attack: { $0.stats.attack < $1.stats.attack }
        case .defense: { $0.stats.defense < $1.stats.defense }
        case .specialAttack: { $0.stats.specialAttack < $1.stats.specialAttack }
        case .specialDefense: { $0.stats.specialDefense < $1.stats.specialDefense }
        case .speed: { $0.stats.speed < $1.stats.speed }
        case .alphabet: { $0.name.lowercased() < $1.name.lowercased() }
        case .total: { $0.stats.total < $1.stats.total }
        default: { $0.id < $1.id }
        }
    }

    static func defaultDirection(for item: FilterItem, current: Bool?) -> Bool? {
        switch item {
        case .all: nil
        case .alphabet, .id: true
        case .total, .hp, .attack, .defense, .specialAttack, .specialDefense, .speed: false
        default: current
        }
    }
}
