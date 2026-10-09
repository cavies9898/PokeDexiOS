import Foundation

struct PokemonDetailQueries: Sendable {
    private let database: PokedexDatabase

    init(database: PokedexDatabase) {
        self.database = database
    }

    func doubleValue(column: String, id: Int) async throws -> Double {
        let row = try await database.firstRow(
            "SELECT \(column) FROM pokemon WHERE id = ?;",
            params: [.integer(Int64(id))]
        )
        return row?.double(column) ?? 0.0
    }

    func intValue(column: String, id: Int, table: String) async throws -> Int {
        let row = try await database.firstRow(
            "SELECT \(column) FROM \(table) WHERE id = ?;",
            params: [.integer(Int64(id))]
        )
        return row?.int(column) ?? 0
    }

    func growthRate(speciesId: Int) async throws -> String {
        let row = try await database.firstRow(
            """
            SELECT gr.identifier
            FROM pokemon_species ps
            LEFT JOIN growth_rates gr ON gr.id = ps.growth_rate_id
            WHERE ps.id = ?
            """,
            params: [.integer(Int64(speciesId))]
        )
        guard let row, !row.isNull("identifier") else { return "" }
        return row.text("identifier")
    }

    func description(speciesId: Int) async throws -> String {
        let row = try await database.firstRow(
            """
            SELECT flavor_text
            FROM pokemon_species_flavor_text
            WHERE species_id = ? AND language_id IN (7, 9)
            ORDER BY CASE language_id WHEN 7 THEN 0 ELSE 1 END, version_id DESC
            LIMIT 1
            """,
            params: [.integer(Int64(speciesId))]
        )
        guard let text = row?.optionalText("flavor_text") else { return "" }
        return collapseWhitespace(text)
    }

    func abilities(pokemonId: Int) async throws -> [PokemonAbility] {
        try await database.rows(
            """
            SELECT an.name, pa.is_hidden
            FROM pokemon_abilities pa
            JOIN ability_names an
              ON an.ability_id = pa.ability_id AND an.local_language_id = 9
            WHERE pa.pokemon_id = ?
            ORDER BY pa.slot
            """,
            params: [.integer(Int64(pokemonId))]
        )
        .map { row in
            PokemonAbility(
                name: row.text("name"),
                isHidden: row.int("is_hidden") == 1
            )
        }
    }

    func moves(pokemonId: Int) async throws -> [PokemonMove] {
        try await database.rows(
            """
            SELECT pm.level, mn.name, t.identifier AS type, mdc.identifier AS damage_class,
                   m.power, m.accuracy, m.pp
            FROM pokemon_moves pm
            JOIN moves m ON m.id = pm.move_id
            JOIN move_names mn
              ON mn.move_id = m.id AND mn.local_language_id = 9
            JOIN types t ON t.id = m.type_id
            JOIN move_damage_classes mdc ON mdc.id = m.damage_class_id
            WHERE pm.pokemon_id = ?
              AND pm.pokemon_move_method_id = 1
              AND pm.version_group_id = (
                  SELECT MAX(version_group_id)
                  FROM pokemon_moves
                  WHERE pokemon_id = pm.pokemon_id
                    AND pokemon_move_method_id = 1
              )
            ORDER BY pm.level, mn.name
            """,
            params: [.integer(Int64(pokemonId))]
        )
        .map { row in
            PokemonMove(
                name: row.text("name"),
                level: row.int("level"),
                type: row.text("type"),
                damageClass: row.text("damage_class"),
                power: row.optionalInt("power"),
                accuracy: row.optionalInt("accuracy"),
                pp: row.optionalInt("pp")
            )
        }
    }

    func evolutionChain(speciesId: Int) async throws -> [EvolutionStage] {
        let chainRow = try await database.firstRow(
            "SELECT evolution_chain_id FROM pokemon_species WHERE id = ?;",
            params: [.integer(Int64(speciesId))]
        )
        guard let chainRow, !chainRow.isNull("evolution_chain_id") else { return [] }
        let chainId = chainRow.int("evolution_chain_id")

        var conditions: [Int: String] = [:]
        let evolutionRows = try await database.rows(
            """
            SELECT pe.evolved_species_id, pe.minimum_level, et.identifier
            FROM pokemon_evolution pe
            JOIN evolution_triggers et ON et.id = pe.evolution_trigger_id
            """
        )
        for row in evolutionRows {
            let evolvedSpecies = row.int("evolved_species_id")
            let minimumLevel = row.isNull("minimum_level") ? nil : row.int("minimum_level")
            conditions[evolvedSpecies] = EvolutionChainOrderer.condition(
                minimumLevel: minimumLevel,
                trigger: row.text("identifier")
            )
        }

        let nodeRows = try await database.rows(
            """
            SELECT ps.id, ps.evolves_from_species_id, p.id AS default_pokemon_id, psn.name, p.identifier
            FROM pokemon_species ps
            JOIN pokemon p ON p.species_id = ps.id AND p.is_default = 1
            LEFT JOIN pokemon_species_names psn
                   ON psn.pokemon_species_id = ps.id AND psn.local_language_id = 9
            WHERE ps.evolution_chain_id = ?
            """,
            params: [.integer(Int64(chainId))]
        )

        let nodes: [EvolutionChainOrderer.Node] = nodeRows.map { row in
            EvolutionChainOrderer.Node(
                speciesId: row.int("id"),
                evolvesFrom: row.isNull("evolves_from_species_id")
                    ? nil
                    : row.int("evolves_from_species_id"),
                pokemonId: row.int("default_pokemon_id"),
                name: row.text("name")
            )
        }

        guard !nodes.isEmpty else { return [] }

        return EvolutionChainOrderer.order(nodes).map { node in
            let displayName = node.name.isEmpty ? String(node.speciesId) : node.name
            return EvolutionStage(
                id: node.speciesId,
                pokemonId: node.pokemonId,
                name: displayName.prefix(1).uppercased() + String(displayName.dropFirst()),
                spriteUrl: PokemonSprites.sprite(node.pokemonId),
                condition: conditions[node.speciesId] ?? "",
                isCurrent: node.speciesId == speciesId
            )
        }
    }

    private func collapseWhitespace(_ text: String) -> String {
        text
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
