import Foundation

struct PokemonRepositoryImpl: PokemonRepository {
    private let database: PokedexDatabase
    private let detailQueries: PokemonDetailQueries
    private let typeChartQueries: TypeChartQueries

    init(database: PokedexDatabase) {
        self.database = database
        detailQueries = PokemonDetailQueries(database: database)
        typeChartQueries = TypeChartQueries(database: database)
    }

    func pokemons() async throws -> [Pokemon] {
        if let cached = await database.loadCachedPokemons() {
            return cached
        }
        let pokemons = try await loadPokemons()
        await database.storePokemons(pokemons)
        return pokemons
    }

    func pokemon(byId id: Int) async throws -> Pokemon? {
        let rows = try await database.rows(
            """
            SELECT
                p.id,
                psn.name AS pokemon_name,
                p.identifier AS identifier,
                g.identifier AS generation,
                rn.name AS region,
                h.identifier AS habitat,
                c.identifier AS color,
                s.identifier AS shape
            FROM pokemon p
            LEFT JOIN pokemon_species ps2 ON ps2.id = p.species_id
            LEFT JOIN pokemon_species_names psn
                   ON psn.pokemon_species_id = ps2.id
                   AND psn.local_language_id = 9
            LEFT JOIN generations g ON g.id = ps2.generation_id
            LEFT JOIN region_names rn
                   ON rn.region_id = g.main_region_id
                   AND rn.local_language_id = 9
            LEFT JOIN pokemon_habitats h ON h.id = ps2.habitat_id
            LEFT JOIN pokemon_colors c ON c.id = ps2.color_id
            LEFT JOIN pokemon_shapes s ON s.id = ps2.shape_id
            WHERE p.id = ?
            LIMIT 1;
            """,
            params: [.integer(Int64(id))]
        )

        guard let row = rows.first else { return nil }

        return Pokemon(
            id: id,
            name: DisplayNameFormatter.displayName(
                identifier: row.text("identifier"),
                speciesName: row.optionalText("pokemon_name")
            ),
            imageUrl: PokemonSprites.artwork(id),
            stats: try await loadStats(id: id),
            types: try await loadTypes(id: id),
            generation: row.text("generation"),
            region: row.text("region"),
            habitat: row.optionalText("habitat"),
            color: row.text("color"),
            shape: row.text("shape")
        )
    }

    func pokemonDetail(id: Int) async throws -> PokemonDetail? {
        guard let pokemon = try await pokemon(byId: id) else { return nil }
        guard let speciesId = try await speciesId(pokemonId: id) else { return nil }

        return PokemonDetail(
            pokemon: pokemon,
            description: try await detailQueries.description(speciesId: speciesId),
            heightMeters: try await detailQueries.doubleValue(column: "height", id: id) / 10.0,
            weightKg: try await detailQueries.doubleValue(column: "weight", id: id) / 100.0,
            captureRate: try await detailQueries.intValue(column: "capture_rate", id: speciesId, table: "pokemon_species"),
            growthRate: try await detailQueries.growthRate(speciesId: speciesId),
            genderRate: try await detailQueries.intValue(column: "gender_rate", id: speciesId, table: "pokemon_species"),
            hatchSteps: try await detailQueries.intValue(column: "hatch_counter", id: speciesId, table: "pokemon_species"),
            abilities: try await detailQueries.abilities(pokemonId: id),
            moves: try await detailQueries.moves(pokemonId: id),
            evolutionChain: try await detailQueries.evolutionChain(speciesId: speciesId),
            weaknesses: try await typeChartQueries.weaknesses(pokemonId: id)
        )
    }

    func teamCoverage(ids: [Int]) async throws -> TeamCoverage {
        guard !ids.isEmpty else { return TeamCoverage() }

        let chart = try await typeChartQueries.typeChart()
        let ownTypes = try await typeChartQueries.ownTypeIds(pokemonIds: ids)

        return chart.coverage(ownTypesByPokemon: ownTypes, ids: ids)
    }

    // MARK: - Catalog

