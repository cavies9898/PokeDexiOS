import Foundation

struct PokemonTeamRecord: Sendable {
    let idPokemon: Int
    let name: String
    let types: String
    let generation: String
    let region: String
    let habitat: String
    let color: String
    let shape: String
    let hp: Int
    let attack: Int
    let defense: Int
    let specialAttack: Int
    let specialDefense: Int
    let speed: Int
    let total: Int
    let idTeam: Int
}

actor UserDatabase {
    private let connection: SQLiteConnection
    private var observers: [UUID: AsyncStream<Void>.Continuation] = [:]

    init() throws {
        let url = try DatabaseHelper.userDatabaseURL()
        connection = try SQLiteConnection(path: url.path, readOnly: false)
        try connection.execute("PRAGMA foreign_keys = ON;")
        try createSchema()
    }

    func changesStream() -> AsyncStream<Void> {
        let id = UUID()
        return AsyncStream { continuation in
            observers[id] = continuation
            continuation.yield(())
            continuation.onTermination = { [weak self] _ in
                Task { await self?.removeObserver(id) }
            }
        }
    }

    private func removeObserver(_ id: UUID) {
        observers[id] = nil
    }

    private func notifyChange() {
        for continuation in observers.values {
            continuation.yield(())
        }
    }

    private func createSchema() throws {
        try connection.execute("""
        CREATE TABLE IF NOT EXISTS favorites (
            id INTEGER PRIMARY KEY NOT NULL,
            name TEXT NOT NULL
        );
        """)
        try connection.execute("""
        CREATE TABLE IF NOT EXISTS teams (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            createdAt INTEGER NOT NULL
        );
        """)
        try connection.execute("""
        CREATE TABLE IF NOT EXISTS pokemon_team (
            idPokemon INTEGER NOT NULL,
            name TEXT NOT NULL,
            types TEXT NOT NULL,
            generation TEXT NOT NULL,
            region TEXT NOT NULL,
            habitat TEXT NOT NULL,
            color TEXT NOT NULL,
            shape TEXT NOT NULL,
            hp INTEGER NOT NULL,
            attack INTEGER NOT NULL,
            defense INTEGER NOT NULL,
            specialAttack INTEGER NOT NULL,
            specialDefense INTEGER NOT NULL,
            speed INTEGER NOT NULL,
            total INTEGER NOT NULL,
            idTeam INTEGER NOT NULL,
            PRIMARY KEY(idPokemon, idTeam),
            FOREIGN KEY(idTeam) REFERENCES teams(id) ON DELETE CASCADE
        );
        """)
        try connection.execute("""
        CREATE INDEX IF NOT EXISTS index_pokemon_team_idTeam ON pokemon_team(idTeam);
        """)
    }

    // MARK: - Favorites

    func favoriteIds() throws -> [Int] {
        try connection
            .rows("SELECT id FROM favorites;")
            .map { $0.int("id") }
    }

    func insertFavorite(id: Int, name: String) throws {
        try connection.execute(
            "INSERT OR REPLACE INTO favorites (id, name) VALUES (?, ?);",
            params: [.integer(Int64(id)), .text(name)]
        )
        notifyChange()
    }

    func deleteFavorite(id: Int) throws {
        try connection.execute(
            "DELETE FROM favorites WHERE id = ?;",
            params: [.integer(Int64(id))]
        )
        notifyChange()
    }

    // MARK: - Teams

    struct TeamRow: Sendable {
        let id: Int
        let name: String
    }

    func teamRows() throws -> [TeamRow] {
        try connection
            .rows("SELECT id, name FROM teams ORDER BY createdAt DESC;")
            .map { TeamRow(id: $0.int("id"), name: $0.text("name")) }
    }

    func teamCounts() throws -> [Int: Int] {
        let rows = try connection.rows(
            "SELECT idTeam, COUNT(*) AS total FROM pokemon_team GROUP BY idTeam;"
        )
        var counts: [Int: Int] = [:]
        for row in rows {
            counts[row.int("idTeam")] = row.int("total")
        }
        return counts
    }

    func teamPokemonIds() throws -> [(idTeam: Int, idPokemon: Int)] {
        try connection
            .rows("SELECT idTeam, idPokemon FROM pokemon_team ORDER BY idTeam, rowid;")
            .map { (idTeam: $0.int("idTeam"), idPokemon: $0.int("idPokemon")) }
    }

    func insertTeam(name: String) throws -> Int {
        try connection.execute(
            "INSERT INTO teams (name, createdAt) VALUES (?, ?);",
            params: [.text(name), .integer(Int64(Date().timeIntervalSince1970 * 1000))]
        )
        notifyChange()
        return Int(connection.lastInsertedRowId)
    }

    func renameTeam(id: Int, name: String) throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw DomainError.emptyTeamName
        }
        try connection.execute(
            "UPDATE teams SET name = ? WHERE id = ?;",
            params: [.text(trimmed), .integer(Int64(id))]
        )
        notifyChange()
    }

    func deleteTeam(id: Int) throws {
        try connection.transaction {
            try connection.execute(
                "DELETE FROM pokemon_team WHERE idTeam = ?;",
                params: [.integer(Int64(id))]
            )
            try connection.execute(
                "DELETE FROM teams WHERE id = ?;",
                params: [.integer(Int64(id))]
            )
        }
        notifyChange()
    }

    // MARK: - Pokemon team

    func teamMembers(idTeam: Int) throws -> [PokemonTeamRecord] {
        try connection
            .rows(
                "SELECT * FROM pokemon_team WHERE idTeam = ? ORDER BY rowid;",
                params: [.integer(Int64(idTeam))]
            )
            .map { row in
                PokemonTeamRecord(
                    idPokemon: row.int("idPokemon"),
                    name: row.text("name"),
                    types: row.text("types"),
                    generation: row.text("generation"),
                    region: row.text("region"),
                    habitat: row.text("habitat"),
                    color: row.text("color"),
                    shape: row.text("shape"),
                    hp: row.int("hp"),
                    attack: row.int("attack"),
                    defense: row.int("defense"),
                    specialAttack: row.int("specialAttack"),
                    specialDefense: row.int("specialDefense"),
                    speed: row.int("speed"),
                    total: row.int("total"),
                    idTeam: row.int("idTeam")
                )
            }
    }

    func savePokemon(_ pokemon: Pokemon, idTeam: Int) throws -> SavePokemonOutcome {
        let outcome: SavePokemonOutcome = try connection.transaction {
            let countRow = try connection.firstRow(
                "SELECT COUNT(*) AS total FROM pokemon_team WHERE idTeam = ?;",
                params: [.integer(Int64(idTeam))]
            )
            let count = countRow?.int("total") ?? 0
            guard count < Team.maxPokemon else { return .teamFull }

            let duplicateRow = try connection.firstRow(
                "SELECT 1 AS present FROM pokemon_team WHERE idPokemon = ? AND idTeam = ?;",
                params: [.integer(Int64(pokemon.id)), .integer(Int64(idTeam))]
            )
            guard duplicateRow == nil else { return .duplicate }

            try connection.execute(
                """
                INSERT INTO pokemon_team (
                    idPokemon, name, types, generation, region, habitat, color, shape,
                    hp, attack, defense, specialAttack, specialDefense, speed, total, idTeam
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
                """,
                params: [
                    .integer(Int64(pokemon.id)),
                    .text(pokemon.name),
                    .text(TypesCSV.serialize(pokemon.types)),
                    .text(pokemon.generation),
                    .text(pokemon.region),
                    .text(pokemon.habitat ?? ""),
                    .text(pokemon.color),
                    .text(pokemon.shape),
                    .integer(Int64(pokemon.stats.hp)),
                    .integer(Int64(pokemon.stats.attack)),
                    .integer(Int64(pokemon.stats.defense)),
                    .integer(Int64(pokemon.stats.specialAttack)),
                    .integer(Int64(pokemon.stats.specialDefense)),
                    .integer(Int64(pokemon.stats.speed)),
                    .integer(Int64(pokemon.stats.total)),
                    .integer(Int64(idTeam)),
                ]
            )
            return .saved
        }
        notifyChange()
        return outcome
    }

    func deletePokemon(idPokemon: Int, idTeam: Int) throws -> Int {
        try connection.execute(
            "DELETE FROM pokemon_team WHERE idPokemon = ? AND idTeam = ?;",
            params: [.integer(Int64(idPokemon)), .integer(Int64(idTeam))]
        )
        let removed = connection.changes
        notifyChange()
        return removed
    }
}
