import Foundation

enum EvolutionChainOrderer {
    struct Node: Sendable {
        let speciesId: Int
        let evolvesFrom: Int?
        let pokemonId: Int
        let name: String
    }

    static func order(_ nodes: [Node]) -> [Node] {
        guard !nodes.isEmpty else { return [] }

        let bySpecies = Dictionary(uniqueKeysWithValues: nodes.map { ($0.speciesId, $0) })
        let roots = nodes.filter { node in
            guard let from = node.evolvesFrom else { return true }
            return bySpecies[from] == nil
        }

        var ordered: [Node] = []
        var pending: [Node] = Array(roots.isEmpty ? Array(nodes.prefix(1)) : roots)

        while !pending.isEmpty {
            let current = pending.removeFirst()
            if ordered.contains(where: { $0.speciesId == current.speciesId }) { continue }
            ordered.append(current)
            for node in nodes where node.evolvesFrom == current.speciesId {
                pending.append(node)
            }
        }

        for node in nodes where !ordered.contains(where: { $0.speciesId == node.speciesId }) {
            ordered.append(node)
        }

        return ordered
    }

    static func condition(minimumLevel: Int?, trigger: String) -> String {
        if let minimumLevel {
            return "Nv. \(minimumLevel)"
        }
        switch trigger.lowercased() {
        case "level-up": return "Subir de nivel"
        case "trade": return "Intercambio"
        case "use-item": return "Usar objeto"
        default: return trigger.prefix(1).uppercased() + String(trigger.dropFirst())
        }
    }
}