    private func loadPokemons() async throws -> [Pokemon] {
        let rows = try await database.rows(
            """
            SELECT DISTINCT
                p.id,
                psn.name AS pokemon_name,
                p.identifier AS identifier,
                t.identifier AS type,

                g.identifier AS generation,
                rn.name AS region,

                h.identifier AS habitat,
                c.identifier AS color,
                s.identifier AS shape,

                st.identifier AS stat_name,
                ps.base_stat AS stat_value,

                pt.slot AS type_slot

            FROM pokemon p
            LEFT JOIN pokemon_species ps2 ON ps2.id = p.species_id
            LEFT JOIN pokemon_species_names psn
                   ON psn.pokemon_species_id = ps2.id
                   AND psn.local_language_id = 9

            LEFT JOIN generations g ON g.id = ps2.generation_id
            LEFT JOIN region_names rn
                   ON rn.region_id = g.main_region_id
                   AND rn.local_language_id = 9

            LEFT JOIN pokemon_habitats h ON h.id = ps2.habitat_id
            LEFT JOIN pokemon_colors c ON c.id = ps2.color_id
            LEFT JOIN pokemon_shapes s ON s.id = ps2.shape_id

            LEFT JOIN pokemon_types pt ON pt.pokemon_id = p.id
            LEFT JOIN types t ON t.id = pt.type_id

            LEFT JOIN pokemon_stats ps ON ps.pokemon_id = p.id
            LEFT JOIN stats st ON st.id = ps.stat_id

            ORDER BY p.id, pt.slot;
            """
        )

        var result: [Int: Pokemon] = [:]
        var orderedIds: [Int] = []
        var statsTemp: [Int: [String: Int]] = [:]

        for row in rows {
            let id = row.int("id")
            let displayName = DisplayNameFormatter.displayName(
                identifier: row.text("identifier"),
                speciesName: row.optionalText("pokemon_name")
            )

            if result[id] == nil {
                result[id] = Pokemon(
                    id: id,
                    name: displayName,
                    imageUrl: PokemonSprites.artwork(id),
                    types: [],
                    generation: row.text("generation"),
                    region: row.text("region"),
                    habitat: row.optionalText("habitat"),
                    color: row.text("color"),
                    shape: row.text("shape")
                )
                orderedIds.append(id)
            }

            if let type = row.optionalText("type"), !result[id]!.types.contains(type) {
                result[id]!.types.append(type)
            }

            if let statName = row.optionalText("stat_name") {
                statsTemp[id, default: [:]][statName] = row.int("stat_value")
            }
        }

        return orderedIds.compactMap { id in
            guard var pokemon = result[id] else { return nil }
            let stats = statsTemp[id] ?? [:]
            pokemon.stats = PokemonStats(
                hp: stats["hp"] ?? 0,
                attack: stats["attack"] ?? 0,
                defense: stats["defense"] ?? 0,
                specialAttack: stats["special-attack"] ?? 0,
                specialDefense: stats["special-defense"] ?? 0,
                speed: stats["speed"] ?? 0,
                total: stats.values.reduce(0, +)
            )
            return pokemon
        }
    }

    private func loadTypes(id: Int) async throws -> [String] {
        try await database.rows(
            """
            SELECT t.identifier
            FROM pokemon_types pt
            JOIN types t ON t.id = pt.type_id
            WHERE pt.pokemon_id = ?
            ORDER BY pt.slot
            """,
            params: [.integer(Int64(id))]
        )
        .map { $0.text("identifier") }
    }

    private func loadStats(id: Int) async throws -> PokemonStats {
        let rows = try await database.rows(
            """
            SELECT st.identifier, ps.base_stat
            FROM pokemon_stats ps
            JOIN stats st ON st.id = ps.stat_id
            WHERE ps.pokemon_id = ?
            """,
            params: [.integer(Int64(id))]
        )

        var stats: [String: Int] = [:]
        for row in rows {
            stats[row.text("identifier")] = row.int("base_stat")
        }

        return PokemonStats(
            hp: stats["hp"] ?? 0,
            attack: stats["attack"] ?? 0,
            defense: stats["defense"] ?? 0,
            specialAttack: stats["special-attack"] ?? 0,
            specialDefense: stats["special-defense"] ?? 0,
            speed: stats["speed"] ?? 0,
            total: stats.values.reduce(0, +)
        )
    }

    private func speciesId(pokemonId: Int) async throws -> Int? {
        let row = try await database.firstRow(
            "SELECT species_id FROM pokemon WHERE id = ?;",
            params: [.integer(Int64(pokemonId))]
        )
        guard let row else { return nil }
        return row.isNull("species_id") ? nil : row.int("species_id")
    }
}
