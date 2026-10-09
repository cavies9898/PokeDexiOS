import Foundation

struct TypeChartQueries: Sendable {
    private let database: PokedexDatabase

    init(database: PokedexDatabase) {
        self.database = database
    }

    func typeChart() async throws -> TypeChart {
        let rows = try await database.rows(
            """
            SELECT te.damage_type_id, t.identifier, te.target_type_id, te.damage_factor
            FROM type_efficacy te
            JOIN types t ON t.id = te.damage_type_id
            """
        )

        var attackerNames: [Int: String] = [:]
        var factors: [String: Int] = [:]

        for row in rows {
            let attackerId = row.int("damage_type_id")
            if attackerNames[attackerId] == nil {
                attackerNames[attackerId] = row.text("identifier")
            }
            factors["\(attackerId)-\(row.int("target_type_id"))"] = row.int("damage_factor")
        }

        let attackers = attackerNames
            .map { TypeChart.Attacker(id: $0.key, name: $0.value) }
            .sorted { $0.name < $1.name }

        return TypeChart(attackers: attackers, factors: factors)
    }

    func ownTypeIds(pokemonIds: [Int]) async throws -> [Int: [Int]] {
        guard !pokemonIds.isEmpty else { return [:] }

        let placeholders = Array(repeating: "?", count: pokemonIds.count).joined(separator: ",")
        let params = pokemonIds.map { SQLiteValue.integer(Int64($0)) }
        let rows = try await database.rows(
            """
            SELECT pokemon_id, type_id
            FROM pokemon_types
            WHERE pokemon_id IN (\(placeholders))
            ORDER BY pokemon_id, slot
            """,
            params: params
        )

        var result: [Int: [Int]] = [:]
        for row in rows {
            result[row.int("pokemon_id"), default: []].append(row.int("type_id"))
        }
        return result
    }

    func ownTypes(pokemonId: Int) async throws -> [(id: Int, name: String)] {
        try await database.rows(
            """
            SELECT t.id, t.identifier
            FROM pokemon_types pt
            JOIN types t ON t.id = pt.type_id
            WHERE pt.pokemon_id = ?
            ORDER BY pt.slot
            """,
            params: [.integer(Int64(pokemonId))]
        )
        .map { (id: $0.int("id"), name: $0.text("identifier")) }
    }

    func weaknesses(pokemonId: Int) async throws -> [TypeEffectiveness] {
        let types = try await ownTypes(pokemonId: pokemonId)
        guard !types.isEmpty else { return [] }
        let chart = try await typeChart()
        return chart.weaknesses(ownTypes: types)
    }
}
