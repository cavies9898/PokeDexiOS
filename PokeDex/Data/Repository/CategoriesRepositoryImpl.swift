import Foundation

struct CategoriesRepositoryImpl: CategoriesRepository {
    private let database: PokedexDatabase

    init(database: PokedexDatabase) {
        self.database = database
    }

    func categories() async throws -> Categories {
        let rows = try await database.rows(
            """
            SELECT 'type' AS category_name, t.identifier AS value
            FROM types t

            UNION

            SELECT 'generation', g.identifier
            FROM generations g

            UNION

            SELECT 'region', rn.name
            FROM region_names rn
            WHERE rn.local_language_id = 9

            UNION

            SELECT 'habitat', h.identifier
            FROM pokemon_habitats h

            UNION

            SELECT 'color', c.identifier
            FROM pokemon_colors c

            UNION

            SELECT 'shape', s.identifier
            FROM pokemon_shapes s;
            """
        )

        var type: [String] = []
        var generation: [String] = []
        var region: [String] = []
        var habitat: [String] = []
        var color: [String] = []
        var shape: [String] = []

        for row in rows {
            switch row.text("category_name") {
            case "type": type.append(row.text("value"))
            case "generation": generation.append(row.text("value"))
            case "region": region.append(row.text("value"))
            case "habitat": habitat.append(row.text("value"))
            case "color": color.append(row.text("value"))
            case "shape": shape.append(row.text("value"))
            default: break
            }
        }

        return Categories(
            type: type.sorted(),
            generation: generation.sorted(),
            region: region.sorted(),
            habitat: habitat.sorted(),
            color: color.sorted(),
            shape: shape.sorted()
        )
    }
}
